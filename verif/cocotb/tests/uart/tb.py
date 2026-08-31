import logging
import os

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, with_timeout


class TB:
    def __init__(self, dut):
        self.dut = dut
        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        self.get_params()
        self.display_params()
        self.get_signals()
        self.zero_input_signals()

        self.clk_period_ns = round(1e9 / self.clk_rate_param)
        self.cycles_per_bit = int(self.clk_rate_param / self.baud_rate_param)
        self.bit_time_ns = round(1e9 / self.baud_rate_param)
        cocotb.start_soon(Clock(self.clk, self.clk_period_ns, unit="ns").start())

    def get_params(self):
        self.rx_sync_stages_param = int(os.environ.get("PARAM_RX_SYNC_STAGES"))
        self.clk_rate_param = int(os.environ.get("PARAM_CLK_RATE"))
        self.baud_rate_param = int(os.environ.get("PARAM_BAUD_RATE"))
        self.rx_ila_en_param = int(os.environ.get("PARAM_RX_ILA_EN"))
        self.tx_ila_en_param = int(os.environ.get("PARAM_TX_ILA_EN"))
        self.loopback_en_param = int(os.environ.get("PARAM_LOOPBACK_EN"))
        self.transmitter_demo_en_param = int(
            os.environ.get("PARAM_TRANSMITTER_DEMO_EN")
        )

    def display_params(self):
        self.log.info("module parameters:")
        self.log.info(f"    RX_SYNC_STAGES = {self.rx_sync_stages_param}")
        self.log.info(f"    CLK_RATE = {self.clk_rate_param}")
        self.log.info(f"    BAUD_RATE = {self.baud_rate_param}")
        self.log.info(f"    RX_ILA_EN = {self.rx_ila_en_param}")
        self.log.info(f"    TX_ILA_EN = {self.tx_ila_en_param}")
        self.log.info(f"    LOOPBACK_EN = {self.loopback_en_param}")
        self.log.info(f"    TRANSMITTER_DEMO_EN = {self.transmitter_demo_en_param}")

    def get_signals(self):
        self.clk = self.dut.clk
        self.rstn = self.dut.rstn
        self.din_start = self.dut.din_start
        self.din = self.dut.din
        self.din_busy = self.dut.din_busy
        self.dout = self.dut.dout
        self.dout_v = self.dut.dout_v
        self.rx = self.dut.rx
        self.tx = self.dut.tx

    def zero_input_signals(self):
        self.rstn.value = 1
        self.din_start.value = 0
        self.din.value = 0
        self.rx.value = 1

    async def reset(self):
        await RisingEdge(self.clk)
        self.rstn.value = 0
        await RisingEdge(self.clk)
        self.rstn.value = 1

    async def drive_bit(self, bit):
        self.rx.value = bit
        for _ in range(self.cycles_per_bit):
            await RisingEdge(self.clk)

    async def drive_rx_byte(self, value):
        await self.drive_bit(0)
        for bit_index in range(8):
            await self.drive_bit((value >> bit_index) & 1)
        await self.drive_bit(1)

    async def expect_tx_byte(self, value):
        await with_timeout(FallingEdge(self.tx), 10 * self.bit_time_ns, "ns")
        for _ in range(8 // 2):
            await RisingEdge(self.clk)
        assert int(self.tx.value) == 0, "TX start bit was not low"

        for bit_index in range(8):
            for _ in range(8):
                await RisingEdge(self.clk)
            assert int(self.tx.value) == (
                (value >> bit_index) & 1
            ), f"TX bit {bit_index} was incorrect"

        for _ in range(8):
            await RisingEdge(self.clk)
        assert int(self.tx.value) == 1, "TX stop bit was not high"

    async def send_tx_byte(self, value):
        while int(self.din_busy.value):
            await RisingEdge(self.clk)
        self.din.value = value
        self.din_start.value = 1
        await RisingEdge(self.clk)
        self.din_start.value = 0

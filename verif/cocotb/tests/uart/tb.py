import logging
import os

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge


class TB:
    def __init__(self, dut):
        self.dut = dut
        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        self.get_params()
        self.display_params()
        self.get_signals()
        self.zero_input_signals()

        cocotb.start_soon(Clock(self.clk, 2, unit="ns").start())

    def get_params(self):
        self.rx_sync_stages_param = int(os.environ.get("PARAM_RX_SYNC_STAGES"))
        self.clk_rate_param = int(os.environ.get("PARAM_CLK_RATE"))
        self.baud_rate_param = int(os.environ.get("PARAM_BAUD_RATE"))
        self.rx_ila_en_param = int(os.environ.get("PARAM_RX_ILA_EN"))
        self.tx_ila_en_param = int(os.environ.get("PARAM_TX_ILA_EN"))
        self.loopback_en_param = int(os.environ.get("PARAM_LOOPBACK_EN"))
        self.transmitter_demo_en_param = int(os.environ.get("PARAM_TRANSMITTER_DEMO_EN"))

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
        self.rx = 1

    async def reset(self):
        await RisingEdge(self.clk)
        self.rstn.value = 0
        await RisingEdge(self.clk)
        self.rstn.value = 1

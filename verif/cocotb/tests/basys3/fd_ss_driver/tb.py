import logging
import os

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from fd_ss_data_classes import ss_digit


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
        self.refresh_rate_param = int(os.environ.get("PARAM_REFRESH_RATE"))

    def display_params(self):
        self.log.info("module parameters:")
        self.log.info(f"    REFRESH_RATE = {self.refresh_rate_param}")

    def get_signals(self):
        self.clk = self.dut.clk
        self.rstn = self.dut.rstn
        self.en = self.dut.en
        self.digits = self.dut.digits
        self.decimals = self.dut.decimals
        self.digit_segment = self.dut.digit_segment
        self.decimal_segment = self.dut.decimal_segment
        self.digit_en = self.dut.digit_en

    def zero_input_signals(self):
        self.rstn.value = 1
        self.en.value = 0
        self.digits.value = 0
        self.decimals.value = 0

    async def reset(self):
        await RisingEdge(self.clk)
        self.rstn.value = 0
        await RisingEdge(self.clk)
        self.rstn.value = 1

    async def display(self, val: hex, decimals: hex):
        self.digits.value = val
        self.decimals.value = decimals

        await self.reset()

        for i in range(4):
            digit = ss_digit((val & (0xF << (i * 4))) >> (i * 4))
            decimal = ((decimals & (0x1 << i)) >> i) ^ 0x1
            en = (0x1 << i) ^ 0xF
            for _ in range(2 ** (17 + self.refresh_rate_param - 2)):
                await RisingEdge(self.clk)
                if self.en.value == 1:
                    assert int(self.digit_en.value) == en
                    assert int(self.decimal_segment.value) == decimal
                    assert int(self.digit_segment.value) == digit.raw
                else:
                    assert int(self.digit_en.value) == 0xF
                    assert int(self.decimal_segment.value) == decimal
                    assert int(self.digit_segment.value) == digit.raw

import logging
import os

import cocotb
from cocotb.clock import Clock


class TB:
    def __init__(self, dut):
        self.dut = dut
        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        self.get_params()
        self.display_params()
        self.get_signals()

        cocotb.start_soon(Clock(self.clk, 2, unit="ns").start())

    def get_params(self):
        self.led_count_param = int(os.environ.get("PARAM_LED_COUNT"))
        self.counter_width_param = int(os.environ.get("PARAM_COUNTER_WIDTH"))

    def display_params(self):
        self.log.info("module parameters:")
        self.log.info(f"    LED_COUNT = {self.led_count_param}")
        self.log.info(f"    COUNTER_WIDTH = {self.counter_width_param}")

    def get_signals(self):
        self.clk = self.dut.clk
        self.led = self.dut.led

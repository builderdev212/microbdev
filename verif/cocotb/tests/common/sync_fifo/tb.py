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
        self.data_width_param = int(os.environ.get("PARAM_DATA_WIDTH"))
        self.fifo_depth_param = int(os.environ.get("PARAM_FIFO_DEPTH"))
        self.cnt_width_param = int(os.environ.get("PARAM_CNT_WIDTH"))
        self.drop_cnt_width_param = int(os.environ.get("PARAM_DROP_CNT_WIDTH"))

    def display_params(self):
        self.log.info("module parameters:")
        self.log.info(f"    DATA_WIDTH = {self.data_width_param}")
        self.log.info(f"    FIFO_DEPTH = {self.fifo_depth_param}")
        self.log.info(f"    CNT_WIDTH = {self.cnt_width_param}")
        self.log.info(f"    DROP_CNT_WIDTH = {self.drop_cnt_width_param}")

    def get_signals(self):
        self.clk = self.dut.clk
        self.rstn = self.dut.rstn
        self.wr_en = self.dut.wr_en
        self.din = self.dut.din
        self.rd_en = self.dut.rd_en
        self.dout = self.dut.dout
        self.dout_v = self.dut.dout_v
        self.empty = self.dut.empty
        self.full = self.dut.full
        self.cnt = self.dut.cnt
        self.drop_cnt = self.dut.drop_cnt

    def zero_input_signals(self):
        self.rstn.value = 1
        self.wr_en.value = 0
        self.din.value = 0
        self.rd_en.value = 0

    async def reset(self):
        await RisingEdge(self.clk)
        self.rstn.value = 0
        await RisingEdge(self.clk)
        self.rstn.value = 1

    async def cycle(self, wr_en=0, din=0, rd_en=0):
        self.log.info(f"Cycle: wr({wr_en},{din}) rd({rd_en})")
        self.wr_en.value = wr_en
        self.din.value = din
        self.rd_en.value = rd_en

        await RisingEdge(self.clk)
        await FallingEdge(self.clk)

        return {
            "dout": int(self.dout.value),
            "dout_v": int(self.dout_v.value),
            "empty": int(self.empty.value),
            "full": int(self.full.value),
            "cnt": int(self.cnt.value),
            "drop_cnt": int(self.drop_cnt.value),
        }

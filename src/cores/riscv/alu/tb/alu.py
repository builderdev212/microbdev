import logging
import os

import cocotb
from cocotb.clock import Clock


class DataError(Exception):
    pass


class TB:
    ALU_NOP = 0
    ALU_ADD = 1
    ALU_SUB = 2
    ALU_AND = 3
    ALU_OR = 4
    ALU_XOR = 5
    ALU_SLL = 6
    ALU_SRL = 7
    ALU_SRA = 8
    ALU_SLT = 9
    ALU_SLTU = 10

    def __init__(self, dut):
        self.dut = dut

        # Start logging
        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        # Simulation Signals
        self.get_signals()
        self.get_params()

        # Start Clock
        cocotb.start_soon(Clock(self.clk, 2, units="ns").start())

        # Zero out input signals
        self.zero_input_signals()

    def get_signals(self):
        self.rst_n = self.dut.rst_n
        self.req_valid = self.dut.req_valid
        self.req_ready = self.dut.req_ready
        self.cmd = self.dut.cmd
        self.rs1 = self.dut.rs1
        self.rs2 = self.dut.rs2
        self.shift_amount = self.dut.shift_amount
        self.resp_valid = self.dut.resp_valid
        self.resp_ready = self.dut.resp_valid
        self.result = self.dut.result
        self.illegal = self.dut.illegal

    def get_params(self):
        self.XLEN = int(os.environ.get('XLEN'))

    def zero_input_signals(self):
        self.rst_n = 0
        self.req_valid = 0
        self.cmd = 0
        self.rs1 = 0
        self.rs2 = 0
        self.shift_amount = 0
        self.resp_ready = 0

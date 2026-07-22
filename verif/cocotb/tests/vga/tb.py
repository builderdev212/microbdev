import logging

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from random import randint

class TB:
    def __init__(self, dut):
        self.dut = dut
        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        self.get_signals()

        cocotb.start_soon(Clock(self.clk, 2, unit="ns").start())

    def get_signals(self):
        self.clk = self.dut.clk
        self.rstn = self.dut.rstn
        self.din = self.dut.din
        self.din_v = self.dut.din_v
        self.wstart = self.dut.wstart
        self.wready = self.dut.wready
        self.wfinish = self.dut.wfinish
        self.hsync = self.dut.hsync
        self.vsync = self.dut.vsync
        self.red = self.dut.red
        self.green = self.dut.green
        self.blue = self.dut.blue

    def zero_input_signals(self):
        self.rstn.value = 1
        self.din.value = 0
        self.din_v.value = 0
        self.wstart.value = 0

    async def reset(self):
        await RisingEdge(self.clk)
        self.rstn.value = 0
        await RisingEdge(self.clk)
        self.rstn.value = 1

    async def write_frame(self, frame, skips=False):
        # Wait for Ready
        while not self.wready.value:
            await RisingEdge(self.clk)

        # Signify Start
        self.wstart.value = 1
        await RisingEdge(self.clk)
        self.wstart.value = 0

        # Send Frame
        count = 0 if self.dut.framebuffer_inst.curr_buff.value == 1 else 320*240
        for row in frame:
            for pixel in row:
                self.din.value = pixel
                self.din_v.value = 1
                assert self.wfinish.value == 0
                await RisingEdge(self.clk)
                if skips and self.wfinish.value == 0:
                    for _ in range(randint(0, 4)):
                        self.din.value = 0
                        self.din_v.value = 0
                        await RisingEdge(self.clk)

        assert self.wfinish.value == 1
        self.din.value = 0
        self.din_v.value = 0
        await RisingEdge(self.clk)

        for row in frame:
            for pixel in row:
                assert int(self.dut.framebuffer_inst.buff_ram[count].value) == pixel
                count += 1


    def rgb332_to_rgb_444(self, color):
        red = (color >> 5) & 0x7
        green = (color >> 2) & 0x7
        blue = color & 0x3

        red = (red << 1) | (red >> 2)
        green = (green << 1) | (green >> 2)
        blue = (blue << 2) | blue

        return red, green, blue

    async def verify_frame(self, frame):
        await RisingEdge(self.dut.clk)

        while not (self.dut.end_of_visible_frame.value == 1):
            await RisingEdge(self.dut.clk)
        for _ in range(240):
            while not (self.dut.valid.value == 1):
                await RisingEdge(self.dut.clk)

            await RisingEdge(self.dut.clk)
            await RisingEdge(self.dut.clk)

            for _ in range(320):
                x = int(self.dut.fb_h_pos.value)-1
                y = int(self.dut.fb_v_pos.value)
                self.log.info(f"x: {x}, y: {y}")

                expected = frame[y][x]

                exp_r, exp_g, exp_b = self.rgb332_to_rgb_444(expected)

                assert int(self.red.value) == exp_r
                assert int(self.green.value) == exp_g
                assert int(self.blue.value) == exp_b

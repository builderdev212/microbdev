`resetall
`timescale 1ns / 1ps
`default_nettype none

module xc7a35t_top #(
    parameter integer LED_COUNT = 16
)(
    input  wire                 clk,
    output wire [6:0]           digit_segment,
    output wire                 decimal_segment,
    output wire [3:0]           digit_en,
    output wire [LED_COUNT-1:0] led
);

  fd_ss_driver #(
    .REFRESH_RATE(3)
  ) fd_ss_driver_inst (
    .clk(clk),
    .rstn(1),
    .en(0),
    .digits(16'h89AB),
    .decimals(4'b0000),
    .digit_segment(digit_segment),
    .decimal_segment(decimal_segment),
    .digit_en(digit_en)
  );

  wire vga_clk;

  vga_clk_25_17007_pll vga_clk_inst (
    .clk_in1(clk),
    .resetn(1),
    .locked(),
    .clk_out1(vga_clk)
  );

  led_shift_reg #(
    .LED_COUNT(LED_COUNT)
  ) led_shift_reg_inst (
    .clk(vga_clk),
    .led(led)
  );

endmodule

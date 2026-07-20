`resetall
`timescale 1ns / 1ps
`default_nettype none

module xc7a35t_top #(
    parameter integer LED_COUNT = 16,
    parameter integer SWITCH_COUNT = 16
)(
    input  wire                    clk,
    // Four Digit Seven Segment LED Display //
    output wire [6:0]              digit_segment,
    output wire                    decimal_segment,
    output wire [3:0]              digit_en,
    // On-board LEDs //
    output wire [LED_COUNT-1:0]    led,
    // Switches //
    input  wire [SWITCH_COUNT-1:0] switch,
    // VGA //
    output wire [3:0]              vga_red,
    output wire [3:0]              vga_green,
    output wire [3:0]              vga_blue,
    output wire                    vga_hsync,
    output wire                    vga_vsync
);

  // Global Reset //
  wire global_rstn;
  assign global_rstn = switch[0];
  assign led[0] = global_rstn;

  // On-board LED Control //
  fd_ss_driver #(
    .REFRESH_RATE(3)
  ) fd_ss_driver_inst (
    .clk(clk),
    .rstn(global_rstn),
    .en(1),
    .digits({4'h0, vga_red, vga_green, vga_blue}),
    .decimals(4'b0000),
    .digit_segment(digit_segment),
    .decimal_segment(decimal_segment),
    .digit_en(digit_en)
  );

  // led_shift_reg #(
  //   .LED_COUNT(LED_COUNT)
  // ) led_shift_reg_inst (
  //   .clk(clk),
  //   .led(led)
  // );

  // VGA //
  wire vga_clk;
  wire vga_clk_locked;
  wire vga_valid;

  vga_clk_25_17007_pll vga_clk_inst (
    .clk_in1(clk),
    .resetn(global_rstn),
    .locked(vga_clk_locked),
    .clk_out1(vga_clk)
  );

  assign led[1] = vga_clk_locked;

  vga_core vga_core_inst (
    .clk(vga_clk),
    .rstn(vga_clk_locked && global_rstn),
    .hsync(vga_hsync),
    .vsync(vga_vsync),
    .valid(vga_valid)
  );

  assign led[2] = vga_hsync;
  assign led[3] = vga_vsync;

  assign vga_red   = vga_valid ? 4'hF : 4'h0;
  assign vga_green = vga_valid ? 4'h0 : 4'h0;
  assign vga_blue  = vga_valid ? 4'h0 : 4'h0;

endmodule

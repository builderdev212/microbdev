`timescale 1ns / 1ps
`default_nettype none

module uart_core #(
    parameter integer CLK_RATE = 100000000,
    parameter integer BAUD_RATE = 12000000
) (
    input  wire       clk,
    input  wire       rstn,
    // Input Data //
    input  wire [7:0] din,
    input  wire       din_v,
    // Output Data //
    input  wire [7:0] dout,
    input  wire       dout_v,
    // UART Interface //
    input  wire       rx,
    output wire       tx
);

endmodule

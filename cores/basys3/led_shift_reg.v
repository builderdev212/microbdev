`timescale 1ns / 1ps
`default_nettype none

module led_shift_reg #(
    parameter integer LED_COUNT = 16,
    parameter integer COUNTER_WIDTH = 32
) (
    input  wire                 clk,
    output wire [LED_COUNT-1:0] led
);

  reg [COUNTER_WIDTH-1:0] counter = 0;

  always @(posedge clk) begin
    counter <= counter + 1;
  end

  assign led = counter[COUNTER_WIDTH-1:COUNTER_WIDTH-LED_COUNT];

endmodule

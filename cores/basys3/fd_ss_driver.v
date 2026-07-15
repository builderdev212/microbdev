`timescale 1ns / 1ps
`default_nettype none

module fd_ss_driver #(
    /*
     * This is all based off of a 100MHz Clock
     * 0 - 1.31ms
     * 1 - 2.62ms
     * 2 - 5.24ms
     * 3 - 10.49ms
     */
    parameter REFRESH_RATE = 0
)(
    input  wire                 clk,
    input  wire                 en,
    input  wire [15:0]          digits,
    input  wire [4:0]           decimals,
    output wire [6:0]           digit_segment,
    output wire                 decimal_segment,
    output wire [3:0]           digit_en
);

  // Helper functions
  function [6:0] ss_hex_digit;
    input [3:0] a;
    begin
      case (a)
        4'h0: ss_hex_digit = 7'b1000000;
        4'h1: ss_hex_digit = 7'b1111001;
        4'h2: ss_hex_digit = 7'b0100100;
        4'h3: ss_hex_digit = 7'b0110000;
        4'h4: ss_hex_digit = 7'b0011001;
        4'h5: ss_hex_digit = 7'b0010010;
        4'h6: ss_hex_digit = 7'b0000010;
        4'h7: ss_hex_digit = 7'b1111000;
        4'h8: ss_hex_digit = 7'b0000000;
        4'h9: ss_hex_digit = 7'b0010000;
        4'hA: ss_hex_digit = 7'b0001000;
        4'hB: ss_hex_digit = 7'b0000011;
        4'hC: ss_hex_digit = 7'b1000110;
        4'hD: ss_hex_digit = 7'b0100001;
        4'hE: ss_hex_digit = 7'b0000110;
        4'hF: ss_hex_digit = 7'b0001110;
      endcase
    end
  endfunction

  // Counter to handle timing for digit enables.
  localparam COUNTER_WIDTH = 17 + REFRESH_RATE;

  reg [COUNTER_WIDTH-1:0] counter = 0;
  wire [1:0] digit_en_packed;

  always @(posedge clk) begin
    counter <= counter + 1;
  end

  assign digit_en_packed = counter[COUNTER_WIDTH-1:COUNTER_WIDTH-2];
  assign digit_en = en ? ~(1 << digit_en_packed) : 4'hF;

  // Output assignment
  reg [3:0] curr_digit = 0;
  reg curr_decimal = 0;

  assign digit_segment = ss_hex_digit(digits[4*digit_en_packed+:4]);
  assign decimal_segment = ~(decimals[digit_en_packed]);

endmodule

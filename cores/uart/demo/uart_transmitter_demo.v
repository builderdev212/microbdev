`timescale 1ns / 1ps
`default_nettype none

module uart_transmitter_demo (
    input  wire       clk,
    input  wire       rstn,
    // Data Interface //
    output wire [7:0] din,
    output wire       start,
    input  wire       busy
);

  reg [7:0] din_reg = 8'h55;
  reg       start_reg = 0;

  always @(posedge clk) begin
    if (!busy && !start) begin
        start_reg <= 1;
    end else begin
        start_reg <= 0;
    end
  end

  assign din = din_reg;
  assign start = start_reg;

endmodule

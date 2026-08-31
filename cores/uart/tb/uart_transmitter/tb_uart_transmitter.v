`resetall
`timescale 1ns / 1ps
`default_nettype none

module tb_uart_transmitter;

  localparam integer CLK_RATE = 96_000_000;
  localparam integer BAUD_RATE = 12_000_000;

  reg clk;
  reg rstn;

  reg start;
  reg [7:0] din;

  wire busy;
  wire tx;

  // Waveform Output
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_uart_transmitter);
  end

  // DUT
  uart_transmitter #(
      .CLK_RATE (CLK_RATE),
      .BAUD_RATE(BAUD_RATE),
      .ILA_EN(0)
  ) dut (
      .clk(clk),
      .rstn(rstn),
      .start(start),
      .din(din),
      .busy(busy),
      .tx(tx)
  );

  // 96 MHz Clock
  initial begin
    clk = 0;
    forever #5.208 clk = ~clk;
  end

  // Simulation
  initial begin
    $display(">>> TESTBENCH STARTED <<<");
    rstn  = 0;
    start = 0;
    din   = 8'h00;

    repeat (5) @(posedge clk);

    rstn = 1;
    $display(">>> RESET RELEASED <<<");

    repeat (5) @(posedge clk);

    din   = 8'hA5;
    start = 1;
    @(posedge clk);
    start = 0;

    $display(">>> START PULSED, busy=%b <<<", busy);

    wait (!busy);

    repeat (10) @(posedge clk);

    $finish;
  end

endmodule

`resetall
`timescale 1ns / 1ps
`default_nettype none

module tb_uart_receiver;

  reg        clk;
  reg        rstn;

  reg        rx;

  wire [7:0] dout;
  wire       dout_v;

  // Waveform Output
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_uart_receiver);
  end

  // DUT
  uart_receiver #(
      .SYNC_STAGES(2),
      .ILA_EN(0)
  ) dut (
      .clk(clk),
      .rstn(rstn),
      .rx(rx),
      .dout(dout),
      .dout_v(dout_v)
  );

  // 96 MHz Clock
  initial begin
    clk = 0;
    forever #5.208 clk = ~clk;
  end

  // Tasks
  task uart_bit;
    input value;
    integer j;
    begin
      rx = value;
      for (j = 0; j < 8; j = j + 1) @(posedge clk); // 12_000_000 Baud
    end
  endtask

  task uart_send;
    input [7:0] data;
    integer k;
    begin
      uart_bit(1'b0);
      for (k = 0; k < 8; k = k + 1) uart_bit(data[k]);
      uart_bit(1'b1);
      uart_bit(1'b1);
    end
  endtask

  // Simulation
  initial begin
    rstn = 0;
    rx   = 1'b1;

    repeat (10) @(posedge clk);

    rstn = 1;

    repeat (20) @(posedge clk);

    uart_send(8'h55);
    uart_send(8'hA5);
    uart_send(8'h00);
    uart_send(8'hFF);

    repeat (50) @(posedge clk);

    $finish;
  end

endmodule

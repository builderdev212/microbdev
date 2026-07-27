`resetall
`timescale 1ns / 1ps
`default_nettype none

module tb_uart_receiver;

  reg        clk;
  reg        rstn;

  reg        rx;

  wire [7:0] dout;
  wire       dout_v;

  uart_reciever dut (
      .clk(clk),
      .rstn(rstn),
      .rx(rx),
      .dout(dout),
      .dout_v(dout_v)
  );

  // 96 MHz clock
  initial begin
    clk = 0;
    forever #5.208 clk = ~clk;
  end

  task uart_bit;
    input value;
    integer j;
    begin
      rx = value;
      for (j = 0; j < BIT_CLKS; j = j + 1) @(posedge clk);
    end
  endtask

  task uart_send;
    input [7:0] data;
    integer k;
    begin
      // Start bit
      uart_bit(1'b0);

      // Data bits (LSB first)
      for (k = 0; k < 8; k = k + 1) uart_bit(data[k]);

      // Stop bit
      uart_bit(1'b1);

      // Idle for one bit
      uart_bit(1'b1);
    end
  endtask

  integer i;
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

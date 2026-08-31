`timescale 1ns / 1ps
`default_nettype none

module tb_uart_core;

  localparam integer CLK_RATE  = 96_000_000;
  localparam integer BAUD_RATE = 12_000_000;
  localparam real    CLK_PERIOD_NS = 1.0e9 / CLK_RATE;
  localparam real    BIT_PERIOD_NS = 1.0e9 / BAUD_RATE;
  localparam integer NUM_BYTES = 4;

  reg        clk  = 1'b0;
  reg        rstn = 1'b0;
  reg        rx   = 1'b1;
  reg        din_start = 1'b0;
  reg [7:0]  din = 8'h00;
  wire       din_busy;
  wire [7:0] dout;
  wire       dout_v;
  wire       tx;

  reg [7:0] expected [0:NUM_BYTES-1];
  integer sender_index;
  integer checker_index;

  // Waveform Output
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_uart_receiver);
  end

  always #(CLK_PERIOD_NS / 2.0) clk = ~clk;

  uart_core #(
      .CLK_RATE(CLK_RATE),
      .BAUD_RATE(BAUD_RATE),
      .LOOPBACK_EN(1)
  ) dut (
      .clk(clk), .rstn(rstn),
      .din_start(din_start), .din(din), .din_busy(din_busy),
      .dout(dout), .dout_v(dout_v),
      .rx(rx), .tx(tx)
  );

  // Send one 8-N-1 frame into the DUT, least-significant bit first.
  task send_uart_byte;
    input [7:0] data;
    integer bit_index;
    begin
      rx = 1'b0;                         // start bit
      #(BIT_PERIOD_NS);
      for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
        rx = data[bit_index];
        #(BIT_PERIOD_NS);
      end
      rx = 1'b1;                         // stop bit
      #(BIT_PERIOD_NS);
    end
  endtask

  // Decode one 8-N-1 frame from tx and compare it with the expected byte.
  task expect_uart_byte;
    input [7:0] data;
    reg [7:0] captured;
    integer bit_index;
    begin
      @(negedge tx);                     // beginning of start bit
      #(BIT_PERIOD_NS * 1.5);            // center of data bit 0
      for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
        captured[bit_index] = tx;
        #(BIT_PERIOD_NS);
      end
      if (tx !== 1'b1) begin
        $display("FAIL: missing stop bit at t=%0t", $time);
        $fatal;
      end
      if (captured !== data) begin
        $display("FAIL: expected 0x%02x, got 0x%02x at t=%0t",
                 data, captured, $time);
        $fatal;
      end
      $display("PASS: looped back 0x%02x at t=%0t", captured, $time);
    end
  endtask

  initial begin
    expected[0] = 8'h55;
    expected[1] = 8'hA3;
    expected[2] = 8'h00;
    expected[3] = 8'hFF;

    repeat (10) @(posedge clk);
    rstn = 1'b1;
    repeat (10) @(posedge clk);

    // Sender and checker run concurrently so back-to-back FIFO traffic is
    // exercised while tx is busy.
    fork
      begin
        for (sender_index = 0; sender_index < NUM_BYTES;
             sender_index = sender_index + 1)
          send_uart_byte(expected[sender_index]);
      end
      begin
        for (checker_index = 0; checker_index < NUM_BYTES;
             checker_index = checker_index + 1)
          expect_uart_byte(expected[checker_index]);
      end
    join

    $display("PASS: uart_core loopback test completed");
    #BIT_PERIOD_NS;
    $finish;
  end

  initial begin
    #(BIT_PERIOD_NS * NUM_BYTES * 30);
    $display("FAIL: test timed out");
    $fatal;
  end

endmodule

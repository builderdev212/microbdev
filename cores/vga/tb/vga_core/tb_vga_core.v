`resetall
`timescale 1ns / 1ps
`default_nettype none

module tb_vga_core;

  reg clk;
  reg rstn;

  // Waveform Output
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_uart_receiver);
  end

  initial begin
    clk = 0;
    // 25 MHz
    forever #20 clk = ~clk;
  end

  // Input interface //
  reg  [7:0] din = 0;
  reg        din_v = 0;
  reg        wstart = 0;
  wire       wready;
  wire       wfinish;

  // VGA outputs //
  wire       hsync;
  wire       vsync;
  wire [3:0] red;
  wire [3:0] green;
  wire [3:0] blue;

  vga_core dut (
      .clk(clk),
      .rstn(rstn),
      .din(din),
      .din_v(din_v),
      .wstart(wstart),
      .wready(wready),
      .wfinish(wfinish),
      .hsync(hsync),
      .vsync(vsync),
      .red(red),
      .green(green),
      .blue(blue)
  );

  integer i;
  initial begin
    // Reset
    rstn = 0;
    repeat (10) @(posedge clk);
    rstn = 1;

    // Wait until framebuffer is ready
    @(posedge wready);
    repeat (20) @(posedge clk);

    // Start writing frame
    @(posedge clk);
    wstart <= 1;
    @(posedge clk);
    wstart <= 0;

    // Send one complete 320x240 frame
    for (i = 0; i < 320 * 240; i = i + 1) begin
      @(posedge clk);
      din   <= 8'h44;
      din_v <= 1;
    end
    @(posedge clk);
    din_v <= 0;
    din   <= 0;

    // Wait to view frame being output
    repeat (100000) @(posedge clk);

    $finish;
  end

endmodule

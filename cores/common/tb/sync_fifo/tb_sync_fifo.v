`resetall
`timescale 1ns / 1ps
`default_nettype none

module tb_sync_fifo;

  localparam DATA_WIDTH = 8;
  localparam FIFO_DEPTH = 16;
  localparam CNT_WIDTH = $clog2(FIFO_DEPTH + 1);
  localparam DROP_CNT_WIDTH = 8;

  reg                       clk;
  reg                       rstn;

  reg                       wr_en;
  reg  [    DATA_WIDTH-1:0] din;

  reg                       rd_en;
  wire [    DATA_WIDTH-1:0] dout;
  wire                      dout_v;

  wire                      empty;
  wire                      full;
  wire [     CNT_WIDTH-1:0] cnt;
  wire [DROP_CNT_WIDTH-1:0] drop_cnt;

  // Waveform Output
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_sync_fifo);
  end

  // DUT
  sync_fifo #(
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_DEPTH(FIFO_DEPTH),
      .CNT_WIDTH(CNT_WIDTH),
      .DROP_CNT_WIDTH(DROP_CNT_WIDTH)
  ) dut (
      .clk(clk),
      .rstn(rstn),
      .wr_en(wr_en),
      .din(din),
      .rd_en(rd_en),
      .dout(dout),
      .dout_v(dout_v),
      .empty(empty),
      .full(full),
      .cnt(cnt),
      .drop_cnt(drop_cnt)
  );

  // Clock
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // Tasks
  task write_fifo;
    input [DATA_WIDTH-1:0] data;
    begin
      @(negedge clk);
      wr_en = 1'b1;
      din   = data;

      @(negedge clk);
      wr_en = 1'b0;
    end
  endtask

  task read_fifo;
    begin
      @(negedge clk);
      rd_en = 1'b1;

      @(negedge clk);
      rd_en = 1'b0;
    end
  endtask

  // Simulation
  integer i;

  initial begin
    wr_en = 1'b0;
    rd_en = 1'b0;
    din   = '0;
    rstn  = 1'b0;

    // Reset
    repeat (2) @(posedge clk);
    rstn = 1'b1;

    @(posedge clk);
    #1;

    // Write a few values
    write_fifo(8'hA0);
    write_fifo(8'hA1);
    write_fifo(8'hA2);
    write_fifo(8'hA3);

    @(posedge clk);
    #1;

    // Read them back
    read_fifo;
    read_fifo;
    read_fifo;
    read_fifo;

    @(posedge clk);
    #1;

    // Fill FIFO completely
    for (i = 0; i < FIFO_DEPTH; i = i + 1) write_fifo(i[7:0]);

    for (i = 0; i < FIFO_DEPTH; i = i + 1) write_fifo(i[7:0]);

    @(posedge clk);
    #1;

    // Drain FIFO
    for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
      read_fifo;

      if (dout !== i[DATA_WIDTH-1:0])
        $display("ERROR: Expected %02h, got %02h", i[DATA_WIDTH-1:0], dout);
    end

    @(posedge clk);
    #1;

    // Attempt read from empty FIFO
    @(negedge clk);
    rd_en = 1'b1;

    @(posedge clk);
    #1;

    rd_en = 1'b0;

    #20;
    $finish;
  end

endmodule

`timescale 1ns / 1ps
`default_nettype none

module sync_fifo #(
    parameter integer DATA_WIDTH = 8,
    parameter integer FIFO_DEPTH = 16,
    parameter integer CNT_WIDTH = $clog2(FIFO_DEPTH + 1),
    parameter integer DROP_CNT_WIDTH = 8
) (
    input  wire                      clk,
    input  wire                      rstn,
    // Write Interface //
    input  wire                      wr_en,
    input  wire [    DATA_WIDTH-1:0] din,
    // Read Interface //
    input  wire                      rd_en,
    output wire [    DATA_WIDTH-1:0] dout,
    output wire                      dout_v,
    // Status Flags //
    output wire                      empty,
    output wire                      full,
    output wire [     CNT_WIDTH-1:0] cnt,
    output wire [DROP_CNT_WIDTH-1:0] drop_cnt
);

  // FIFO Pointer Signals //
  localparam integer PTR_WIDTH = $clog2(FIFO_DEPTH);

  reg [     PTR_WIDTH-1:0] wr_ptr = 0;
  reg [     PTR_WIDTH-1:0] rd_ptr = 0;

  // RAM Signals //
  reg [    DATA_WIDTH-1:0] ram              [0:FIFO_DEPTH-1];

  // Output Data Signals //
  reg [    DATA_WIDTH-1:0] dout_reg = 0;
  reg                      dout_v_reg = 0;

  // Flag Signals //
  reg [     CNT_WIDTH-1:0] cnt_reg = 0;
  reg [DROP_CNT_WIDTH-1:0] drop_cnt_reg = 0;

  // Write Logic //
  always @(posedge clk) begin
    if (wr_en && !full) begin
      ram[wr_ptr] <= din;
      wr_ptr <= wr_ptr + 1;
    end

    if (!rstn) begin
      wr_ptr <= 0;
    end
  end

  // Read Logic //
  always @(posedge clk) begin
    if (rd_en && !empty) begin
      dout_reg <= ram[rd_ptr];
      dout_v_reg <= 1;
      rd_ptr <= rd_ptr + 1;
    end else begin
      dout_v_reg <= 0;
    end

    if (!rstn) begin
      dout_reg <= 0;
      dout_v_reg <= 0;
      rd_ptr <= 0;
    end
  end

  assign dout   = dout_reg;
  assign dout_v = dout_v_reg;

  // Flag Logic //
  always @(posedge clk) begin
    if (wr_en && !rd_en) begin
      if (cnt_reg != FIFO_DEPTH) begin
        cnt_reg <= cnt_reg + 1;
      end else begin
        drop_cnt_reg <= drop_cnt_reg + 1;
      end
    end else if (!wr_en && rd_en) begin
      if (cnt_reg != 0) begin
        cnt_reg <= cnt_reg - 1;
      end
    end

    if (!rstn) begin
      cnt_reg <= 0;
      drop_cnt_reg <= 0;
    end
  end

  assign full = cnt_reg == FIFO_DEPTH;
  assign empty = cnt_reg == 0;
  assign cnt = cnt_reg;
  assign drop_cnt = drop_cnt_reg;

endmodule

`timescale 1ns / 1ps
`default_nettype none

module uart_core #(
    parameter integer RX_SYNC_STAGES = 2,
    parameter integer CLK_RATE = 96_000_000,
    parameter integer BAUD_RATE = 12_000_000,
    parameter integer RX_ILA_EN = 0,
    parameter integer TX_ILA_EN = 0,
    parameter integer LOOPBACK_EN = 0,
    parameter integer TRANSMITTER_DEMO_EN = 0
) (
    input  wire       clk,
    input  wire       rstn,
    // Input Data //
    input  wire       din_start,
    input  wire [7:0] din,
    output wire       din_busy,
    // Output Data //
    input  wire [7:0] dout,
    input  wire       dout_v,
    // UART Interface //
    input  wire       rx,
    output wire       tx
);

  // Transmitter Signals //
  wire       tx_start;
  wire [7:0] tx_din;
  wire       tx_busy;

  // Reciever Signals //
  wire [7:0] rx_dout;
  wire       rx_dout_v;

  // Transmitter //
  uart_transmitter #(
      .CLK_RATE(CLK_RATE),
      .BAUD_RATE(BAUD_RATE),
      .ILA_EN(TX_ILA_EN)
  ) uart_core_tx_inst (
      .clk(clk),
      .rstn(rstn),
      .start(tx_start),
      .din(tx_din),
      .busy(tx_busy),
      .tx(tx)
  );

  // Reciever //
  generate
    if (TRANSMITTER_DEMO_EN == 0) begin : gen_uart_rx
      uart_receiver #(
          .SYNC_STAGES(RX_SYNC_STAGES),
          .ILA_EN(RX_ILA_EN)
      ) uart_core_rx_inst (
          .clk(clk),
          .rstn(rstn),
          .dout(rx_dout),
          .dout_v(rx_dout_v),
          .rx(rx)
      );
    end
  endgenerate

  // Input/Output Assignment //
  generate
    if (TRANSMITTER_DEMO_EN == 1) begin : gen_tx_demo
      uart_transmitter_demo uart_tx_demo_inst (
          .clk  (clk),
          .rstn (rstn),
          .din  (tx_din),
          .start(tx_start),
          .busy (tx_busy)
      );
    end else if (LOOPBACK_EN == 1) begin : gen_loopback
      wire loopback_fifo_empty;

      sync_fifo #(
        .DATA_WIDTH(8),
        .FIFO_DEPTH(32),
        .CNT_WIDTH(5),
        .DROP_CNT_WIDTH(8)
      ) loopback_fifo_inst (
        .clk(clk),
        .rstn(rstn),
        .wr_en(rx_dout_v),
        .din(rx_dout),
        .rd_en(!loopback_fifo_empty && !tx_busy),
        .dout(tx_din),
        .dout_v(tx_start),
        .empty(loopback_fifo_empty),
        .full(),
        .cnt(),
        .drop_cnt()
      );

      assign din_busy = 0;
    end else begin : gen_custom_hookup
      assign tx_start = din_start;
      assign tx_din = din;
      assign din_busy = tx_busy;

      assign rx_dout = dout;
      assign rx_dout_v = dout_v;
    end
  endgenerate

endmodule

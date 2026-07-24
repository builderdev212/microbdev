`timescale 1ns / 1ps
`default_nettype none

module uart_transmitter #(
    parameter integer CLK_RATE  = 96_000_000,
    parameter integer BAUD_RATE = 12_000_000
) (
    input  wire       clk,
    input  wire       rstn,
    // Data Interface //
    input  wire       start,
    input  wire [7:0] din,
    output wire       busy,
    // UART Interface //
    output wire       tx
);

  // Clock Enable Signals //
  localparam integer DIV_CNT = CLK_RATE / BAUD_RATE;
  localparam integer DIV_WIDTH = $clog2(DIV_CNT);

  reg [DIV_WIDTH-1:0] tick_cnt = 0;
  reg                 tick = 0;

  // Input Handling Signals //
  reg [          7:0] latched_din = 0;
  reg [          2:0] curr_bit = 0;

  // Output Signals //
  reg                 tx_reg = 1;

  // FSM Signals //
  localparam [1:0] READY = 0, START = 1, DATA = 2, STOP = 3;

  reg [1:0] state_reg = READY;

  // Clock Enable Generator //
  always @(posedge clk) begin
    if (state_reg == READY) begin
      tick_cnt <= 0;
      tick <= 0;
    end else begin
      if (tick_cnt == DIV_CNT - 1) begin
        tick_cnt <= 0;
        tick <= 1;
      end else begin
        tick_cnt <= tick_cnt + 1;
        tick <= 0;
      end
    end

    if (!rstn) begin
      tick_cnt <= 0;
      tick <= 0;
    end
  end

  // FSM //
  always @(posedge clk) begin
    case (state_reg)
      READY: begin
        if (start) begin
          state_reg <= START;
        end
      end
      START: begin
        if (tick) begin
          state_reg <= DATA;
        end
      end
      DATA: begin
        if ((curr_bit == 3'b111) && tick) begin
          state_reg <= STOP;
        end
      end
      STOP: begin
        if (tick) begin
          state_reg <= READY;
        end
      end
      default: begin
        state_reg <= state_reg;
      end
    endcase

    if (!rstn) begin
      state_reg <= READY;
    end
  end

  // Input Latch //
  always @(posedge clk) begin
    if ((state_reg == READY) && start) begin
      latched_din <= din;
    end
    if ((state_reg == DATA) && tick) begin
      latched_din <= {1'b0, latched_din[7:1]};
    end

    if (!rstn) begin
      latched_din <= 0;
    end
  end

  assign busy = state_reg != READY;

  // Output Data Shift Reg //
  always @(posedge clk) begin
    if (state_reg == DATA) begin
      if (tick) begin
        curr_bit <= curr_bit + 1;
      end
    end else begin
      curr_bit <= 0;
    end

    if (!rstn) begin
      curr_bit <= 0;
    end
  end

  // TX Output //
  always @(posedge clk) begin
    case (state_reg)
      START: begin
        tx_reg <= 0;
      end
      DATA: begin
        tx_reg <= latched_din[0];
      end
      default: begin
        tx_reg <= 1;
      end
    endcase

    if (!rstn) begin
      tx_reg <= 1;
    end
  end

  assign tx = tx_reg;

endmodule

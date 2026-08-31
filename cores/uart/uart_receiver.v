`timescale 1ns / 1ps
`default_nettype none

module uart_receiver #(
    parameter integer SYNC_STAGES = 2,
    parameter integer ILA_EN = 0
) (
    input  wire       clk,
    input  wire       rstn,
    // Data Interface //
    output wire [7:0] dout,
    output wire       dout_v,
    // UART Interface //
    input  wire       rx
);

  // Input Synchronizer Signals //
  (* ASYNC_REG = "TRUE" *) reg [SYNC_STAGES-1:0] rx_ff;
  wire rx_sync;

  // Start Detection Signals //
  wire uart_transaction_start;
  reg rx_prev;

  // FSM Signals //
  localparam [1:0] READY = 0, START = 1, DATA = 2, STOP = 3;

  reg [1:0] state_reg;

  // Bit Sample Signals //
  reg [2:0] sample_cnt;
  reg [3:0] bit_cnt;
  reg [7:0] dout_reg;
  reg       dout_v_reg;

  // ILA //
  generate
    if (ILA_EN == 1) begin : gen_uart_transmitter_ila
      uart_ila uart_reciever_ila (
          .clk(clk),
          .probe0(dout_v),
          .probe1(dout),
          .probe2(uart_transaction_start),
          .probe3(rx)
      );
    end
  endgenerate

  // Input Synchronizer //
  integer sync_stage;
  always @(posedge clk) begin
    rx_ff[SYNC_STAGES-1] <= rx;

    for (sync_stage = 0; sync_stage < SYNC_STAGES - 1; sync_stage = sync_stage + 1) begin
      rx_ff[sync_stage] <= rx_ff[sync_stage+1];
    end

    if (!rstn) begin
      rx_ff <= {SYNC_STAGES{1'b1}};
    end
  end

  assign rx_sync = rx_ff[0];

  // Start Detection //
  always @(posedge clk) begin
    rx_prev <= rx_sync;

    if (!rstn) begin
      rx_prev <= 0;
    end
  end

  assign uart_transaction_start = rx_prev && !rx_sync;

  // FSM //
  always @(posedge clk) begin
    case (state_reg)
      READY: begin
        if (uart_transaction_start) begin
          state_reg <= START;
        end
      end
      START: begin
        if (sample_cnt == 3) begin
          state_reg <= DATA;
        end
      end
      DATA: begin
        if (bit_cnt == 8) begin
          state_reg <= STOP;
        end
      end
      STOP: begin
        if (sample_cnt == 7) begin
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

  // Sample Counter //
  always @(posedge clk) begin
    if (state_reg != READY) begin
      if ((state_reg == START) && sample_cnt == 3) begin
        sample_cnt <= 0;
      end else begin
        sample_cnt <= sample_cnt + 1;
      end
    end else begin
      sample_cnt <= 0;
    end

    if (!rstn) begin
      sample_cnt <= 0;
    end
  end

  // Bit Counter //
  always @(posedge clk) begin
    if (state_reg == DATA) begin
      if (sample_cnt == 7) begin
        bit_cnt <= bit_cnt + 1;
      end
    end else begin
      bit_cnt <= 0;
    end

    if (!rstn) begin
      bit_cnt <= 0;
    end
  end

  // Output Shift Reg //
  always @(posedge clk) begin
    if (state_reg == DATA) begin
      if (sample_cnt == 7) begin
        dout_reg[bit_cnt[2:0]] <= rx_sync;
      end
    end

    if (!rstn) begin
      dout_reg <= 0;
    end
  end

  assign dout = dout_reg;

  // Data Valid Gen //
  always @(posedge clk) begin
    dout_v_reg <= 0;

    if ((state_reg == DATA) && (sample_cnt == 7) && (bit_cnt == 7)) begin
      dout_v_reg <= 1;
    end

    if (!rstn) begin
      dout_v_reg <= 0;
    end
  end

  assign dout_v = dout_v_reg;

endmodule

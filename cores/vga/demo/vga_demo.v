`timescale 1ns / 1ps
`default_nettype none

module vga_demo (
    input  wire       clk,
    input  wire       rstn,
    // VGA //
    output wire [7:0] din,
    output wire       din_v,
    output wire       wstart,
    input  wire       wready,
    input  wire       wfinish
);

  localparam integer FRAME_SIZE = 320 * 240;
  localparam integer CLK_FREQ = 25170070;
  localparam integer DELAY_COUNT = CLK_FREQ * 3;

  // Frame data interface //
  reg [7:0] din_reg;
  reg       din_v_reg;
  reg       wstart_reg;

  assign din = din_reg;
  assign din_v = din_v_reg;
  assign wstart = wstart_reg;

  // FSM Signals //
  localparam [1:0] S_WAIT = 0, S_START = 1, S_WRITE = 2, S_DELAY = 3;
  reg [ 1:0] state;

  // Counters //
  reg [27:0] delay_counter;

  always @(posedge clk) begin
    if ((state == S_DELAY) && !(delay_counter == DELAY_COUNT - 1)) begin
      delay_counter <= delay_counter + 1;
    end else begin
      delay_counter <= 0;
    end

    if (!rstn) begin
      delay_counter <= 0;
    end
  end

  // FSM Logic //
  always @(posedge clk) begin
    case (state)
      S_WAIT: begin
        if (wready) begin
          state <= S_START;
        end
      end
      S_START: begin
        state <= S_WRITE;
      end
      S_WRITE: begin
        if (wfinish) begin
          state <= S_DELAY;
        end
      end
      S_DELAY: begin
        if (delay_counter == DELAY_COUNT - 1) begin
          state <= S_WAIT;
        end
      end
      default: begin
        state <= state;
      end
    endcase

    if (!rstn) begin
      state <= S_WAIT;
    end
  end

  // Frame Data //
  reg [1:0] color_sel;

  always @(posedge clk) begin
    // Start sending data
    if (state == S_START) begin
      wstart_reg <= 1;
    end else begin
      wstart_reg <= 0;
    end

    // Output data
    if (state == S_WRITE) begin
      din_v_reg <= 1;
      case (color_sel)
        // https://roger-random.github.io/RGB332_color_wheel_three.js/
        0: din_reg <= 8'hE0;  // Red
        1: din_reg <= 8'h1C;  // Green
        2: din_reg <= 8'h03;  // Blue
        3: din_reg <= 8'hEB;  // Pink
        default: din_reg <= 8'hFF;  // White
      endcase
    end else begin
      din_v_reg <= 0;
    end

    // Loop through colors
    if (state == S_DELAY) begin
      if (delay_counter == DELAY_COUNT - 1) begin
        color_sel <= color_sel + 1;
      end
    end

    if (!rstn) begin
      color_sel  <= 0;
      din_reg    <= 8'd0;
      din_v_reg  <= 1'b0;
      wstart_reg <= 1'b0;
    end
  end

endmodule

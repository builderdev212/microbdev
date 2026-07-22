`timescale 1ns / 1ps
`default_nettype none

module vga_double_framebuffer #(
    parameter integer H_TOTAL = 320,
    parameter integer H_POS_WIDTH = $clog2(H_TOTAL),
    parameter integer V_TOTAL = 240,
    parameter integer V_POS_WIDTH = $clog2(V_TOTAL)
) (
    input  wire                   clk,
    input  wire                   rstn,
    // Input data //
    input  wire [            7:0] din,
    input  wire                   din_v,
    input  wire                   wstart,
    output wire                   wready,
    output wire                   wfinish,
    // Position from vga_pos_sync //
    input  wire [H_POS_WIDTH-1:0] h_pos,
    input  wire [V_POS_WIDTH-1:0] v_pos,
    input  wire                   valid_pos,
    input  wire                   end_of_visible_frame,
    // Output color //
    output wire [            7:0] color
);

  // Framebuffer RAM Signals //
  localparam integer RAM_ADDR_CNT = 2*H_TOTAL*V_TOTAL;
  localparam integer RAM_ADDR_WIDTH = $clog2(RAM_ADDR_CNT);
  localparam integer BUFF0_ADDR = 0;
  localparam integer BUFF0_ADDR_END = H_TOTAL*V_TOTAL-1;
  localparam integer BUFF1_ADDR = H_TOTAL*V_TOTAL;
  localparam integer BUFF1_ADDR_END = 2*H_TOTAL*V_TOTAL-1;
  localparam integer DEFAULT_COLOR = 8'h0;

  // Idea is whatever the current displayed buffer is, the other buffer
  // should be written to to prevent tearing, then swapped out.
  function automatic [RAM_ADDR_WIDTH-1:0] buff_starting_addr;
    input curr_disp_buff;
    begin
      if (curr_disp_buff) begin
        buff_starting_addr = BUFF0_ADDR;
      end else begin
        buff_starting_addr = BUFF1_ADDR;
      end
    end
  endfunction

  function automatic [RAM_ADDR_WIDTH-1:0] buff_ending_addr;
    input curr_disp_buff;
    begin
      if (curr_disp_buff) begin
        buff_ending_addr = BUFF0_ADDR_END;
      end else begin
        buff_ending_addr = BUFF1_ADDR_END;
      end
    end
  endfunction

  // Should return the current starting address of the displayed region.
  function automatic [RAM_ADDR_WIDTH-1:0] color_starting_addr;
    input curr_disp_buff;
    begin
      if (curr_disp_buff) begin
        color_starting_addr = BUFF1_ADDR;
      end else begin
        color_starting_addr = BUFF0_ADDR;
      end
    end
  endfunction

  reg [7:0] buff_ram [0:RAM_ADDR_CNT-1];
  reg [RAM_ADDR_WIDTH-1:0] buff_wraddr = BUFF1_ADDR;
  reg curr_buff = 0;

  // State Signals //
  localparam [1:0]
    BUFF_CLEAR = 0,
    BUFF_SWAP = 1,
    BUFF_READY = 2,
    BUFF_WRITE = 3;

  reg [1:0] state_reg = BUFF_CLEAR;

  // Control FSM //
  always @(posedge clk) begin
    case (state_reg)
      BUFF_CLEAR:
        begin
          if (wfinish) begin
            state_reg <= BUFF_SWAP;
          end
        end
      BUFF_SWAP:
        begin
          if (end_of_visible_frame) begin
            state_reg <= BUFF_READY;
          end
        end
      BUFF_READY:
        begin
          if (wstart) begin
            state_reg <= BUFF_WRITE;
          end
        end
      BUFF_WRITE:
        begin
          if (wfinish) begin
            state_reg <= BUFF_SWAP;
          end
        end
      default:
        begin
          state_reg <= BUFF_CLEAR;
        end
    endcase

    if (!rstn) begin
      state_reg <= BUFF_CLEAR;
    end
  end

  // Buffer Write Control //
  always @(posedge clk) begin
    if (state_reg == BUFF_CLEAR) begin
      buff_wraddr <= buff_wraddr + 1;
      buff_ram[buff_wraddr] <= DEFAULT_COLOR;
    end else if (state_reg == BUFF_WRITE) begin
      if (din_v) begin
        buff_wraddr <= buff_wraddr + 1;
        buff_ram[buff_wraddr] <= din;
      end
    end else begin
      buff_wraddr <= buff_starting_addr(curr_buff);
    end
  end

  assign wready = (state_reg == BUFF_READY) ? 1 : 0;
  assign wfinish = (buff_wraddr == buff_ending_addr(curr_buff)) ? 1 : 0;

  // Swap Frame Control //
  reg prev_buff = 0;
  always @(posedge clk) begin
    if (state_reg == BUFF_SWAP) begin
      if (curr_buff == prev_buff) begin
        curr_buff <= ~curr_buff;
      end
    end else begin
      prev_buff <= curr_buff;
      curr_buff <= curr_buff;
    end
  end

  // Color Output //
  reg [7:0] color_reg = 0;

  always @(posedge clk) begin
    if (valid_pos) begin
      color_reg <= buff_ram[color_starting_addr(curr_buff) + (v_pos*H_TOTAL) + h_pos];
    end else begin
      color_reg <= 0;
    end
  end

  assign color = color_reg;

endmodule

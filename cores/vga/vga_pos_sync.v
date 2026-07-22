`timescale 1ns / 1ps
`default_nettype none

module vga_pos_sync #(
    // 640x480 60Hz //
    // DMT V1.0 Rev.13 pg.21 //
    // Horizontal pixels //
    parameter integer H_ACTIVE = 640,
    parameter integer H_FRONT_PORCH = 16,
    parameter integer H_SYNC = 96,
    parameter integer H_BACK_PORCH = 48,
    parameter integer H_TOTAL = H_ACTIVE + H_FRONT_PORCH + H_SYNC + H_BACK_PORCH,
    parameter integer H_POS_WIDTH = $clog2(H_TOTAL),

    // Vertical rows //
    parameter integer V_ACTIVE = 480,
    parameter integer V_FRONT_PORCH = 10,
    parameter integer V_SYNC = 2,
    parameter integer V_BACK_PORCH = 33,
    parameter integer V_TOTAL = V_ACTIVE + V_FRONT_PORCH + V_SYNC + V_BACK_PORCH,
    parameter integer V_POS_WIDTH = $clog2(V_TOTAL)
) (
    input  wire                   clk,
    input  wire                   rstn,
    // Current Position //
    output wire [H_POS_WIDTH-1:0] h_pos,
    output wire [V_POS_WIDTH-1:0] v_pos,
    // Sync Signals //
    output wire                   hsync,
    output wire                   vsync,
    // Status Signals //
    output wire                   valid,
    output wire                   end_of_visible_frame
);

  // Horizontal Position
  reg [H_POS_WIDTH-1:0] h_pos_reg = 0;  // X position

  always @(posedge clk) begin
    if (h_pos_reg == H_TOTAL - 1) begin
      h_pos_reg <= 0;
    end else begin
      h_pos_reg <= h_pos_reg + 1;
    end

    if (!rstn) begin
      h_pos_reg <= 0;
    end
  end

  assign h_pos = h_pos_reg;
  assign hsync = ~((h_pos_reg >= H_ACTIVE + H_FRONT_PORCH) && (h_pos_reg < H_ACTIVE + H_FRONT_PORCH + H_SYNC));

  // Vertical Position
  reg [V_POS_WIDTH-1:0] v_pos_reg = 0;  // Y position

  always @(posedge clk) begin
    if (h_pos_reg == H_TOTAL - 1) begin
      if (v_pos_reg == V_TOTAL - 1) begin
        v_pos_reg <= 0;
      end else begin
        v_pos_reg <= v_pos_reg + 1;
      end
    end

    if (!rstn) begin
      v_pos_reg <= 0;
    end
  end

  assign v_pos = v_pos_reg;
  assign vsync = ~((v_pos_reg >= V_ACTIVE + V_FRONT_PORCH) && (v_pos_reg < V_ACTIVE + V_FRONT_PORCH + V_SYNC));

  // Draw Valid
  assign valid = (h_pos_reg < H_ACTIVE) && (v_pos_reg < V_ACTIVE);

  // End of Visible Frame
  assign end_of_visible_frame = (v_pos == V_ACTIVE) && (h_pos == 0);

endmodule

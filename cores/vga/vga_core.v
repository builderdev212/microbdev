`timescale 1ns / 1ps
`default_nettype none

module vga_core (
    input  wire       clk,
    input  wire       rstn,
    // Input Data //
    input  wire [7:0] din,
    input  wire       din_v,
    input  wire       wstart,
    output wire       wready,
    output wire       wfinish,
    // VGA Interface //
    output wire       hsync,
    output wire       vsync,
    output wire [3:0] red,
    output wire [3:0] green,
    output wire [3:0] blue
);

  // VGA Sync and Position Generator //
  localparam integer H_ACTIVE = 640;
  localparam integer H_FRONT_PORCH = 16;
  localparam integer H_SYNC = 96;
  localparam integer H_BACK_PORCH = 48;
  localparam integer H_TOTAL = H_ACTIVE + H_FRONT_PORCH + H_SYNC + H_BACK_PORCH;
  localparam integer H_POS_WIDTH = $clog2(H_TOTAL);
  localparam integer V_ACTIVE = 480;
  localparam integer V_FRONT_PORCH = 10;
  localparam integer V_SYNC = 2;
  localparam integer V_BACK_PORCH = 33;
  localparam integer V_TOTAL = V_ACTIVE + V_FRONT_PORCH + V_SYNC + V_BACK_PORCH;
  localparam integer V_POS_WIDTH = $clog2(V_TOTAL);

  wire [H_POS_WIDTH-1:0] h_pos;
  wire [V_POS_WIDTH-1:0] v_pos;
  wire                   hsync_w;
  wire                   vsync_w;
  wire                   valid;
  wire                   end_of_visible_frame;

  vga_pos_sync #(
      .H_ACTIVE(H_ACTIVE),
      .H_FRONT_PORCH(H_FRONT_PORCH),
      .H_SYNC(H_SYNC),
      .H_BACK_PORCH(H_BACK_PORCH),
      .H_TOTAL(H_TOTAL),
      .H_POS_WIDTH(H_POS_WIDTH),
      .V_ACTIVE(V_ACTIVE),
      .V_FRONT_PORCH(V_FRONT_PORCH),
      .V_SYNC(V_SYNC),
      .V_BACK_PORCH(V_BACK_PORCH),
      .V_TOTAL(V_TOTAL),
      .V_POS_WIDTH(V_POS_WIDTH)
  ) sync_gen_inst (
      .clk(clk),
      .rstn(rstn),
      .h_pos(h_pos),
      .v_pos(v_pos),
      .hsync(hsync_w),
      .vsync(vsync_w),
      .valid(valid),
      .end_of_visible_frame(end_of_visible_frame)
  );

  // Sync Clocking //
  reg hsync_reg;
  reg vsync_reg;

  always @(posedge clk) begin
    hsync_reg <= hsync_w;
    vsync_reg <= vsync_w;
  end

  assign hsync = hsync_reg;
  assign vsync = vsync_reg;

  // VGA Framebuffer //
  localparam integer FB_H_TOTAL = H_ACTIVE / 2;
  localparam integer FB_H_POS_WIDTH = $clog2(FB_H_TOTAL);
  localparam integer FB_V_TOTAL = V_ACTIVE / 2;
  localparam integer FB_V_POS_WIDTH = $clog2(FB_V_TOTAL);

  wire [FB_H_POS_WIDTH-1:0] fb_h_pos;
  wire [FB_V_POS_WIDTH-1:0] fb_v_pos;
  wire [7:0] color;

  vga_double_framebuffer #(
      .H_TOTAL(FB_H_TOTAL),
      .H_POS_WIDTH(FB_H_POS_WIDTH),
      .V_TOTAL(FB_V_TOTAL),
      .V_POS_WIDTH(FB_V_POS_WIDTH)
  ) framebuffer_inst (
      .clk(clk),
      .rstn(rstn),
      .din(din),
      .din_v(din_v),
      .wstart(wstart),
      .wready(wready),
      .wfinish(wfinish),
      .h_pos(fb_h_pos),
      .v_pos(fb_v_pos),
      .valid_pos(valid),
      .end_of_visible_frame(end_of_visible_frame),
      .color(color)
  );

  assign fb_h_pos = h_pos[1+:FB_H_POS_WIDTH];
  assign fb_v_pos = v_pos[1+:FB_V_POS_WIDTH];

  // Color Output //
  assign red = {color[7:5], color[7]};
  assign green = {color[4:2], color[4]};
  assign blue = {color[1:0], color[1:0]};

endmodule

`timescale 1ns / 1ps
`default_nettype none

module xc7a35t_top #(
    parameter integer LED_SHIFT_REG_EN = 0,
    parameter integer LED_COUNT = 16,
    parameter integer SWITCH_COUNT = 16,
    parameter integer INCLUDE_VGA = 1,
    parameter integer INCLUDE_VGA_DEMO = 1,
    parameter integer INCLUDE_UART = 1,
    parameter integer UART_TRANSMITTER_DEMO = 0,
    parameter integer UART_LOOPBACK = 1
) (
    input  wire                    clk,
    // Four Digit Seven Segment LED Display //
    output wire [             6:0] digit_segment,
    output wire                    decimal_segment,
    output wire [             3:0] digit_en,
    // On-board LEDs //
    output wire [   LED_COUNT-1:0] led,
    // Switches //
    input  wire [SWITCH_COUNT-1:0] switch,
    // VGA //
    output wire [             3:0] vga_red,
    output wire [             3:0] vga_green,
    output wire [             3:0] vga_blue,
    output wire                    vga_hsync,
    output wire                    vga_vsync,
    // UART //
    input  wire                    uart_rx,
    output wire                    uart_tx
);

  // Global Reset Signals //
  wire global_rstn;
  assign global_rstn = switch[0];

  // LED Signals //
  wire [15:0] fd_ss_digits;
  wire [ 3:0] fd_ss_decimal;

  assign fd_ss_digits  = 16'hb212;
  assign fd_ss_decimal = 4'h0;

  // VGA Signals //
  wire       vga_clk;
  wire       vga_clk_locked;
  wire       vga_rstn;
  wire [7:0] vga_din;
  wire       vga_din_v;
  wire       vga_wstart;
  wire       vga_wready;
  wire       vga_wfinish;

  // UART Signals //
  wire       uart_clk;
  wire       uart_clk_locked;
  wire       uart_rstn;

  // LEDs //
  fd_ss_driver #(
      .REFRESH_RATE(3)
  ) fd_ss_driver_inst (
      .clk(clk),
      .rstn(global_rstn),
      .en(1),
      .digits(fd_ss_digits),
      .decimals(fd_ss_decimal),
      .digit_segment(digit_segment),
      .decimal_segment(decimal_segment),
      .digit_en(digit_en)
  );

  generate
    if (LED_SHIFT_REG_EN == 1) begin : gen_led_shift_reg
      led_shift_reg #(
          .LED_COUNT(LED_COUNT)
      ) led_shift_reg_inst (
          .clk(clk),
          .led(led)
      );
    end else begin : gen_led_status_bits
      assign led[0] = global_rstn;
      if (INCLUDE_VGA == 1) begin : gen_vga_led_status
        assign led[1] = vga_clk_locked;
      end
    end
  endgenerate

  // VGA //
  generate
    if (INCLUDE_VGA == 1) begin : gen_vga_core
      vga_clk_25_17007_pll vga_clk_inst (
          .clk_in1 (clk),
          .resetn  (global_rstn),
          .locked  (vga_clk_locked),
          .clk_out1(vga_clk)
      );

      assign vga_rstn = vga_clk_locked && global_rstn;

      vga_core vga_core_inst (
          .clk(vga_clk),
          .rstn(vga_rstn),
          .din(vga_din),
          .din_v(vga_din_v),
          .wstart(vga_wstart),
          .wready(vga_wready),
          .wfinish(vga_wfinish),
          .hsync(vga_hsync),
          .vsync(vga_vsync),
          .red(vga_red),
          .blue(vga_blue),
          .green(vga_green)
      );

      if (INCLUDE_VGA_DEMO == 1) begin : gen_vga_demo
        vga_demo vga_demo_inst (
            .clk(vga_clk),
            .rstn(vga_rstn),
            .din(vga_din),
            .din_v(vga_din_v),
            .wstart(vga_wstart),
            .wready(vga_wready),
            .wfinish(vga_wfinish)
        );
      end
    end
  endgenerate

  // UART //
  generate
    if (INCLUDE_UART == 1) begin : gen_uart_core
      uart_clk_96_pll uart_clk_inst (
          .clk_in1 (clk),
          .resetn  (global_rstn),
          .locked  (uart_clk_locked),
          .clk_out1(uart_clk)
      );

      assign uart_rstn = uart_clk_locked && global_rstn;

      uart_core #(
          .RX_SYNC_STAGES(2),
          .CLK_RATE(96_000_000),
          .BAUD_RATE(12_000_000),
          .RX_ILA_EN(0),
          .TX_ILA_EN(0),
          .LOOPBACK_EN(UART_LOOPBACK),
          .TRANSMITTER_DEMO_EN(UART_TRANSMITTER_DEMO)
      ) uart_core_inst (
          .clk(uart_clk),
          .rstn(uart_rstn),
          .din_start(),
          .din(),
          .din_busy(),
          .dout(),
          .dout_v(),
          .rx(uart_rx),
          .tx(uart_tx)
      );
    end
  endgenerate

endmodule

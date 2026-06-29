`resetall
`timescale 1ns / 1ps
`default_nettype none

module xc7a35t_top #(
    parameter integer LED_COUNT = 16
)(
    input  wire                 clk,
    output wire [LED_COUNT-1:0] led
);

    led_shift_reg #(
        .LED_COUNT(LED_COUNT)
    ) led_shift_reg_inst (
        .clk(clk),
        .led(led)
    );

endmodule

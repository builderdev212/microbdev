`resetall
`timescale 1ns / 1ps
`default_nettype none

module tb_uart_transmitter;

    localparam integer CLK_RATE  = 96_000_000;
    localparam integer BAUD_RATE = 12_000_000;

    reg clk;
    reg rstn;

    reg start;
    reg [7:0] din;

    wire busy;
    wire tx;

    uart_transmitter #(
        .CLK_RATE(CLK_RATE),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .din(din),
        .busy(busy),
        .tx(tx)
    );

    // 96 MHz clock
    initial begin
        clk = 0;
        forever #5.208 clk = ~clk;
    end

    initial begin
        rstn  = 0;
        start = 0;
        din   = 8'h00;

        repeat (10) @(posedge clk);

        rstn = 1;

        repeat (10) @(posedge clk);

        // Send 0xA5
        din = 8'hA5;
        start = 1;

        @(posedge clk);
        start = 0;

        // Wait until transmission completes
        wait (!busy);

        #500;

        $finish;
    end

endmodule
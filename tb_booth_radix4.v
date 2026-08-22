`timescale 1ns/1ps

module tb_booth_radix4;
    reg [7:0] multiplicand, multiplier;
    reg clk, rst, start;
    wire [15:0] product;
    wire done;

    booth_radix4_multiplier #(8) uut (
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .clk(clk), .rst(rst), .start(start),
        .product(product), .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst = 1; start = 0;
        multiplicand = 8'd13;   // Example: 13
        multiplier   = -8'd6;   // Example: -6

        #10 rst = 0;
        #10 start = 1;
        #10 start = 0;

        wait(done);
        $display("Multiplicand = %d, Multiplier = %d", $signed(multiplicand), $signed(multiplier));
        $display("Product = %d", $signed(product));
        $finish;
    end
endmodule

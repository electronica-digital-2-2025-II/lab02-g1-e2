`include "shifter4b.v"
`timescale 1ns/1ps
module tb_shifter4;
    reg  [3:0] A;
    reg  [1:0] B;
    wire [3:0] Y;

    // DUT
    shifter4_logical_left dut (.A(A), .B(B), .Y(Y));

    initial begin
        $dumpfile("shifter4.vcd");
        $dumpvars(0, tb_shifter4);

        // Probe cases
        A = 4'b1011; B = 2'd0; #5;   // expect 1011
        B = 2'd1;         #5;        // expect 0101
        B = 2'd2;         #5;        // expect 0010
        B = 2'd3;         #5;        // expect 0001

        A = 4'b0101; B = 2'd1; #5;   // expect 0010
        A = 4'b1111; B = 2'd3; #5;   // expect 0001
        A = 4'b0001; B = 2'd2; #5;   // expect 0000

        $finish;
    end
endmodule

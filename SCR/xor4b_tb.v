`include "xor4b.v"
`timescale 1ns/1ps

module xor1_tb;
    reg  a, b;
    wire y;

    // DUT
    xor4b dut (.A(a), .B(b), .Y(y));

    // VCD for GTKWave
    initial begin
        $dumpfile("xor4b_tb.vcd");
        $dumpvars(0, xor1_tb);
    end

    // (Optional) Console probe
    initial begin
        $display(" t(ns) | a b | y");
        $monitor("%6t | %b %b | %b", $time, a, b, y);
    end

    // Probe cases
    initial begin
        a = 0; b = 0; #5;   // 0 ^ 0 -> 0
        a = 0; b = 1; #5;   // 0 ^ 1 -> 1
        a = 1; b = 0; #5;   // 1 ^ 0 -> 1
        a = 1; b = 1; #5;   // 1 ^ 1 -> 0
        $finish;
    end
endmodule
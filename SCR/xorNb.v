module xor1 (
    input  wire a,
    input  wire b,
    output wire y
);
    assign y = a ^ b;  
endmodule

/*
For N bits

module xorn #(
    parameter N = 8
) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire [N-1:0] y
);
    assign y = a ^ b;
endmodule
*/
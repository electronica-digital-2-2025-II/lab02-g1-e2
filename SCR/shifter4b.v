module shifter4_left (
    input  wire [3:0] A,
    input  wire [1:0] B,   // shift amount: 0..3
    output wire [3:0] Y
);
    assign Y = A << B;     
endmodule
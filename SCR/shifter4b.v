// shifter4_logical_right.v
module shifter4_logical_left (
    input  wire [3:0] A,
    input  wire [1:0] B,   // shift amount: 0..3
    output wire [3:0] Y
);
    assign Y = A << B;     // logical right shift, zeros shift in
endmodule

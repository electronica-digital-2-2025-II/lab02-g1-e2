`include "sum4b.v"

module sub4b_signed (
    input  wire [3:0] A,
    input  wire [3:0] B,
    output wire [3:0] Y,         
    output wire Overflow      
);
  wire [3:0] Bx = ~B;  // Invert of B
  wire       Co;

  // Two’s-complement subtraction: A - B = A + (~B) + 1
  sum4b u_add(.A(A), .B(Bx), .Ci(1'b1), .S(Y), .Co(Co));

  // Signed overflow for subtraction:
  assign Overflow = (A[3] ^ B[3]) & (A[3] ^ Y[3]);
  
endmodule
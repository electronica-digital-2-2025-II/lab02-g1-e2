//`include "sum4b.v"

// sub4b_signed.v
module sub4b_signed (
    input  wire [3:0] A,
    input  wire [3:0] B,
    output wire [3:0] D,         // D = A - B  (mod 16)
    output wire       Overflow,  // signed two’s-complement overflow
    output wire       Negative,  // N flag = MSB of result
    output wire       Zero       // Z flag = (D == 0)
);
  wire [3:0] Bx = ~B;  // bitwise invert of B
  wire       Co;

  // Two’s-complement subtraction: A - B = A + (~B) + 1
  sum4b u_add(.A(A), .B(Bx), .Ci(1'b1), .S(D), .Co(Co));

  // Signed overflow for subtraction:
  assign Overflow = (A[3] ^ B[3]) & (A[3] ^ D[3]);
  // Helpful CPU-like flags:
  assign Negative = D[3];
  assign Zero     = (D == 4'b0000);
endmodule

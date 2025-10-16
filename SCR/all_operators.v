`include "subtraction4b.v"
`include "multiplier4b.v"
`include "shifter4b.v"
`include "xor4b.v"

module alu4 #(
    parameter N = 4,
    parameter M = 8
) (
    input  wire clk,
    input  wire rst,          
    input  wire init,         
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [2:0] opcode,       
    output reg  [7:0] Y,
    output reg overflow,
    output reg zero
);

    wire [3:0] sum4, diff4, xor4, shl4;
    wire [7:0] prod8;   // 8-bit product
    wire ovf_sub;       // from subtractor
    wire ovf_add;
    wire mul_done;

    // --- Instantiate operators ---
    sum4b u_add (.A(A[3:0]), .B(B[3:0]), .Ci(1'b0), .S(sum4), .Overflow(ovf_add));

    sub4b_signed u_sub (.A(A[3:0]), .B(B[3:0]), .Y(diff4), .Overflow(ovf_sub));

    xor4b u_xor (.A(A[3:0]), .B(B[3:0]), .Y(xor4));

    shifter4_left u_shl (.A(A[3:0]), .B(B[1:0]), .Y(shl4)); 

    // Start multiplier only when opcode==MUL
    wire init_mul = init & (opcode == 3'b100);
    multiplier u_mul (.clk(clk), .rst(rst), .init(init_mul), .A(A[3:0]), .B(B[3:0]), .Y(prod8), .done(mul_done));

    //wire ovf_sub = (A[N-1] != B[N-1]) && (diff4[N-1] != A[N-1]);
    wire ovf_mul = |prod8[7:4]; 

    // ---- Opcode-driven multiplexer (combinational) ----
    reg [7:0] y_sel;
    reg ovf_sel;
    always @* begin
        y_sel   = {8{1'b0}};
        ovf_sel = 1'b0;
        case (opcode)
            3'b000: begin y_sel = {4'b0000, sum4 }; ovf_sel = ovf_add; end
            3'b001: begin y_sel = {4'b0000, diff4}; ovf_sel = ovf_sub; end
            3'b010: begin y_sel = {4'b0000, xor4 }; ovf_sel = 1'b0;   end
            3'b011: begin y_sel = {4'b0000, shl4 }; ovf_sel = 1'b0;   end
            3'b100: begin y_sel = prod8;                 ovf_sel = ovf_mul; end
            default: begin y_sel = {8{1'b0}};            ovf_sel = 1'b0;    end
        endcase
    end

        // ---- Output registers ----
    // Non-MUL ops: capture on init. MUL: capture on mul_done.
    always @(posedge clk) begin
        if (rst) begin
            Y <= {8{1'b0}}; 
            overflow <= 1'b0; 
            zero <= 1'b1;
        end else begin
            if (opcode != 3'b100) begin
                if (init) begin
                    Y <= y_sel; 
                    overflow <= ovf_sel; 
                    zero <= (y_sel == {8{1'b0}});
                end
            end else begin
                if (mul_done) begin
                    Y <= prod8; overflow <= ovf_mul; zero <= (prod8 == {8{1'b0}});
                end
            end
        end
    end
endmodule
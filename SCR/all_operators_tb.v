`timescale 1ns/1ps
`include "all_operators.v"
// `default_nettype none  // (optional) enable to catch undeclared nets

module alu4_tb;

  // ===== Clock / reset =====
  reg clk = 0;
  always #5 clk = ~clk;   // 100 MHz

  reg rst;
  reg init;

  // ===== ALU interface =====
  reg  [3:0] A, B;
  reg  [2:0] opcode;

  wire [7:0] Y;
  wire       overflow;
  wire       zero;

  // ===== Device Under Test =====
  alu4 dut (
    .clk(clk),
    .rst(rst),
    .init(init),
    .A(A),
    .B(B),
    .opcode(opcode),
    .Y(Y),
    .overflow(overflow),
    .zero(zero)
  );

  // ===== Wave dump =====
  initial begin
    $dumpfile("alu4_tb.vcd");
    $dumpvars(0, alu4_tb);
  end

  // ===== Opcodes =====
  localparam [2:0] OP_ADD = 3'b000,
                   OP_SUB = 3'b001,
                   OP_XOR = 3'b010,
                   OP_SLL = 3'b011,
                   OP_MUL = 3'b100;

  // ===== Scoreboard =====
  integer tests  = 0;
  integer errors = 0;

  task check_outputs;
    input [7:0] expY;
    input       expV;
    input       expZ;
    input [79:0] tag;   // message label
  begin
    tests = tests + 1;
    if (Y !== expY || overflow !== expV || zero !== expZ) begin
      errors = errors + 1;
      $display("FAIL %-12s | Y=%02h exp=%02h | V=%0b exp=%0b | Z=%0b exp=%0b @ t=%0t",
               tag, Y, expY, overflow, expV, zero, expZ, $time);
    end else begin
      $display("PASS %-12s | Y=%02h V=%0b Z=%0b @ t=%0t", tag, Y, overflow, zero, $time);
    end
  end
  endtask

  // ===== Helpers to compute expectations (combinational) =====
  function [7:0] expY_nonmul;
    input [2:0] opc;
    input [3:0] a,b;
    reg   [3:0] low;
  begin
    case (opc)
      OP_ADD: low = (a + b);               // take low nibble implicitly
      OP_SUB: low = (a - b);
      OP_XOR: low = (a ^ b);
      OP_SLL: low = (a << b[1:0]);         // mask shift amount to 0..3
      default: low = 4'h0;
    endcase
    expY_nonmul = {4'b0000, low};
  end
  endfunction

  function       expV_nonmul;
    input [2:0] opc;
    input [3:0] a,b;
    reg   [3:0] low;
  begin
    case (opc)
      OP_ADD: begin
        low         = (a + b);
        expV_nonmul = (~(a[3]^b[3])) & (a[3]^low[3]);  // signed overflow, Ci=0
      end
      OP_SUB: begin
        low         = (a - b);
        expV_nonmul = (a[3]^b[3]) & (a[3]^low[3]);     // signed overflow
      end
      default: expV_nonmul = 1'b0;                     // XOR, SLL → no signed ovf
    endcase
  end
  endfunction

  function [7:0] expY_mul;
    input [3:0] a,b;
  begin
    expY_mul = a * b;    // full 8-bit product
  end
  endfunction

  function       expV_mul_unsigned4;
    input [7:0] p8;
  begin
    expV_mul_unsigned4 = |p8[7:4];  // overflow if upper nibble != 0
  end
  endfunction

  // ===== Driver tasks =====

  task run_and_check_nonmul;
    input [2:0] opc;
    input [3:0] a,b;
    reg   [7:0] EY;
    reg         EV, EZ;
  begin
    opcode = opc; A = a; B = b;

    // arm and capture on init
    @(posedge clk); init = 1'b1;
    @(posedge clk); init = 1'b0;   // ALU captures on this cycle

    // compute expectations
    EY = expY_nonmul(opc,a,b);
    EV = expV_nonmul(opc,a,b);
    EZ = (EY == 8'h00);

    // give one settling edge after capture (registered in DUT)
    @(posedge clk);
    check_outputs(EY, EV, EZ,
      (opc==OP_ADD) ? "ADD" :
      (opc==OP_SUB) ? "SUB" :
      (opc==OP_XOR) ? "XOR" : "SLL");
  end
  endtask

  task run_and_check_mul;
    input [3:0] a,b;
    reg   [7:0] EY;
    reg         EV, EZ;
  begin
    opcode = OP_MUL; A = a; B = b;

    // start multiply
    @(posedge clk); init = 1'b1;
    @(posedge clk); init = 1'b0;

    // wait for DUT's mul_done pulse, then sample next clk (registered outputs)
    @(posedge dut.mul_done);
    @(posedge clk);

    // expectations
    EY = expY_mul(a,b);
    EV = expV_mul_unsigned4(EY);
    EZ = (EY == 8'h00);

    check_outputs(EY, EV, EZ, "MUL");
  end
  endtask

  // ===== Stimulus =====
  initial begin
    // reset
    rst = 1'b1; init = 1'b0; opcode = OP_ADD; A = 4'd0; B = 4'd0;
    repeat (2) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);

    // --- ADD ---
    run_and_check_nonmul(OP_ADD, 4'sd7, 4'sd4);  // +7 + +4 = 11 (0x0B), V=0
    run_and_check_nonmul(OP_ADD, 4'sd7, 4'sd5);  // +7 + +5 = +12 (wrap), V=1

    // --- SUB ---
    run_and_check_nonmul(OP_SUB, 4'sd3, 4'sd7);  // 3 - 7 = -4 (0xC), V=0
    run_and_check_nonmul(OP_SUB, -6,     4'sd3); // -6 - 3 = -9 (wrap + V=1)

    // --- XOR ---
    run_and_check_nonmul(OP_XOR, 4'b1010, 4'b0110); // A^B = 0xC
    run_and_check_nonmul(OP_XOR, 4'b0101, 4'b0101); // A^A = 0x0 (Z=1)

    // --- SLL ---
    run_and_check_nonmul(OP_SLL, 4'b0011, 4'b0010); // 0x3 << 2 = 0xC
    run_and_check_nonmul(OP_SLL, 4'b1111, 4'b0011); // 0xF << 3 = 0x8

    // --- MUL ---
    run_and_check_mul(4'd9,  4'd7);   // 9*7  = 63  (0x3F),  V=1
    run_and_check_mul(4'd15, 4'd15);  // 15*15= 225 (0xE1),  V=1
    run_and_check_mul(4'd0,  4'd7);   // 0*7  = 0           , Z=1

    // report
    $display("\nRESULT: %0d tests, %0d errors", tests, errors);
    if (errors) begin
      $display("SOME TESTS FAILED");
    end else begin
      $display("ALL TESTS PASSED");
    end
    #20 $finish;
  end

endmodule
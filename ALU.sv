`timescale 1ns / 1ps

//`include "define.sv"
import ALUOps::*;

module ALU #(int N=32) (
  input       [N-1:0]  A,
  input       [N-1:0]  B,
  input  logic [4:0]   ALUOp,
  output logic         Flag,   // reg потому что тебе потребуется мультиплексор
  output logic [N-1:0]  Result  // описанный в case внутри always 
);                            // а в always, слева от "равно", всегда стоит reg

always_comb begin : ALU
    case (ALUOp)
        ADD: begin Result = A + B; Flag = 0; end
        SUB: begin Result = A - B; Flag = 0; end
        SLL: begin Result = A << B; Flag = 0; end
        SLT: begin Result = ($signed(A) < $signed(B)); Flag = 0; end
        SLTU: begin Result = A < B; Flag = 0; end
        XORR: begin Result = A ^ B; Flag = 0; end
        SRL: begin Result = A >> B; Flag = 0; end
        SRA:  begin Result = $signed(A) >>> B; Flag = 0; end
        ORR: begin Result = A | B; Flag = 0; end
        ANDD: begin Result = A & B; Flag = 0; end
        BEQ: begin Flag = (A == B); Result = 0; end
        BNE: begin Flag = (A != B); Result = 0; end
        BLT: begin Flag = ($signed(A) < $signed(B)); Result = 0; end
        BGE: begin Flag = $signed(A >= B); Result = 0; end
        BLTU: begin Flag = (A < B); Result = 0; end
        BGEU: begin Flag = (A >= B); Result = 0; end
        default: begin Result = 32'bx; Flag = 32'bx; end
    endcase
end

endmodule
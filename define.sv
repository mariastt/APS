`timescale 1ns / 1ps

package ALUOps; 

enum logic [4:0] {
    ADD  = 5'b0_0_000,
    SUB  = 5'b0_1_000,
    SLL  = 5'b0_0_001,
    SLT  = 5'b0_0_010,
    SLTU = 5'b0_0_011,
    XORR = 5'b0_0_100,
    SRL  = 5'b0_0_101,
    SRA  = 5'b0_1_101,
    ORR  = 5'b0_0_110,
    ANDD = 5'b0_0_111,
    BEQ  = 5'b1_1_000,
    BNE  = 5'b1_1_001,
    BLT  = 5'b1_1_100,
    BGE  = 5'b1_1_101,
    BLTU = 5'b1_1_110,
    BGEU = 5'b1_1_111
} aluops;

endpackage

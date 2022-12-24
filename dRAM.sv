`timescale 1ns / 1ps

module dRAM(
  input CLK,
  input logic WE,
  input logic [31:0] WD,
  input logic [31:0] A,
  output logic [31:0] RD
);

logic [31:0] dRAM [0:255]; // создаём память

assign RD = ((A >= 32'h68000000) & (A <= 32'h680003FC)) ? dRAM[A[9:2]] : 32'b0;

always @(posedge CLK) begin
      if (WE)
        dRAM[A[9:2]] <= WD;
      else
        dRAM[A[9:2]] <= dRAM[A[9:2]];     
      end

endmodule

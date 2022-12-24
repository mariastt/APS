`timescale 1ns / 1ps

module iROM #(
  int WIDTH = 32,
  int DEPTH = 256)
(
  input logic [31:0] A,
//  input logic [$clog2(DEPTH)-1:0] A_8, // 8 битный адрес
  output logic [WIDTH-1:0] RD
);   

logic [31:0] SRL_2;
assign SRL_2 = {2'b00, A[31:2]}; // сдвиг вправо(деление на 4), переход на пословную адресацию

logic [$clog2(DEPTH)-1:0] A_8; // 8 битный адрес
assign A_8 = SRL_2[7:0];

logic [WIDTH-1:0] ROM [0:DEPTH-1];

assign RD = ROM[A_8];

initial
  $readmemh("mem.txt", ROM);

endmodule


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2022 22:29:08
// Design Name: 
// Module Name: iROM_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module iROM_tb #(
int WIDTH = 32,
int DEPTH = 64
);

//logic [$clog2(DEPTH)-1:0] A;
logic [31:0] A;
logic [WIDTH-1:0] RD;
logic [7:0] A_8;
logic [WIDTH-1:0] ROM [0:DEPTH-1];

iROM dut (A, RD);

initial begin
  for (integer adr = 0; adr < 63; adr++) begin
    A = adr;
    if (RD != ROM[A_8]) 
      $display("BAD");
    #10;
  end
end

endmodule

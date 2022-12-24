`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.10.2022 22:38:31
// Design Name: 
// Module Name: risc_v_tb
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


module risc_v_tb();

logic CLK;
logic RST;

risc_v dut (.CLK100MHZ(CLK), .CPU_RESETN(RST));

always #10 CLK = ~ CLK;

initial begin 
  CLK = 1;
  RST = 0;
  #150;
  RST = 1;
end

endmodule

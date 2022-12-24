`timescale 1ns / 1ps

module RF(
    input                CLK,
    input  logic [4:0]   RA1, // адрес памяти, к которому нужно обратиться
    input  logic [4:0]   RA2, // read address
    input  logic [4:0]   WA, // write address
    input  logic [31:0]  WD3, // write data
    input  logic         WE,
    output logic [31:0]  RD1, // read data
    output logic [31:0]  RD2
    );
    
    logic [31:0] RAM [0:31]; // создаём память
    
    assign RD1 = (RA1 != 0) ? RAM[RA1] : 0;
    assign RD2 = (RA2 != 0) ? RAM[RA2] : 0;
    
    always @(posedge CLK) begin
      RAM[0] = 32'b0;
      if (WE && (WA != 0))
        RAM[WA] <= WD3;
      else
        RAM[WA] <= RAM[WA];     
      end
endmodule

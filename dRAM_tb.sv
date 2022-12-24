`timescale 1ns / 1ps

module dRAM_tb();
  
parameter PERIOD = 10;
logic CLK;
logic WE;
logic [31:0] WD;
logic [31:0] A;
logic [31:0] RD;
    
dRAM dut (CLK, WE, WD, A, RD);

always begin
  CLK = 1'b0;
  #(PERIOD/2) CLK = 1'b1;
  #(PERIOD/2);
end
    
initial begin
  int data;  
  for (integer i = 0; i < 255; i=i+4) begin
    @(posedge CLK); #1;
      data = $urandom();
      WE = 1'b1;
      WD = data;
      A = i;
        
    @(posedge CLK); #1;
      WE = 1'b0;
      A = i;
        
    @(posedge CLK); #1;
      if (RD != data)
        $display("Bad");
      else 
        $display("Good");
        end
	end			
  

endmodule

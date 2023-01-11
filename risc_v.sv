`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.10.2022 16:36:28
// Design Name: 
// Module Name: risc_v
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


module miriscv_core (
  input clk_i,
  input arstn_i,
  
  input  logic [31:0] instr_rdata_i,       // инструкция
  output logic [31:0] instr_addr_o,        // регистр счетчика команд PC
  input  logic [31:0] data_rdata_i,        // чтение из памяти
  output logic [31:0] data_wdata_o,        // запись данных в память
  output logic data_req_o,                 // enable ram
  output logic data_we_o,                  // 1 - write, 0 - read
  output logic [3:0] data_be_o,            // 8, 16, 32 word
  output logic [31:0] data_addr_o          // result on alu
    );

//logic [31:0] data_rdata_input;
//assign data_rdata_input = data_rdata_i;
logic [31:0] data_addr_out;
assign data_addr_o = data_addr_out;
logic en_pc;    
logic [31:0] PC;                  // регистр счетчика команд
assign instr_addr_o = PC;
logic jal_sel;                    // wire sel(jal) with or(jal)
logic jalr_o;                     // wire sel(jalr) with jalr_o
logic jal_o;                      // wire or(jal) with jal_o
logic [31:0] cons_sel;            // wire sel(branch) with sel(jal)
logic branch_o;                   // wire and(branch,comp) with branch_o
logic comp;                       // wire and(branch,comp) with alu_Flag
logic and_or;                     // wire and(branch,comp) with or(jal)

//logic [31:0] instr;               // инструкция
//assign instr_rdata_i = instr;
logic [31:0] imm_I;
assign imm_I = {{20{instr_rdata_i[31]}},instr_rdata_i[31:20]};
logic [31:0] imm_S;
assign imm_S = {{20{instr_rdata_i[31]}}, instr_rdata_i[31:25], instr_rdata_i[11:7]};
logic [31:0] imm_J;
assign imm_J = {{12{instr_rdata_i[31]}}, instr_rdata_i[19:12], instr_rdata_i[20], instr_rdata_i[30:21], 1'b0};
logic [31:0] imm_B;
assign imm_B = {{20{instr_rdata_i[31]}}, instr_rdata_i[7], instr_rdata_i[30:25], instr_rdata_i[11:8], 1'b0};

logic gpr_we_a_o;                 // wire WE3 for RF
logic [31:0] RD1;                 // wire RD1 for RF
logic [31:0] RD2;                 // wire RD2 for RF
logic [31:0] WD3;                 // WD3 for RF on sel
logic [4:0] RA1;                  // RA1 for RF
assign RA1 = instr_rdata_i[19:15];
logic [4:0] RA2;                  // RA2 for RF
assign RA2 = instr_rdata_i[24:20];
logic [4:0] WA;                   // WA for RF
assign WA = instr_rdata_i[11:7];

logic [1:0] ex_op_a_sel_o;        // sel a
logic [2:0] ex_op_b_sel_o;        // sel b
logic [4:0] alu_op_o;             // alu_op
logic [31:0] Result;              // result on alu
logic [31:0] A_sel;               // A on alu
logic [31:0] B_sel;               // B on alu

logic mem_we_o;                   // WE for dRAM
logic wb_src_sel_o;               // sel for dRAM
logic [31:0] RD;                  // RD for dRAM

logic illegal_instr_o;            // к подсистеме прерываний
logic mem_req_o;                  // висит в воздухе
logic [2:0] mem_size_o;                 // висит в воздухе

    
ALU alu     (.A(A_sel), 
             .B(B_sel), 
             .ALUOp(alu_op_o), 
             .Flag(comp), 
             .Result(Result));

RF rf       (.CLK(clk_i), 
             .RA1(RA1), 
             .RA2(RA2), 
             .WA(WA), 
             .WD3(WD3),
             .WE(gpr_we_a_o), 
             .RD1(RD1), 
             .RD2(RD2));
             
//iROM rom    (.A(PC), .RD(instr));  
    //dRAM ram    (.CLK(clk_i), .WE(mem_we_o), .WD(RD2), .A(Result), .RD(RD));

decoder dec (.fetched_instr_i(instr_rdata_i),
             .ex_op_a_sel_o(ex_op_a_sel_o),
             .ex_op_b_sel_o(ex_op_b_sel_o),
             .alu_op_o(alu_op_o), 
             .mem_req_o(mem_req_o),
             .mem_we_o(mem_we_o), 
             .mem_size_o(mem_size_o), 
             .gpr_we_a_o(gpr_we_a_o),
             .wb_src_sel_o(wb_src_sel_o), 
             .illegal_instr_o(illegal_instr_o), 
             .branch_o(branch_o),
             .jal_o(jal_o), .jalr_o(jalr_o));
             
miriscv_lsu lsu (.clk_i(clk_i),
                 .arstn_i(arstn_i), 
                 .lsu_addr_i(Result), 
                 .lsu_we_i(mem_we_o),
                 .lsu_size_i(mem_size_o),
                 .lsu_data_i(RD2),
                 .lsu_req_i(mem_req_o),
                 .lsu_stall_req_o(en_pc),
                 .lsu_data_o(RD),
                 .data_rdata_i(data_rdata_i), 
                 .data_req_o(data_req_o), 
                 .data_we_o(data_we_o), 
                 .data_be_o(data_be_o),
                 .data_addr_o(data_addr_out),
                 .data_wdata_o(data_wdata_o));

assign and_or = comp & branch_o;
assign jal_sel = jal_o | and_or;
assign cons_sel = (branch_o == 1'b0) ? imm_J : imm_B;
               
assign WD3 = (wb_src_sel_o == 1'b1) ? RD : Result;

// асинхронный сброс   
always_ff @(posedge clk_i or negedge arstn_i) 
begin
  if (!arstn_i) 
     PC <= 0;
  else begin
     if (en_pc) 
         PC <= PC + 0;
     else
         case (jalr_o)
           1'b1: PC <= RD1 + imm_I;
           1'b0: case (jal_sel)
                1'b0: PC <= PC + 32'd4;
                1'b1: PC <= PC + cons_sel; 
              endcase
         endcase
  end
end

always_comb begin
         case (ex_op_a_sel_o)
           2'd0: A_sel <= RD1;
           2'd1: A_sel <= PC;
           default: A_sel <= 32'd0;
         endcase
         
         case (ex_op_b_sel_o) 
           3'd0: B_sel <= RD2;
           3'd1: B_sel <= imm_I;
           3'd2: B_sel <= {instr_rdata_i[31:12], 12'b0};
           3'd3: B_sel <= imm_S;
           3'd4: B_sel <= 32'd4;
           default: B_sel <= 32'b0;
         endcase
       end

endmodule

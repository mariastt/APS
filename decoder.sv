`timescale 1ns / 1ps

`include "./defines_riscv.v"

module decoder(
  input       [31:0]  fetched_instr_i,
  output  logic [1:0]   ex_op_a_sel_o,      // выходы сделаны регистрами,
  output  logic [2:0]   ex_op_b_sel_o,      // потому что всЄ устройство 
  output  logic [4:0]   alu_op_o,           // будет комбинационной схемой
  output  logic         mem_req_o,          // описанной внутри блока 
  output  logic         mem_we_o,           // always, а слева от знака равно
  output  logic [2:0]   mem_size_o,         // внутри always должны сто€ть
  output  logic         gpr_we_a_o,         // всегда только регистры,
  output  logic         wb_src_sel_o,       // даже если в итоге схема
  output  logic         illegal_instr_o,    // превратитс€ в
  output  logic         branch_o,           // комбинационно устройство
  output  logic         jal_o,              // без пам€ти
  output  logic         jalr_o              // 
    );

logic [6:0] func7;
assign func7 = fetched_instr_i[31:25];
logic [2:0] func3;
assign func3 = fetched_instr_i[14:12];
                   
always @ * begin   
  case (fetched_instr_i[1:0]) 
    2'b11: illegal_instr_o = 1'b0;
    default: illegal_instr_o = 1'b1;
  endcase

  case (fetched_instr_i[6:2])
    `OP_OPCODE:       begin
                        gpr_we_a_o = 1'b1;
                        ex_op_a_sel_o = `OP_A_RS1;
                        ex_op_b_sel_o = `OP_B_RS2;
                        mem_we_o = 1'b0;              // неважно
                        mem_req_o = 1'b0;             // не обращаемс€ к пам€ти
                        mem_size_o = 3'b0;          // неважно
                        wb_src_sel_o = `WB_EX_RESULT; // результат с алу
                        branch_o = 1'b0; 
                        jal_o = 1'b0;  
                        jalr_o = 1'b0; 
//                        alu_op_o = alu_op;
                        case (func7)
                          7'h0:     case (func3)
                                      3'h0: alu_op_o = `ALU_ADD;
                                      3'h4: alu_op_o = `ALU_XOR;
                                      3'h6: alu_op_o = `ALU_OR;
                                      3'h7: alu_op_o = `ALU_AND;
                                      3'h1: alu_op_o = `ALU_SLL;
                                      3'h5: alu_op_o = `ALU_SRL;
                                      3'h2: alu_op_o = `ALU_SLTS;
                                      3'h3: alu_op_o = `ALU_SLTU;
                                      default: illegal_instr_o = 1'b1;
                                    endcase
                                    
                          7'h20:    case (func3)
                                      3'h0: alu_op_o = `ALU_SUB;
                                      3'h5: alu_op_o = `ALU_SRA;
                                      default: illegal_instr_o = 1'b1;
                                    endcase
                          default: illegal_instr_o = 1'b1;
                        endcase
                      end
                      
    `OP_IMM_OPCODE:   begin
                        gpr_we_a_o = 1'b1;
//                        alu_op_o = alu_op_i;
                        ex_op_a_sel_o = `OP_A_RS1;
                        ex_op_b_sel_o = `OP_B_IMM_I;
                        mem_we_o = 1'b0;              // неважно
                        mem_req_o = 1'b0;             // не обращаемс€ к пам€ти
                        mem_size_o = 3'b0;            // неважно
                        wb_src_sel_o = `WB_EX_RESULT; // результат с алу
                        branch_o = 1'b0; 
                        jal_o = 1'b0; 
                        jalr_o = 1'b0; 
                        case (func3)
                          3'h0: alu_op_o = `ALU_ADD;
                          3'h4: alu_op_o = `ALU_XOR;
                          3'h6: alu_op_o = `ALU_OR;
                          3'h7: alu_op_o = `ALU_AND;
                          
                          3'h1: case (func7)
                                  7'h0: alu_op_o = `ALU_SLL;
                                  default: illegal_instr_o = 1'b1;
                                endcase
                                
                          3'h5: case (func7)
                                  7'h0: alu_op_o = `ALU_SRL;
                                  7'h20: alu_op_o = `ALU_SRA;
                                  default: illegal_instr_o = 1'b1;
                                endcase
                                
                          3'h2: alu_op_o = `ALU_SLTS;
                          3'h3: alu_op_o = `ALU_SLTU;
                          default: illegal_instr_o = 1'b1;
                        endcase
                      end
                      
    `LUI_OPCODE:      begin
                        gpr_we_a_o = 1'b1;
                        alu_op_o = `ALU_ADD;
                        ex_op_a_sel_o = `OP_A_ZERO;
                        ex_op_b_sel_o = `OP_B_IMM_U;
                        mem_we_o = 1'b0;              // неважно
                        mem_req_o = 1'b0;             // не обращаемс€ к пам€ти
                        mem_size_o = 3'b0;          // неважно
                        wb_src_sel_o = `WB_EX_RESULT; // результат с алу
                        branch_o = 1'b0;
                        jal_o = 1'b0; 
                        jalr_o = 1'b0;
                      end
                      
    `LOAD_OPCODE:     begin
                        gpr_we_a_o = 1'b1;
                        alu_op_o = `ALU_ADD;
                        ex_op_a_sel_o = `OP_A_RS1;
                        ex_op_b_sel_o = `OP_B_IMM_I;
                        mem_we_o = 1'b0; 
                        mem_req_o = 1'b1;            // любое обращение к пам€ти
//                        mem_size_o = mem_size_i;
                        wb_src_sel_o = `WB_LSU_DATA; // результат с алу
                        branch_o = 1'b0; 
                        jal_o = 1'b0;
                        jalr_o = 1'b0; 
                        case (func3)
                          3'h0: mem_size_o = `LDST_B;
                          3'h1: mem_size_o = `LDST_H;
                          3'h2: mem_size_o = `LDST_W;
                          3'h4: mem_size_o = `LDST_BU;
                          3'h5: mem_size_o = `LDST_HU;
                          default: illegal_instr_o = 1'b1;
                        endcase
                      end
                      
    `STORE_OPCODE:    begin
                        gpr_we_a_o = 1'b0;
                        alu_op_o = `ALU_ADD;
                        ex_op_a_sel_o = `OP_A_RS1;
                        ex_op_b_sel_o = `OP_B_IMM_S;
                        mem_we_o = 1'b1;
                        mem_req_o = 1'b1; 
//                        mem_size_o = mem_size_s;
                        wb_src_sel_o = 1'b0;        // неважно
                        branch_o = 1'b0; 
                        jal_o = 1'b0; 
                        jalr_o = 1'b0;
                        case (func3)
                          3'h0: mem_size_o = `LDST_B;
                          3'h1: mem_size_o = `LDST_H;
                          3'h2: mem_size_o = `LDST_W;
                          default: illegal_instr_o = 1'b1;
                        endcase
                      end
    
    `BRANCH_OPCODE:   begin
                        gpr_we_a_o = 1'b0;
//                        alu_op_o = alu_op_b;
                        ex_op_a_sel_o = `OP_A_RS1;
                        ex_op_b_sel_o = `OP_B_RS2;
                        mem_we_o = 1'b0;            // неважно
                        mem_req_o = 1'b0; 
                        mem_size_o = 3'b0;        // неважно
                        wb_src_sel_o = 1'b0;        // неважно
//                        branch_o = branch; 
                        jal_o = 1'b0; 
                        jalr_o = 1'b0; 
                        case (func3)
                          3'h0: begin
                                  alu_op_o = `ALU_EQ;
                                  branch_o = 1'b1;
                                end
                          3'h1: begin
                                  alu_op_o = `ALU_NE;
                                  branch_o = 1'b1;
                                end       
                          3'h4: begin
                                  alu_op_o = `ALU_LTS;
                                  branch_o = 1'b1;
                                end 
                          3'h5: begin
                                  alu_op_o = `ALU_GES;
                                  branch_o = 1'b1;
                                end
                          3'h6: begin
                                  alu_op_o = `ALU_LTU;
                                  branch_o = 1'b1;
                                end
                          3'h7: begin
                                  alu_op_o = `ALU_GEU;   
                                  branch_o = 1'b1;
                                end
                          default: illegal_instr_o = 1'b1;                     
                        endcase
                      end                     
                      
    `JAL_OPCODE:      begin
                        gpr_we_a_o = 1'b1;
                        alu_op_o = `ALU_ADD;
                        ex_op_a_sel_o = `OP_A_CURR_PC;
                        ex_op_b_sel_o = `OP_B_INCR;
                        mem_we_o = 1'b0;              // неважно
                        mem_req_o = 1'b0; 
                        mem_size_o = 3'b0;          // неважно
                        wb_src_sel_o = `WB_EX_RESULT; // результат с алу
                        branch_o = 1'b0; 
                        jal_o = 1'b1; 
                        jalr_o = 1'b0; 
                      end   
    
    `JALR_OPCODE:     begin
                        gpr_we_a_o = 1'b1;
                        alu_op_o = `ALU_ADD;
                        ex_op_a_sel_o = `OP_A_CURR_PC;
                        ex_op_b_sel_o = `OP_B_INCR;
                        mem_we_o = 1'b0;              // неважно
                        mem_req_o = 1'b0; 
                        mem_size_o = 3'b0;          // неважно
                        wb_src_sel_o = `WB_EX_RESULT; // результат с алу
                        branch_o = 1'b0;
                        jal_o = 1'b0; 
//                        jalr_o = jalr; 
                        case (func3)
                          3'h0: jalr_o = 1'b1;
                          default: illegal_instr_o = 1'b1;
                        endcase
                      end
    
    `AUIPC_OPCODE:    begin
                        gpr_we_a_o = 1'b1;
                        alu_op_o = `ALU_ADD;
                        ex_op_a_sel_o = `OP_A_CURR_PC;
                        ex_op_b_sel_o = `OP_B_IMM_U;
                        mem_we_o = 1'b0;              // неважно
                        mem_req_o = 1'b0; 
                        mem_size_o = 3'b0;          // неважно
                        wb_src_sel_o = `WB_EX_RESULT; // результат с алу
                        branch_o = 1'b0;              // неважно
                        jal_o = 1'b0;                 // неважно 
                        jalr_o = 1'b0; 
                      end
    
    `MISC_MEM_OPCODE: begin
                        gpr_we_a_o = 1'b0;
                        alu_op_o = `ALU_ADD;
                        ex_op_a_sel_o = `OP_A_RS1;
                        ex_op_b_sel_o = `OP_B_IMM_I;
                        mem_we_o = 1'b0;              // неважно
                        mem_req_o = 1'b0; 
                        mem_size_o = 3'b0;          // неважно
                        wb_src_sel_o = `WB_EX_RESULT; // результат с алу
                        branch_o = 1'b0; 
                        jal_o = 1'b0; 
                        jalr_o = 1'b0; 
                        illegal_instr_o = !(fetched_instr_i[1] & fetched_instr_i[0]);
                      end
    
    `SYSTEM_OPCODE:   begin
                        gpr_we_a_o = 1'b0;
                        alu_op_o = `ALU_ADD;
                        ex_op_a_sel_o = `OP_A_RS1;
                        ex_op_b_sel_o = `OP_B_IMM_I;
                        mem_we_o = 1'b0;              // неважно
                        mem_req_o = 1'b0; 
                        mem_size_o = 3'b0;          // неважно
                        wb_src_sel_o = `WB_EX_RESULT; // результат с алу
                        branch_o = 1'b0;
                        jal_o = 1'b0; 
                        jalr_o = 1'b0; 
                        illegal_instr_o = !(fetched_instr_i[1] & fetched_instr_i[0]);
                      end
                      
    default: illegal_instr_o = 1'b1;
  endcase
end    
    
endmodule
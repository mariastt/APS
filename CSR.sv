`timescale 1ns / 1ps

`define MIE_ADDR 32'h304
`define MTVEC_ADDR 32'h305
`define MSCRATCH_ADDR 32'h340
`define MEPC_ADDR 32'h341
`define MCAUSE_ADDR 32'h342

module CSR(
    input clk_i,
    input  logic [2:0] op_i,       // операция над содержимым CSR
    input  logic [31:0] mcause_i,
    input  logic [31:0] PC,
    input  logic [11:0] A,       // address register = imm[11:0] in I-type instr
    input  logic [31:0] WD,      // data from RD1 (in RF)
    output logic [31:0] mie_o,
    output logic [31:0] mtvec_o,
    output logic [31:0] mepc_o,
    output logic [31:0] RD
    );
    
logic [31:0] mie_reg;
logic [31:0] mtvec_reg;
logic [31:0] mscratch_reg;
logic [31:0] mepc_reg;
logic [31:0] mcause_reg;

assign mie_o = mie_reg;
assign mtvec_o = mtvec_reg;
assign mepc_o = mepc_reg;
    
always @(*) begin

    case (A)
        `MIE_ADDR: RD <= mie_reg;
        `MTVEC_ADDR: RD <= mtvec_reg;
        `MSCRATCH_ADDR: RD <= mscratch_reg;
        `MEPC_ADDR: RD <= mepc_reg;
        `MCAUSE_ADDR: RD <= mcause_reg;
        default: RD <= 32'b0;
    endcase
    
end  

logic [31:0] write_data_reg;

always_comb begin
    case (op_i[1:0])
        2'd3: write_data_reg <= RD | WD;
        2'd2: write_data_reg <= RD & ~WD;
        2'd1: write_data_reg <= WD;
        2'd0: write_data_reg <= 32'b0;
    endcase
end

logic interruption;            // произошло прерывание
assign interruption = op_i[2];

always_ff @(posedge clk_i, posedge interruption) begin
    if (interruption) begin
        mepc_reg <= PC;
        mcause_reg <= mcause_i;
    end 
    else begin
        if (op_i[1] | op_i[0]) begin
            case (A)
                `MIE_ADDR: mie_reg <= write_data_reg;
                `MTVEC_ADDR: mtvec_reg <= write_data_reg;
                `MSCRATCH_ADDR: mscratch_reg <= write_data_reg;
                `MEPC_ADDR: mepc_reg <= write_data_reg;
                `MCAUSE_ADDR: mcause_reg <= write_data_reg;
                default: begin
                    mie_reg <= mie_reg;
                    mtvec_reg <= mtvec_reg;
                    mscratch_reg <= mscratch_reg;
                    mepc_reg <= mepc_reg;
                    mcause_reg <= mcause_reg;
                end
            endcase
        end
    end
end
    
endmodule

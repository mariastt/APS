`timescale 1ns / 1ps

`include "./defines_riscv.v"

module miriscv_lsu(

    input clk_i,   // �������������
    input arstn_i, // ����� ���������� ���������
    
    // core protocol
    input        [31:0] lsu_addr_i,       // �����, �� �������� ����� ����������
    input               lsu_we_i,         // 1 - ���� ����� �������� � ������ (���� ������, �� 0)
    input        [2:0]  lsu_size_i,       // ������ �������������� ������ (8,16,32-������ �����)
    input        [31:0] lsu_data_i,       // ������ ��� ������ � ������
    input               lsu_req_i,        // 1 - ���������� � ������ (� ��� ������, � ��� ������)
    output logic        lsu_stall_req_o,  // ��� ���������� ������ !enable pc. � 1 - ������ ���� ��������������,
                                          // ���� ������ �� ����� ��������
    output logic [31:0] lsu_data_o,       // ������ ��������� �� ������
    
    // memory protocol
    input  logic [31:0] data_rdata_i,     // ����������� ������ �� ������
    output logic        data_req_o,       // 1 - ���������� � ������, ���� 1 �� � ��������� ����� ������/������. �������� ������ � ������� �������
    output logic        data_we_o,        // ��� �������. 1 - ��� ������ �� ������, 0 - �� ������
    output logic [3:0]  data_be_o,        // � ����� ������ ����� ���� ��������� � ������
    output logic [31:0] data_addr_o,      // �����, �� �������� ���� ���������
    output logic [31:0] data_wdata_o      // ������, ������� ��������� ��������
    );
 
logic stall_condition = 1;       
  
always @(*)
  begin
    if(lsu_we_i == 1'b1 && lsu_req_i == 1'b1)       // ������ � ������
      begin
        data_req_o <= 1;                            // ������� ������� � ������
        data_we_o <= 1;                             // ������ �� ������
        data_addr_o <= lsu_addr_i;                  // ����������� ������
//        lsu_stall_req_o <= 1;
         
        case (lsu_size_i)
          `LDST_B:  begin
                            data_wdata_o <= { 4{lsu_data_i[7:0]} };
                            case (lsu_addr_i[1:0])
                                2'b00 :  data_be_o <= 4'b0001;
                                2'b01 :  data_be_o <= 4'b0010;
                                2'b10 :  data_be_o <= 4'b0100;
                                2'b11 :  data_be_o <= 4'b1000;
                                default: data_be_o <= 4'b0000; 
                            endcase
                    end
                    
          `LDST_H: begin
                            data_wdata_o <= { 2{lsu_data_i[15:0]} };
                            case (lsu_addr_i[1:0])
                                2'b00 :  data_be_o <= 4'b0011;
                                2'b10 :  data_be_o <= 4'b1100;
                                default: data_be_o <= 4'b0000; 
                            endcase
                    end
                    
          `LDST_W: begin
                            data_wdata_o <= lsu_data_i[31:0];
                            case (lsu_addr_i[1:0])
                                2'b00 :  data_be_o <= 4'b1111;
                                default: data_be_o <= 4'b0000; 
                            endcase
                    end
           
          default: data_be_o <= 4'b0000; 
        endcase
      end
      
      
    else if (lsu_we_i == 1'b0 && lsu_req_i == 1'b1)    // ������ �� ������
      begin
        data_req_o <= 1;                            // ������� ������� � ������
        data_we_o <= 0;                             // ������
        data_addr_o <= lsu_addr_i;                  // ����������� ������
//        lsu_stall_req_o <= 1;
        
        case (lsu_size_i)
          `LDST_B:  
                    case (lsu_addr_i[1:0])
                        2'b00 :  lsu_data_o <= { {24{data_rdata_i[7]}}, data_rdata_i[7:0] };
                        2'b01 :  lsu_data_o <= { {24{data_rdata_i[15]}}, data_rdata_i[15:8] };  
                        2'b10 :  lsu_data_o <= { {24{data_rdata_i[23]}}, data_rdata_i[23:16] };
                        2'b11 :  lsu_data_o <= { {24{data_rdata_i[31]}}, data_rdata_i[31:24] };
                        default: lsu_data_o <= 32'b0;
                    endcase
                    
          `LDST_H:
                    case (lsu_addr_i[1:0])
                        2'b00 :  lsu_data_o <= { {16{data_rdata_i[15]}}, data_rdata_i[15:0] };
                        2'b10 :  lsu_data_o <= { {16{data_rdata_i[31]}}, data_rdata_i[31:16] };
                        default: lsu_data_o <= 32'b0;
                    endcase
                    
          `LDST_W:
                    case (lsu_addr_i[1:0])
                        2'b00 :  lsu_data_o <= data_rdata_i[31:0];
                        default: lsu_data_o <= 32'b0;
                    endcase
                    
          `LDST_BU:
                    case (lsu_addr_i[1:0])
                        2'b00 :  lsu_data_o <= { {24{data_rdata_i[7]}}, data_rdata_i[7:0] };
                        2'b01 :  lsu_data_o <= { {24{data_rdata_i[15]}}, data_rdata_i[15:8] };  
                        2'b10 :  lsu_data_o <= { {24{data_rdata_i[23]}}, data_rdata_i[23:16] };
                        2'b11 :  lsu_data_o <= { {24{data_rdata_i[31]}}, data_rdata_i[31:24] };
                        default: lsu_data_o <= 32'b0;
                    endcase
                    
          `LDST_HU: 
                    case (lsu_addr_i[1:0])
                        2'b00 :  lsu_data_o <= { {16{data_rdata_i[15]}}, data_rdata_i[15:0] };
                        2'b10 :  lsu_data_o <= { {16{data_rdata_i[31]}}, data_rdata_i[31:16] };
                        default: lsu_data_o <= 32'b0;
                    endcase 
                    
          default: lsu_data_o <= 32'b0;
        endcase
      end
      
      else begin
        data_req_o <= 0;                          
        data_we_o <= 0;  
//        lsu_stall_req_o <= 0;
      end
  end
    
  always @(posedge clk_i or posedge arstn_i)
        begin
        if (!arstn_i || !stall_condition)
            stall_condition <= 1;
        else
            stall_condition <= !lsu_req_i;
        end 
        
    always @(*)
            lsu_stall_req_o <= stall_condition & lsu_req_i;    
    
endmodule

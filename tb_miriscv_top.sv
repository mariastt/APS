`timescale 1ns / 1ps

module tb_miriscv_top();

  parameter     HF_CYCLE = 2.5;       // 200 MHz clock
  parameter     RST_WAIT = 10;         // 10 ns reset
  parameter     RAM_SIZE = 512;       // in 32-bit words

  // clock, reset
  logic clk;
  logic rst_n;
  logic [31:0] int_req = 32'b0;
  logic [31:0] int_fin;

  always begin
    clk = 1'b0;
    #(HF_CYCLE);
    clk = 1'b1;
    #(HF_CYCLE);
  end

//  logic [31:0] int_req = 32'b0;
//  logic [31:0] int_fin;
  logic prog_finished;

  miriscv_top #(
    .RAM_SIZE       ( RAM_SIZE),
    .RAM_INIT_FILE  ( "mem.txt" )

  ) dut (
    .clk_i    ( clk   ),
    .rst_n_i  ( rst_n ),
    .int_req_i(int_req),
    .int_fin_o(int_fin),

    .core_prog_finished(prog_finished)
  );
  
  
  // если прерывание обработано, обнуляем запрос на прерывание
  always @(posedge clk)
    if(int_fin == int_req) 
        int_req <= 0;
        
  initial begin
    clk   = 1'b0;
    rst_n = 1'b0;
    #RST_WAIT;
    rst_n = 1'b1;
    #100;
    int_req = 32'h20;      // прерыание 5
    #400;
    int_req = 32'h80000;   // прерывание 19
  end
    
    

//  logic program_started;
//  int i;

//  initial begin
//    // вывод всех инструкций в памяти
//    i = 0;
//    while (dut.ram.mem[i] >= {32{1'b0}}) begin
//      $display("%d) mem = %h", i, dut.ram.mem[i]);
//      i++;
//    end

//    int_req = 0;         // сигнал запроса на прерывание
  
//    clk   = 1'b0;
//    rst_n = 1'b0;
//    #RST_WAIT;
//    rst_n = 1'b1;
//    #RST_WAIT;
//    program_started = 1'b1;
//    i = 0;

//    #100;  // wait for init CSR
    
//    while (!prog_finished) begin
//    i++;
//      if (!(i % 137)) begin
//// выставляем на 5 входе запрос на прерывание
//        int_req[5] = 1'b1;
//// как прерывание будет обратано, убираем выполненный запрос    
//        @(posedge int_fin[5]);  
//        #(2 * HF_CYCLE);
//        int_req[5] = 1'b0;
//      end

//      if (!(i % 227)) begin
//        int_req[19] = 1'b1;
//        @(posedge int_fin[19]);
//        #(2 * HF_CYCLE);
//        int_req[19] = 1'b0;
//      end
//      #(HF_CYCLE);
//    end
////    $finish;
//  end

//  int debug_iter = 0;
//  always_ff @(posedge clk) begin
//    if (1 && program_started) begin
//      $display(
//          "\n%d) \nInstruction = %h\nIllegal instruction = %b\nWD3 = %h\nRD1 = %h\nRD2 = %h\nReset = %b\nProgram counter = %h\n!Enable PC = %b",
//      debug_iter, dut.core.instr_rdata_i, dut.core.illegal_instr_o, dut.core.WD3,
//          dut.core.RD1, dut.core.RD2, dut.core.arstn_i, dut.core.PC,
//          dut.core.en_pc);
          
//      $display(
//          "\nlsu_req_i = %h\nlsu_stall_req_o = %h\nlsu_data_o = %h\ndata_req_o = %h\ndata_we_o = %h\ndata_addr_o %h",
//          dut.core.lsu.lsu_req_i, dut.core.lsu.lsu_stall_req_o,
//          dut.core.lsu.lsu_data_o, dut.core.lsu.data_req_o,
//          dut.core.lsu.data_we_o, dut.core.lsu.data_addr_o);
//      debug_iter++;
//    end
//  end

//  always begin
//    #HF_CYCLE;
//    clk = ~clk;
//  end

endmodule

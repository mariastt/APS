`timescale 1ns / 1ps

module interrupt_controller(
    input clk_i,
    input arstn_i,
    input [31:0] mie_i,      // маска прерывания
    input [31:0] int_req,    // запрос на прерывание
    input INT_RST,           // передача сообщ на один из выходов int_fin, что прерывание обработано
    output [31:0] mcause_o,  // код причины прерывания
    output INT_o,            // сигнал, что произошло прерывание
    output [31:0] int_fin    // прерывание обработано
    );
    
logic [31:0] decoder_out;
logic [4:0] counter_clk;     // код причины прерывания, выход счётчика

// decoder    
always_comb begin
    decoder_out <= 32'b0;
    case (counter_clk)
        0: decoder_out[0] <= 1'b1;
        1: decoder_out[1] <= 1'b1;
        2: decoder_out[2] <= 1'b1;
        3: decoder_out[3] <= 1'b1;
        4: decoder_out[4] <= 1'b1;
        5: decoder_out[5] <= 1'b1;
        6: decoder_out[6] <= 1'b1;
        7: decoder_out[7] <= 1'b1;
        8: decoder_out[8] <= 1'b1;
        9: decoder_out[9] <= 1'b1;
        10: decoder_out[10] <= 1'b1;
        11: decoder_out[11] <= 1'b1;
        12: decoder_out[12] <= 1'b1;
        13: decoder_out[13] <= 1'b1;
        14: decoder_out[14] <= 1'b1;
        15: decoder_out[15] <= 1'b1;
        16: decoder_out[16] <= 1'b1;
        17: decoder_out[17] <= 1'b1;
        18: decoder_out[18] <= 1'b1;
        19: decoder_out[19] <= 1'b1;
        20: decoder_out[20] <= 1'b1;
        21: decoder_out[21] <= 1'b1;
        22: decoder_out[22] <= 1'b1;
        23: decoder_out[23] <= 1'b1;
        24: decoder_out[24] <= 1'b1;
        25: decoder_out[25] <= 1'b1;
        26: decoder_out[26] <= 1'b1;
        27: decoder_out[27] <= 1'b1;
        28: decoder_out[28] <= 1'b1;
        29: decoder_out[29] <= 1'b1;
        30: decoder_out[30] <= 1'b1;
        31: decoder_out[31] <= 1'b1;
        default: decoder_out <= 32'b0;
    endcase
end

logic [31:0] found_int;        // найдено незамаскированное прерывание
assign found_int = decoder_out & (mie_i & int_req);

assign int_fin = found_int & {32{INT_RST}};

logic found_int_or;
assign found_int_or = |found_int;     // свётрка or

logic int_reg;                        // регистр на выходе INT

always_ff @(posedge clk_i) begin
    int_reg <= INT_RST ? 1'b0 : found_int_or;
end

assign INT_o = int_reg ^ found_int_or;
    
logic counter_en_n;
assign counter_en_n = !found_int_or;  

logic counter_rst;
assign counter_rst = INT_RST;

always @(posedge clk_i or negedge arstn_i) begin
    if (!arstn_i) begin
        counter_clk <= 5'b0;
    end else if (counter_rst) begin
                counter_clk <= 5'b0;
    end else if (counter_en_n) begin
                counter_clk <= counter_clk + 1'b1;
             end
end

assign mcause_o = {{1'b1}, {26{1'b0}}, counter_clk};
    
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 09:48:12
// Design Name: 
// Module Name: disp_seg_hex
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
`include "macro.v"
/* 注意位宽问题！！！ an_o, seg_o 不要写成一位  */

module disp_seg_hex(
    input clk,
    input rstn,
    input [2:0] disp_mode,
    input [31:0] register_data,
    input [31:0] instr_data,
    input [31:0] dm_data,
    input [31:0] alu_data,
    output[7:0] an_o,
    output[7:0] seg_o
);
    // wire [31:0] disp_data;
    // always @(*) begin
    //     // 在 always 块里面, 由于里面含过程赋值
    //     case(disp_mode) // 没有':'
    //         `INSTR_DISPLAY: begin // 宏定义前面的' ` '
    //             disp_data = instr_data;
    //         end
    //         `REG_DISPLAY: begin
    //             disp_data = register_data;
    //         end
    //         `ALU_DISPLAY:begin
    //            disp_data = alu_data;
    //         end
    //         default: begin
    //             disp_data = 32'hff;
    //         end
    //     endcase
    // end
    wire [31:0] disp_data;

    assign disp_data = 
        (disp_mode == `INSTR_DISPLAY) ? instr_data :
        (disp_mode == `REG_DISPLAY) ? register_data :
        (disp_mode == `ALU_DISPLAY) ? alu_data : 32'hff;

    wire[3:0] digits[7:0];

    genvar i;
    for(i=0;i<8;i=i+1) begin
       assign digits[i] = disp_data[4*i+3:4*i]; // 4*i
    end

    reg [2:0] selector;
    always @(posedge clk) begin
       selector <= selector + 1; 
    end

    reg[7:0] reg_an_o, reg_seg_o;
    always @(selector) begin
       reg_an_o <= ~(8'b1 << selector); // 8'b1 !
       reg_seg_o <= seven_seg_translator(digits[selector]);
    end

    assign an_o = reg_an_o;
    assign seg_o = reg_seg_o;




    function [7:0] seven_seg_translator;
        input[3:0] num;
        case(num)
            4'b0000: seven_seg_translator = 8'hC0;
            4'b0001: seven_seg_translator = 8'hF9;
            4'b0010: seven_seg_translator = 8'hA4;
            4'b0011: seven_seg_translator = 8'hB0;
            4'b0100: seven_seg_translator = 8'h99;
            4'b0101: seven_seg_translator = 8'h92;
            4'b0110: seven_seg_translator = 8'h82;
            4'b0111: seven_seg_translator = 8'hF8;
            4'b1000: seven_seg_translator = 8'h80;
            4'b1001: seven_seg_translator = 8'h90;
            4'b1010: seven_seg_translator = 8'h88;
            4'b1011: seven_seg_translator = 8'h83;
            4'b1100: seven_seg_translator = 8'hC6;
            4'b1101: seven_seg_translator = 8'hA1;
            4'b1110: seven_seg_translator = 8'h86;
            4'b1111: seven_seg_translator = 8'h8E;
            default: seven_seg_translator = 8'hFF;
        endcase
    endfunction


endmodule

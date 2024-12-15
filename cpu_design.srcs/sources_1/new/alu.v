`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 10:19:38
// Design Name: 
// Module Name: alu
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


module alu(
        input signed [31:0] A,
        input signed [31:0] B,
        input [4:0] ALUop,
        output signed [31:0] C,
        output zero
);
    reg signed [31:0] reg_c;
    always @(*) begin
       case(ALUop)
        4'b0000: reg_c = A + B;
        4'b0001: reg_c = A - B;
        default: reg_c = 0;
       endcase
    end

    assign C = reg_c;
    assign zero = (C == 0);

endmodule

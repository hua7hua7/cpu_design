`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 09:17:07
// Design Name: 
// Module Name: register_file
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


module register_file(
        input clk,
        input rstn,
        input [4:0] rs1,
        input [4:0] rs2,
        input [4:0] rd,
        input reg_write,
        input [31:0] wdata,
        output[31:0] rs1_data,
        output [31:0] rs2_data,
        input [4:0] addr,
        output [31:0]  addr_data
    );

    reg[31:0] register_file[31:0];

    assign rs1_data = register_file[rs1];
    assign rs2_data = register_file[rs2];

    integer i;
    always @(posedge clk, negedge rstn) begin
       if(!rstn) begin
        for(i=0;i<32;i=i + 1) begin
            register_file[i] <= i;
        end
       end
       else if(reg_write && rd != 0) begin
        register_file[rd] <= wdata;
       end 
       else begin
        register_file[rd] <= register_file[rd];
       end
    end
    
    assign addr_data = register_file[addr];

endmodule

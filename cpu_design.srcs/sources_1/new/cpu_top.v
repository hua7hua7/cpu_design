`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 09:36:13
// Design Name: 
// Module Name: cpu_top
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

module cpu_top(
        input clk,
        input rstn,
        input [15:0] sw_i,
        output [7:0] disp_an_o,
        output [7:0] disp_seg_o
    );

    parameter ROM_SIZE = 12;
    parameter ALU_SIZE = 5;

    wire fast_disp; 
    wire[1:0] alu_op;
    wire [2:0] disp_mode;
    wire alu_pause = sw_i[0], instr_pause = sw_i[0], register_pause = sw_i[0];
    
    assign fast_disp = sw_i[15];
    assign disp_mode = sw_i[14:12];  
    assign alu_op = sw_i[2]; // 0 for add, 1 for sub

    wire[31:0] A, B, C;
    assign A = {{28{sw_i[10]}}, sw_i[10:7]}, B = {{28{sw_i[6]}},sw_i[6:3]};
    wire zero;
    alu u_alu(.A(A), .B(B), .C(C), .ALUop(alu_op), .zero(zero));

    wire clk_fast, clk_slow, clk_used, clk_disp;

    clk_divider #(.DIV_NUM(24)) div24 (.clk(clk), .clk_out(clk_fast)); // 
    clk_divider #(.DIV_NUM(27)) div27 (.clk(clk), .clk_out(clk_slow));
    clk_divider #(.DIV_NUM(12)) div12 (.clk(clk), .clk_out(clk_disp));

    assign clk_used = fast_disp ? clk_fast : clk_slow;

    wire[4:0] rs1, rs2, rd;
    wire[31:0] wdata;
    wire reg_write;

    assign rs1 = sw_i[10:8];
    assign rs2 = sw_i[7:5];
    assign rd = sw_i[10:8];
    assign wdata = sw_i[7:5];
    assign reg_write = sw_i[2];

    register_file u_rf(.clk(clk_used), .rstn(rstn), .rs1(rs1), .rs2(rs2), .rd(rd), .reg_write(reg_write), .wdata(wdata));

    wire[4:0] instr_addr;
    wire[31:0] instr_data;

    addr_controller #(.ADDR_SIZE(ROM_SIZE)) u_instr_addr(.clk(clk_used), .rstn(rstn), .addr_pause(instr_pause), .data_out(instr_addr));
    instr_memory u_im(.instr_addr(instr_addr), .instr_data(instr_data));

    wire [4:0] dm_addr;
    wire [31:0] dm_data;
    /* dist_mem_dm ...*/

    wire [$clog2(ALU_SIZE)-1:0] alu_addr;
    reg [31:0] alu_data;

    addr_controller #(.ADDR_SIZE(ALU_SIZE)) u_alu_addr(.clk(clk_used), .rstn(rstn), .addr_pause(alu_pause), .data_out(alu_addr));
    always@(*) begin
        case(alu_addr)
        0: alu_data = A;
        1: alu_data = B;
        2: alu_data = C;
        3: alu_data = {{31{1'b0}}, zero};
        4: alu_data = {32{1'b1}};
        endcase
    end

//数码管展示
    disp_seg_hex u_disp_seg_hex(.clk(clk_disp), .rstn(rstn), .disp_mode(disp_mode), .an_o(disp_an_o), .seg_o(disp_seg_o),
                                .register_data(register_data), .instr_data(instr_data), .alu_data(alu_data), .dm_data(dm_data));

endmodule

module clk_divider #(
    parameter DIV_NUM = 24
)
(
    input clk,
    output clk_out
);
reg[DIV_NUM:0] counter;
always @(posedge clk) begin 
   counter <= counter + 1; 
end 
assign clk_out = counter[DIV_NUM];
endmodule

module addr_controller #(
    parameter ADDR_SIZE = 20
  )(
    input clk,
    input rstn,
    input addr_pause,
    output reg [$clog2(ADDR_SIZE)-1:0] data_out
  );
  always @(posedge clk, negedge rstn)
  begin
    if(!rstn)
    begin
      data_out <= 0;
    end
    else if(addr_pause)
    begin
      data_out <= data_out;
    end
    else
    begin
      if(data_out == ADDR_SIZE - 1)
      begin
        data_out <= 0;
      end
      else
      begin
        data_out <= data_out + 1;
      end
    end
  end
endmodule
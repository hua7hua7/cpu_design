`timescale 1ns / 1ps  // 定义仿真时间单位和时间精度

`include "macro.v"  // 引入宏定义文件

module task_2_top(
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
    wire alu_pause = sw_i[1], instr_pause = sw_i[1], register_pause = sw_i[1];
    
    assign fast_disp = sw_i[15];
    assign disp_mode = sw_i[14:12];  
    assign alu_op = sw_i[2];  // sw[2] 控制加法(0)或减法(1)

    wire clk_fast, clk_slow, clk_used, clk_disp;

    //三个分频
    clk_divider #(.DIV_NUM(24)) div24 (.clk(clk), .clk_out(clk_fast)); 
    clk_divider #(.DIV_NUM(27)) div27 (.clk(clk), .clk_out(clk_slow));
    clk_divider #(.DIV_NUM(12)) div12 (.clk(clk), .clk_out(clk_disp));

    //选分频速度
    assign clk_used = fast_disp ? clk_fast : clk_slow;

    wire[4:0] rs1, rs2, rd;
    wire[31:0] wdata, rs1_data, rs2_data;
    wire reg_write;

    assign rs1 = sw_i[10:8];
    assign rs2 = sw_i[7:5];
    assign rd = sw_i[10:8];
    assign wdata = {{29{sw_i[7]}}, sw_i[7:5]};  // 通过开关决定写入数据
    assign reg_write = sw_i[3];  // sw[3] 控制寄存器堆写入有效

    register_file u_rf(
        .clk(clk_used), 
        .rstn(rstn), 
        .rs1(rs1), 
        .rs2(rs2), 
        .rd(rd), 
        .reg_write(reg_write), 
        .wdata(wdata),
        .rs1_data(rs1_data), 
        .rs2_data(rs2_data), 
        .addr(register_addr), 
        .addr_data(register_data)
    );

    wire[4:0] instr_addr;
    wire[31:0] instr_data;

    addr_controller #(.ADDR_SIZE(ROM_SIZE)) u_instr_addr(.clk(clk_used), .rstn(rstn), .addr_pause(instr_pause), .data_out(instr_addr));
    instr_memory u_im(.instr_addr(instr_addr), .instr_data(instr_data));

    wire [4:0] dm_addr;
    wire [31:0] dm_data;
    /* dist_mem_dm ...*/

    wire [$clog2(ALU_SIZE)-1:0] alu_addr;
    reg [31:0] alu_data;
    wire[31:0] A, B, C;  // A OP B = C
    assign A = rs1_data;
    assign B = rs2_data;
    wire zero;

    alu u_alu(
        .A(A), 
        .B(B), 
        .C(C), 
        .ALUop(alu_op), 
        .zero(zero)
    );

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
    
    wire[4:0] register_addr;
    addr_controller #(.ADDR_SIZE(32)) u_reg_addr(.clk(clk_used), .rstn(rstn), .addr_pause(alu_pause), .data_out(register_addr));
    
    wire[31:0] register_data;

    disp_seg_hex u_disp_seg_hex(
        .clk(clk_disp), 
        .rstn(rstn), 
        .disp_mode(disp_mode), 
        .an_o(disp_an_o), 
        .seg_o(disp_seg_o),
        .register_data(register_data), 
        .instr_data(instr_data), 
        .alu_data(alu_data), 
        .dm_data(dm_data)
    );

endmodule


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  J. Callenes
// 
// Create Date: 01/05/2019 12:17:57 AM
// Design Name: 
// Module Name: registerFile
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


module reg_file(
    input clk,
    input wr,

    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] rd_data,

    output logic [31:0] rs1_data, 
    output logic [31:0] rs2_data
    );

    localparam x0 = 0;
    typedef logic [31:0] u_word;

    u_word regs [31:0]; // 32 registers each 32 bits long

    always_comb begin
        if (rs1 == x0) 
            rs1_data = 0;
        else 
            rs1_data = regs[rs1];
    end

    always_comb begin
        if (rs2 == x0) 
            rs2_data = 0;
        else 
            rs2_data = regs[rs2];
    end
    
    always_ff@(posedge clk) 
    begin
        if(wr && rd != x0) 
            regs[rd] <= rd_data;
    end

 endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: J. Callenes
// 
// Create Date: 01/27/2019 08:37:11 AM
// Design Name: 
// Module Name: bram_dualport
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

//port 1 is read only (instructions - used in fetch stage)
//port 2 is read/write (data - used in writeback stage)

 module memory
    #(
        parameter ADDR_WIDTH = 15
        parameter DATA_WIDTH = 32 
    )

    ( 
        input clk,

        // Port A (Instruction)
        input a_rd,
        input [31:0] a_addr,
        output logic [31:0] a_data,
 
        // Port B (Data)
        input b_rd,
        input b_wr,
        input [31:0] b_addr,
        output logic [31:0] b_data,
    );

    // Signals
    logic s_rd_addr1;
    logic s_rd_addr2;
    logic s_wr_data;
    
    // Map 32-bit address to 15-bit address
    logic [ACTUAL_WIDTH-1:0] inst_addr, data_addr; 
    assign inst_addr = {addr1[ACTUAL_WIDTH-1:2],2'b0};
    assign data_addr = addr2[ACTUAL_WIDTH-1:0];
    
    // Raw memory block
    logic [7:0] mem [0:2**ACTUAL_WIDTH-1];
    
    // Initialize memory
    initial begin
        $readmemh("mem.txt", mem, 0, 2**ACTUAL_WIDTH-1);
    end 

endmodule
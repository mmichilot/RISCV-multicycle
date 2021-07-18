`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: J. Callenes
// 
// Create Date: 06/07/2018 04:21:54 PM
// Design Name: 
// Module Name: ProgCount
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


module prog_cntr(
    input clk,
    input rstn,
    input ld,
    input logic [31:0] data,
    output logic [31:0] count
    );
    
    always_ff @(posedge clk)
    begin
        if (rstn == 0)
            count <=  0;
        else if (ld == 1)
            count <= data;
    end
    
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Matthew Michilot
// 
// Create Date: 01/27/2019 08:37:11 AM
// Design Name: Instruction Memory (read-only)
// Module Name: rom
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

module rom
    #(
        parameter ADDR_WIDTH = 13, // 8K x 32 -> 32KB
        parameter DATA_WIDTH = 32
    )

    (
        input clk,

        input rd,
        input [ADDR_WIDTH-1:0] addr,
        
        output logic[DATA_WIDTH-1:0] dout
    );
    
    (* syn_romstyle="EBR" *)
    reg [DATA_WIDTH-1:0] mem [0:2**ADDR_WIDTH-1];

    // Initialize ROM
    initial begin
        $readmemh("mem.txt", mem, 0, 2**ADDR_WIDTH-1);
    end

    // Read
    always_ff @(posedge clk) begin
        if (rd)
            dout <= mem[addr];
    end

endmodule

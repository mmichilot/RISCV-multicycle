`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: J. Callenes, M. Michilot
// 
// Create Date: 01/27/2019 08:37:11 AM
// Design Name: OTTER Basic Memory
// Module Name: memory
// Project Name: OTTER CPU for OrangeCrab 
// Target Devices: OrangeCrab r0.2 (Lattice ECP5-25U)
// Tool Versions: 
// Description: Basic memory module for the OTTER CPU, utilizing the built-in
// block RAM on the OrangeCrab's ECP5-25U.
// 
// Dependencies: bram - Used to initialize, infer, and expose 
//                      Single-Port Block RAM w/ Byte Enable
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

 module bram
    #(
        parameter RAM_ADDR_WIDTH = 13, // 8K x 32 (32KB)
        parameter RAM_BUS_WIDTH = 32,
    )

    (
        input clk,
        input [3:0] we,
        input [RAM_ADDR_WIDTH-1:0] addr,
        input [RAM_BUS_WIDTH-1:0] data,
        output logic [RAM_BUS_WIDTH-1:0] out,
    );

    // Raw memory block
    (* syn_ramstyle="block_ram" *)
    logic [RAM_BUS_WIDTH-1:0] mem [0:2**RAM_ADDR_WIDTH-1];
    
    // Initialize memory
    initial begin
        $readmemh("mem.txt", mem, 0, 2**RAM_ADDR_WIDTH-1);
    end 

    integer i;
    always_ff @(posedge clk) begin

        // Read
        out <= mem[addr];

        // Write
        if (we) begin
            for (i = 0; i < 4; i++) begin
                if (we[i])
                    mem[addr][8*i +: 8] <= data[8*i +: 8];
            end
        end
    end
    
endmodule

module memory 
    #(
        parameter ADDR_WIDTH = 13;
        parameter BUS_WIDTH = 31;
    )

    (
        input clk,
        input [BUS_WIDTH-1:0] addr,
        input [BUS_WIDTH-1:0] data,
        output logic [BUS_WIDTH-1:0] out
    )


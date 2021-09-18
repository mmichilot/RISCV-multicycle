`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: M. Michilot
// 
// Create Date: 08/20/2021
// Design Name: Single-Port Block RAM w/ Byte Enable
// Module Name: bram
// Project Name: OTTER CPU
// Target Devices: OrangeCrab r0.2 (ECP5-25F)
// Tool Versions: 
// Description: Module to infer and initialize block RAM for ECP5 FPGAs
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
 module bram
    #(
        parameter RAM_ADDR_WIDTH = 13, // 8K x 32 (32KB)
        parameter RAM_BUS_WIDTH = 32
    ) (
        input clk,
        input rd,
        input [3:0] we,
        input [RAM_ADDR_WIDTH-1:0] addr,
        input [RAM_BUS_WIDTH-1:0] data,
        output logic [RAM_BUS_WIDTH-1:0] out
    );

    // Raw memory block
    (* syn_ramstyle="block_ram" *)
    logic [RAM_BUS_WIDTH-1:0] mem [0:2**RAM_ADDR_WIDTH-1];
    
    // Initialize memory
    initial begin
        $readmemh("../sw/build/mem.txt", mem, 0);
    end 

    integer i;
    always_ff @(posedge clk) begin

        // Read
        if (rd)
            out <= mem[addr];
      
        // Write
        if (we > 0) begin
            for (i = 0; i < 4; i++) begin
                if (we[i])
                    mem[addr][8*i +: 8] <= data[8*i +: 8];
            end
        end
    end
    
endmodule

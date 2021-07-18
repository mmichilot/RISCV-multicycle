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

// Read-only memory
module rom
    #(
        parameter ADDR_WIDTH = 13, // 8K x 32 (32KB)
        parameter DATA_WIDTH = 32
    )

    ( 
        input i_clk,
        input i_rst,

        // Wishbone Interface
        input [ADDR_WIDTH-1:0]        i_wb_addr,
        input [DATA_WIDTH-1:0]        i_wb_dat,
        input [3:0]                   i_wb_sel,
        input                         i_wb_we,
        input                         i_wb_cyc,
        input                         i_wb_stb,
        output logic [DATA_WIDTH-1:0] o_wb_dat,
        output logic                  o_wb_ack
        
    );

    // Convert byte address to word address for indexing memory
    logic [ADDR_WIDTH-1:0] addr;
    assign addr = ADDR_WIDTH'(i_wb_addr[ADDR_WIDTH-1:2]);
     
    // Raw memory block
    logic [DATA_WIDTH-1:0] mem [(1<<ADDR_WIDTH)-1:0];
    
    // Initialize memory
    initial begin
        $readmemh("otter_memory.mem", mem, 0, (1<<ADDR_WIDTH)-1);
    end

    always_ff @(posedge i_clk) begin
        if (i_rst)
            o_wb_ack <= 1'b0;
        else begin
            o_wb_ack <= 1'b0;

            if (i_wb_stb && i_wb_cyc && !o_wb_ack) begin
                o_wb_ack <= 1'b1;
                
                // Read
                o_wb_dat <= mem[addr];
            end
        end
    end

endmodule

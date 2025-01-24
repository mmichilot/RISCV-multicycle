`timescale 1ns / 1ps
`include "defs.svh"

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: J. Callenes, M. Michilot
//
// Create Date: 01/27/2019 08:37:11 AM
// Design Name: SRAM memory module
// Module Name: sram
// Project Name: OTTER CPU
// Target Devices: N/A
// Tool Versions:
// Description: SRAM used for memory
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module sram
    #(
        parameter SIZE_BYTES = 32_768,
        localparam NUM_WORDS = SIZE_BYTES/4,
        localparam ADDR_WIDTH = $clog2(SIZE_BYTES)
    ) (
        input clk,

        // Port A (Read-Only)
        input [31:0]        A_addr,
        input               A_read,
        output logic [31:0] A_rdata,
        output logic        A_ready,

        // Port B (Read/Write)
        input               B_read,
        input               B_write,
        input [3:0]         B_byte_en,
        input [31:0]        B_addr,
        input [31:0]        B_wdata,
        output logic [31:0] B_rdata,
        output logic        B_ready
    );

    // Raw memory block
    (* syn_ramstyle="block_ram" *)
    logic [31:0] mem [0:NUM_WORDS-1];

    // Port A (Read-Only)
    always_ff @(posedge clk) begin
        A_ready <= 0;
        if (A_read & ~A_ready) begin
            A_rdata <= mem[A_addr[ADDR_WIDTH-1:2]];
            A_ready <= 1;
        end
    end

    // Port B (Read/Write)
    always_ff @(posedge clk) begin
        B_ready <= 0;
        if (B_read & ~B_ready) begin
            B_rdata <= mem[B_addr[ADDR_WIDTH-1:2]];
            B_ready <= 1;
        end else if (B_write & ~B_ready) begin
            integer i;
            for (i = 0; i < 4; i++) begin
                if (B_byte_en[i])
                    mem[B_addr[ADDR_WIDTH-1:2]][8*i +: 8] <= B_wdata[8*i +: 8];
            end
            B_ready <= 1;
        end
    end

endmodule

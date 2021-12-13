`timescale 1ns / 1ps
`include "buses.svh"
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
// Interface: Wishbone
// Dependencies: bram - Used to initialize and infer
//                      single-port block RAM w/ Byte Enable.
//               wishbone_bus - Used to specify the bus implementation.
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module sram
    #(
        parameter ADDR_WIDTH = 15,
        parameter BUS_WIDTH = 32
    ) (
        wishbone_bus.secondary bus
    );

    //localparam MAX_ADDR = (2**ADDR_WIDTH)-1;
    localparam RAM_ADDR_WIDTH = ADDR_WIDTH-2;

    /* verilator lint_off UNUSED */
    enum logic [1:0] {
        BYTE = 2'b00,
        HALF = 2'b01,
        WORD = 2'b10
    } size_e;
    /* verilator lint_on UNUSED */

    // Signals
    logic [RAM_ADDR_WIDTH-1:0] s_addr;
    assign s_addr = bus.wb_adr[RAM_ADDR_WIDTH-1:2];
    //logic [3:0] s_we;
    //logic [1:0] byte_sel = bus.addr[1:0];

    // RAM Instantiation
    (* keep=1 *)
    (* keep_hierarchy=1 *)
    bram #(
        .RAM_ADDR_WIDTH (RAM_ADDR_WIDTH),
        .RAM_BUS_WIDTH  (BUS_WIDTH)
    ) ram (
        .clk    (bus.wb_clk_i),
        .rd     (!(bus.wb_we)),
        .we     (bus.wb_sel),
        .addr   (s_addr),
        .data   (bus.wdata),
        .out    (bus.rdata)
    );

    // assign s_addr = bus.addr[ADDR_WIDTH-1:2];

    // always_ff @(posedge clk) begin : addr_check
    //     bus.error <= 0;
 
    //     if (bus.addr > MAX_ADDR) // Address space 
    //         bus.error <= 1;
    //     else if (bus.size == WORD && bus.addr[1:0] != 2'b0) // Word boundary
    //         bus.error <= 1;
    //     else if (bus.size == HALF && bus.addr[0] != 0) // Half-word boundary
    //         bus.error <= 1;
    // end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: J. Callenes, M. Michilot
// 
// Create Date: 01/27/2019 08:37:11 AM
// Design Name: OTTER Basic Memory
// Module Name: memory
// Project Name: OTTER CPU
// Target Devices: N/A
// Tool Versions: 
// Description: Basic memory module for the OTTER CPU
// 
// Dependencies: bram - Used to initialize and infer
//                      single-port block RAM w/ Byte Enable.
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module memory 
    #(
        parameter ADDR_WIDTH = 13,
        parameter BUS_WIDTH = 32
    )

    (
        input clk,
        input [BUS_WIDTH-1:0] addr,
        input [BUS_WIDTH-1:0] data,
        output logic [BUS_WIDTH-1:0] out,

        input [1:0] size,
        input sign,
        output error
    );

    enum {
        BYTE = 2'b00,
        HALF = 2'b01,
        WORD = 2'b10
    } e_size;

    enum {
        SIGNED = 1'b0,
        UNSIGNED = 1'b1
    } e_sign;

    // Signals
    logic [ADDR_WIDTH-1:0] s_addr;
    logic [3:0] s_we;
    logic [BUS_WIDTH-1:0] s_out;

    // RAM Instantiation
    bram #(
        .RAM_ADDR_WIDTH(ADDR_WIDTH),
        .RAM_BUS_WIDTH(BUS_WIDTH)
    ) ram (
        .clk(clk),
        .we(s_we),
        .addr(s_addr),
        .data(data),
        .out(s_out)
    );

    // Map address to nearest word boundary
    assign s_addr = {addr[ADDR_WIDTH-1:2], 2'b0};

    // TODO: Address error checks

endmodule
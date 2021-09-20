`timescale 1ns / 1ps
`include "buses.svh"
`include "core.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: M. Michilot
// 
// Create Date: 08/20/2021
// Design Name:OTTER CPU
// Module Name: cpu
// Project Name: OTTER CPU
// Target Devices:
// Tool Versions: 
// Description: Contains the core, bus, and system peripherals
// 
// Dependencies: core, bus_matrix, csr
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module cpu (
    input clk,
    input rst,
    otter_bus.primary mem_bus
);

otter_bus core_bus();

core core(
    .clk (clk),
    .rst (rst),
    .bus (core_bus)
);

bus_matrix bus_matrix(
    .input_bus (core_bus),
    .mem_bus   (mem_bus)
);



endmodule

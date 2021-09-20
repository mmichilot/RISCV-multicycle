`timescale 1ns / 1ps
`include "buses.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: M. Michilot
// 
// Create Date: 08/20/2021
// Design Name: Bus Matrix
// Module Name: bus_matrix
// Project Name: OTTER CPU
// Target Devices:
// Tool Versions: 
// Description: Selects the proper bus to use, given an address
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module bus_matrix (
    otter_bus.secondary input_bus,
    otter_bus.primary   mem_bus
);

  /* verilator lint_off UNUSED */
enum logic [3:0] {
    MEMORY_0 = 4'h0,
    MEMORY_1 = 4'h1,
    MEMORY_2 = 4'h2,
    MEMORY_3 = 4'h3,
    SYSTEM_0 = 4'h4,
    SYSTEM_1 = 4'h5
} memoryMap_e;

logic [31:0] s_addr = input_bus.addr;
  /* verilator lint_on UNUSED */

always_comb begin
    mem_bus.wr = 0;
    mem_bus.rd = 0;
    mem_bus.size = 0;
    mem_bus.addr = 0;
    mem_bus.wdata = 0;
    input_bus.error = 0;
    input_bus.rdata = 0;

    /* verilator lint_off CASEINCOMPLETE */
    case (s_addr[31:28])
        MEMORY_0,MEMORY_1,MEMORY_2,MEMORY_3: begin
            mem_bus.wr  = input_bus.wr;
            mem_bus.rd  = input_bus.rd;
            mem_bus.size = input_bus.size;
            mem_bus.addr = input_bus.addr;
            mem_bus.wdata = input_bus.wdata;

            input_bus.error = mem_bus.error;
            input_bus.rdata = mem_bus.rdata;

        end

        SYSTEM_0,SYSTEM_1: begin
            
        end

    endcase
    /* verilator lint_on CASEINCOMPLETE */
end

endmodule

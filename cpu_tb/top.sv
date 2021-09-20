`timescale 1ns / 1ps
`include "buses.svh"
`include "memory.svh"
`include "cpu.svh"
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
module top (
    input clk,
    input rst
);

    otter_bus mem_bus(clk);

    (* keep=1 *)
    (* keep_hierarchy=1 *)
    cpu cpu(
        .clk     (clk     ),
        .rst     (rst     ),
        .mem_bus (mem_bus )
    );

    (* keep=1 *)
    (* keep_hierarchy=1 *)
    sram sram(
    	.bus (mem_bus )
    );
    
// Tracing for verilator
`ifdef VERILATOR
    // Set up tracing
    initial begin
       if($test$plusargs("trace") != 0) begin
           $display("[%0t] Tracing to logs/vlt_dump.vcd...\n", $time);
           $dumpfile("logs/vlt_dump.vcd");
           $dumpvars();
       end
       $display("[%0t] Module running...\n", $time);
    end
`endif

endmodule

`timescale 1ns / 1ps
`include "memory.svh"
`include "core.svh"
`include "sys_bus.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: M. Michilot
// 
// Create Date: 08/20/2021
// Design Name: Basic CPU Wrapper
// Module Name: top
// Project Name: OTTER CPU
// Target Devices:
// Tool Versions: 
// Description: Basic CPU Wrapper to be used with Verilator testbench
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top
    (
        input clk,
        input rst
    );

    sys_bus bus(clk);

// Buses are treated as a port for verilator
`ifdef VERILATOR

    core core(
        .rst    (rst), 
        .bus    (bus.primary)
    );

    memory memory(
        .bus    (bus.secondary)
    );

`else

    (* keep=1 *)
    (* keep_hierarchy=1 *)
    core core(bus.primary);
    assign core.rst = rst;

    (* keep=1 *)
    (* keep_hierarchy=1 *)
    memory memory(bus.secondary);
    
`endif


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

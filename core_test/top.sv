`timescale 1ns / 1ps
`include "memory.svh"
`include "core.svh"
`include "buses.svh"
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

    // Note: yosys throws warnings about interface signals being implicitly
    //       declared. If 'default_nettype none' is used, yosys throws an error
    //       instead.
    // Temp. Solution: Don't use 'default_nettype none' until issue is resolved
    // Issue: Currently OPEN on Yosys GitHub
    //       https://github.com/YosysHQ/yosys/issues/1053

    // (* keep=1 *)
    // (* keep_hierarchy=1 *)
    // core core(
    //     .bus(sysBus)
    // );


    // (* keep=1 *)
    // (* keep_hierarchy=1 *)
    // sram sram(
    //     .bus(sysBus)
    // );
    


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

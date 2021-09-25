`timescale 1ns / 1ps
`include "buses.svh"
`include "core.svh"
`include "memory.svh"

module top
    (
        input clk,
        input RX,

        output logic TX,

        output logic rgb_led0_r,
        output logic rgb_led0_g,
        output logic rgb_led0_b
    );

    // Signals
    logic cpu_clk, cpu_rst;

    assign rgb_led0_r = ~cpu_rst;
    assign rgb_led0_g = ~cpu_clk;
    assign rgb_led0_b = 1;

    otter_bus mem_bus();

    (* keep=1 *)
    (* keep_hierarchy=1 *)
    uart u_uart(
    	.clk     (clk     ),
        .RX      (RX      ),
        .TX      (TX      ),
        .cpu_clk (cpu_clk ),
        .cpu_rst (cpu_rst ),
        .bus_addr(mem_bus.addr),
        .bus_rdata(mem_bus.rdata),
        .bus_wdata(mem_bus.wdata)
    );

    
    (* keep=1 *)
    (* keep_hierarchy=1 *)
    core u_core(
        .rst (cpu_rst ),
        .clk (cpu_clk ),
        .bus (mem_bus )
    );
    

    (* keep=1 *)
    (* keep_hierarchy=1 *)
    sram sram(
        .clk (cpu_clk ),
    	.bus (mem_bus )
    );
    
endmodule

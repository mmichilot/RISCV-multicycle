`timescale 1ns / 1ps

// Note: yosys throws warnings about interface signals being implicitly
//       declared. If 'default_nettype none' is used, yosys throws an error
//       instead.
// Temp. Solution: Don't use 'default_nettype none' until issue is resolved
// Issue: Currently OPEN on Yosys GitHub
//       https://github.com/YosysHQ/yosys/issues/1053

module fpga_top
    (
        input clk,
        input rst_n,

        input logic external_int,

        // scope data memory bus
        output logic        probe_cyc,
        output logic        probe_stb,
        output logic        probe_we,
        output logic [3:0]  probe_sel,
        output logic [31:0] probe_adr,
        output logic [31:0] probe_dat_i,
        output logic [31:0] probe_dat_o,
        output logic        probe_ack
    );

    top soc (
        .clk,
        .rst_n,

        .external_int,

        .probe_cyc,
        .probe_stb,
        .probe_we,
        .probe_sel,
        .probe_adr,
        .probe_dat_i,
        .probe_dat_o,
        .probe_ack
    );

endmodule

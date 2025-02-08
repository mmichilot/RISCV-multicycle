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

        input logic external_int
    );

    top soc (
        .clk,
        .rst_n,

        .external_int
    );

endmodule

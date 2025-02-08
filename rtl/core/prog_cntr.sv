`timescale 1ns / 1ps

module prog_cntr(
    input clk,
    input rst_n,
    input ld,
    input logic [31:0] data,
    output logic [31:0] count
    );

    always_ff @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            count <= '0;
        else if (ld)
            count <= data;
    end

endmodule

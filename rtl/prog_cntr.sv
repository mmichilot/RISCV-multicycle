`timescale 1ns / 1ps

module prog_cntr #(
        parameter RESET_ADDR = 32'h8000_0000
    )(
        input clk,
        input rst_n,
        input ld,
        input logic [31:0] data,
        output logic [31:0] count
    );

    always_ff @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            count <= RESET_ADDR;
        else if (ld)
            count <= data;
    end

endmodule

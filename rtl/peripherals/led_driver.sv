`timescale 1ns/1ps

module led_driver (
    input clk,
    input rst_n,

    // Wishbone interface
    input logic         wb_cyc_i,
    input logic         wb_stb_i,
    input logic         wb_we_i,
    output logic        wb_ack_o,
    input  logic [3:0]  wb_sel_i,
    input  logic [1:0]  wb_adr_i,
    input  logic [31:0] wb_dat_i,
    output logic [31:0] wb_dat_o,

    // To LEDS
    output logic [7:0] leds
);

    // Register
    logic [7:0] register [4];

    always_ff @(posedge clk) begin
        wb_ack_o <= 0;

        if (wb_cyc_i & wb_stb_i & ~wb_ack_o) begin
            integer i;
            for (i = 0; i < 4; i++) begin
                if (wb_we_i & wb_sel_i[i])
                    register[i] <= wb_dat_i[8*i +: 8];
            end

            wb_dat_o <= {register[3], register[2], register[1], register[0]};
            wb_ack_o <= 1;
        end
    end

    assign leds = register[0];

endmodule
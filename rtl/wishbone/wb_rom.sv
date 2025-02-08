`timescale 1ns/1ps

module wb_rom #(
    parameter SIZE = 512,
    parameter FILE = "boot.rom"
) (
    input  logic        wb_cyc_i,
    input  logic        wb_stb_i,
    output logic        wb_ack_o,
    input  logic [10:0]  wb_adr_i,
    output logic [31:0] wb_dat_o
);

    logic [31:0] mem [SIZE];

    assign wb_ack_o = wb_cyc_i & wb_stb_i;
    assign wb_dat_o = mem[wb_adr_i[10:2]];

endmodule

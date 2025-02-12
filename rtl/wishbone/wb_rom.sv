`timescale 1ns/1ps

module wb_rom #(
        parameter SIZE_BYTES = 512,
        localparam NUM_WORDS = SIZE_BYTES/4,
        localparam ADDR_WIDTH = $clog2(SIZE_BYTES),
        parameter FILE = ""
    ) (
        input  logic                  wb_cyc_i,
        input  logic                  wb_stb_i,
        output logic                  wb_ack_o,
        input  logic [ADDR_WIDTH-1:0] wb_adr_i,
        output logic [31:0]           wb_dat_o
    );

    logic [31:0] mem [NUM_WORDS];

    initial if (FILE != "") $readmemh(FILE, mem);

    assign wb_ack_o = wb_cyc_i & wb_stb_i;
    assign wb_dat_o = mem[wb_adr_i[ADDR_WIDTH-1:2]];

endmodule

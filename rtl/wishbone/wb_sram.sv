`timescale 1ns / 1ps

module wb_sram
    #(
        parameter SIZE_BYTES = 32_768,
        localparam NUM_WORDS = SIZE_BYTES/4,
        localparam ADDR_WIDTH = $clog2(SIZE_BYTES),
        parameter FILE = ""
    ) (
        input  logic                  wb_clk_i,
        input  logic                  wb_cyc_i,
        input  logic                  wb_stb_i,
        input  logic [ADDR_WIDTH-1:0] wb_adr_i,
        input  logic                  wb_we_i,
        input  logic [3:0]            wb_sel_i,
        input  logic [31:0]           wb_dat_i,
        output logic [31:0]           wb_dat_o,
        output logic                  wb_ack_o
    );

    (* ram_style = "block" *)
    logic [31:0] mem [NUM_WORDS];

    initial if (FILE != "") $readmemh(FILE, mem);

    always_ff @(posedge wb_clk_i) begin
        wb_ack_o <= 0;

        if (wb_cyc_i & wb_stb_i & ~wb_ack_o) begin
            integer i;
            for (i = 0; i < 4; i++) begin
                if (wb_we_i & wb_sel_i[i])
                    mem[wb_adr_i[ADDR_WIDTH-1:2]][8*i +: 8] <= wb_dat_i[8*i +: 8];
            end

            wb_dat_o <= mem[wb_adr_i[ADDR_WIDTH-1:2]];
            wb_ack_o <= 1;
        end
    end
endmodule

`timescale 1ns / 1ps

module wb_sram
    #(
        parameter SIZE_BYTES = 32_768,
        localparam NUM_WORDS = SIZE_BYTES/4,
        localparam ADDR_WIDTH = $clog2(SIZE_BYTES)
    ) (
        // Port A
        input  logic                  a_clk_i,
        input  logic                  a_cyc_i,
        input  logic                  a_stb_i,
        input  logic [ADDR_WIDTH-1:0] a_adr_i,
        input  logic                  a_we_i,
        input  logic [3:0]            a_sel_i,
        input  logic [31:0]           a_dat_i,
        output logic [31:0]           a_dat_o,
        output logic                  a_ack_o,

        // Port B
        input  logic                  b_clk_i,
        input  logic                  b_cyc_i,
        input  logic                  b_stb_i,
        input  logic [ADDR_WIDTH-1:0] b_adr_i,
        input  logic                  b_we_i,
        input  logic [3:0]            b_sel_i,
        input  logic [31:0]           b_dat_i,
        output logic [31:0]           b_dat_o,
        output logic                  b_ack_o
    );

    // Raw memory block
    (* no_rw_check *)
    logic [31:0] mem [0:NUM_WORDS-1];

    integer i;

    // logic a_read, a_write;
    // assign a_read = a_cyc_i & a_stb_i & ~a_we_i;
    // assign a_write = a_cyc_i & a_stb_i & a_we_i;

    // logic b_read, b_write;
    // assign b_read = b_cyc_i & b_stb_i & ~b_we_i;
    // assign b_write = b_cyc_i & b_stb_i & b_we_i;

    // Port A
    always_ff @(posedge a_clk_i) begin
        a_ack_o <= 0;

        if (a_cyc_i & a_stb_i & ~a_ack_o) begin
            for (i = 0; i < 4; i++) begin
                if (a_we_i & a_sel_i[i])
                    mem[a_adr_i[ADDR_WIDTH-1:2]][8*i +: 8] <= a_dat_i[8*i +: 8];
            end

            a_dat_o <= mem[a_adr_i[ADDR_WIDTH-1:2]];
            a_ack_o <= 1; 
        end
    end

    // Port B
    always_ff @(posedge b_clk_i) begin
        b_ack_o <= 0;
        
        if (b_cyc_i & b_stb_i & ~b_ack_o) begin
            for (i = 0; i < 4; i++) begin
                if (b_we_i & b_sel_i[i])
                    mem[b_adr_i[ADDR_WIDTH-1:2]][8*i +: 8] <= b_dat_i[8*i +: 8];
            end
            b_dat_o <= mem[b_adr_i[ADDR_WIDTH-1:2]];
            b_ack_o <= 1;
        end
    end

endmodule

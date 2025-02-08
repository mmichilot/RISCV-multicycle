`timescale 1ns / 1ps

// Top Module
module top #(
        parameter SRAM_SIZE = 32_768
    ) (
    input clk,
    input rst_n,

    input external_int
);

    // Core Interrupts
    logic timer_int, software_int;
    logic [31:0] interrupts;
    assign interrupts[11] = external_int;
    assign interrupts[7]  = timer_int;
    assign interrupts[3]  = software_int;

    /*
     * RISC-V Core
     */
    logic wb_cyc_o, wb_stb_o, wb_we_o, wb_ack_i, wb_stall_i;
    logic [3:0] wb_sel_o;
    logic [31:0] wb_adr_o, wb_dat_i, wb_dat_o;
    assign wb_stall_i = 0; // Temporary
    core core(
        .clk,
        .rst_n,

        .wb_cyc_o,
        .wb_stb_o,
        .wb_stall_i,
        .wb_ack_i,
        .wb_we_o,
        .wb_sel_o,
        .wb_adr_o,
        .wb_dat_o,
        .wb_dat_i,

        .interrupts
    );

    localparam ROM_BASE = 32'h0000_0000;
    localparam ROM_MASK = 32'hFFFF_FE00;
    localparam SRAM_BASE = 32'h8000_0000;
    localparam SRAM_MASK = ~32'(SRAM_SIZE-1);
    localparam CLINT_BASE = 32'h0200_0000;
    localparam CLINT_MASK = 32'hFFFF_0000;

    logic rom_ack_o;
    logic [31:0] rom_dat_o;
    wb_rom rom(
        .wb_cyc_i (wb_cyc_o),
        .wb_stb_i (wb_stb_o & rom_sel),
        .wb_ack_o (rom_ack_o),
        .wb_adr_i (wb_adr_o[10:0]),
        .wb_dat_o (rom_dat_o)
    );


    localparam SRAM_ADDR_WIDTH = $clog2(SRAM_SIZE);
    logic sram_ack_o;
    logic [31:0] sram_dat_o;
    wb_sram #(
        .SIZE_BYTES(SRAM_SIZE)
    ) sram (
        .wb_clk_i (clk),
        .wb_cyc_i (wb_cyc_o),
        .wb_stb_i (wb_stb_o & sram_sel),
        .wb_adr_i (wb_adr_o[SRAM_ADDR_WIDTH-1:0]),
        .wb_we_i  (wb_we_o),
        .wb_sel_i (wb_sel_o),
        .wb_dat_i (wb_dat_o),
        .wb_dat_o (sram_dat_o),
        .wb_ack_o (sram_ack_o)
    );

    logic clint_ack_o;
    logic [31:0] clint_dat_o;
    wb_clint clint (
        .clk ,
        .rst_n,

        .wb_cyc_i (wb_cyc_o),
        .wb_stb_i (wb_stb_o & clint_sel),
        .wb_we_i  (wb_we_o),
        .wb_adr_i (wb_adr_o[15:0]),
        .wb_sel_i (wb_sel_o),
        .wb_dat_i (wb_dat_o),
        .wb_dat_o (clint_dat_o),
        .wb_ack_o (clint_ack_o),

        .software_int,
        .timer_int
    );


    logic rom_sel, sram_sel, clint_sel;
    wb_decoder wb_decoder(
        .adr_i           (wb_adr_o),

        .slv0_adr_prefix (ROM_BASE),
        .slv0_adr_mask   (ROM_MASK),
        .acmp0           (rom_sel),

        .slv1_adr_prefix (SRAM_BASE),
        .slv1_adr_mask   (SRAM_MASK),
        .acmp1           (sram_sel),

        .slv2_adr_prefix (CLINT_BASE),
        .slv2_adr_mask   (CLINT_MASK),
        .acmp2           (clint_sel)
    );

    always_comb begin : wb_dat_i_mux
        wb_dat_i = '0;

        if ((wb_adr_o & ROM_MASK) == ROM_BASE)
            wb_dat_i = rom_dat_o;
        if ((wb_adr_o & SRAM_MASK) == SRAM_BASE)
            wb_dat_i = sram_dat_o;
        if ((wb_adr_o & CLINT_MASK) == CLINT_BASE)
            wb_dat_i = clint_dat_o;
    end

    assign wb_ack_i = clint_ack_o | sram_ack_o | rom_ack_o;

endmodule
`timescale 1ns / 1ps

// Top Module
module top #(
        SRAM_SIZE = 32_768
    ) (
    input clk,
    input rst_n,

    input external_int,

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

    // Core Interrupts
    logic timer_int, software_int;
    logic [31:0] interrupts;
    assign interrupts[11] = external_int;
    assign interrupts[7]  = timer_int;
    assign interrupts[3]  = software_int;

    logic imem_cyc_o, imem_stb_o, imem_stall_i, imem_we_o, imem_ack_i;
    logic [3:0] imem_sel_o;
    logic [31:0] imem_adr_o, imem_dat_i, imem_dat_o;

    logic dmem_cyc_o, dmem_stb_o, dmem_stall_i, dmem_we_o, dmem_ack_i;
    logic [3:0] dmem_sel_o;
    logic [31:0] dmem_adr_o, dmem_dat_i, dmem_dat_o;

    wb_core core (
        .clk,
        .rst_n,

        .imem_cyc_o,
        .imem_stb_o,
        .imem_stall_i,
        .imem_we_o,
        .imem_adr_o,
        .imem_sel_o,
        .imem_dat_o,
        .imem_dat_i,
        .imem_ack_i,

        .dmem_cyc_o,
        .dmem_stb_o,
        .dmem_stall_i,
        .dmem_we_o,
        .dmem_adr_o,
        .dmem_sel_o,
        .dmem_dat_o,
        .dmem_dat_i,
        .dmem_ack_i,

        .interrupts
    );
    
    localparam SRAM_ADDR_WIDTH = $clog2(SRAM_SIZE);
    logic sram_stb_i, sram_ack_o;
    logic [31:0] sram_dat_o;
    assign sram_stb_i = dmem_stb_o & sram_sel;
    assign dmem_dat_i = sram_dat_o;
    assign dmem_ack_i = sram_ack_o;
    wb_sram #(
        .SIZE_BYTES(SRAM_SIZE)
    ) sram (
        .a_clk_i (clk),
        .a_cyc_i (imem_cyc_o),
        .a_stb_i (imem_stb_o),
        .a_adr_i (imem_adr_o[SRAM_ADDR_WIDTH-1:0]),
        .a_we_i  (imem_we_o),
        .a_sel_i (imem_sel_o),
        .a_dat_i (imem_dat_o),
        .a_dat_o (imem_dat_i),
        .a_ack_o (imem_ack_i),

        .b_clk_i (clk),
        .b_cyc_i (dmem_cyc_o),
        .b_stb_i (sram_stb_i),
        .b_adr_i (dmem_adr_o[SRAM_ADDR_WIDTH-1:0]),
        .b_we_i  (dmem_we_o),
        .b_sel_i (dmem_sel_o),
        .b_dat_i (dmem_dat_o),
        .b_dat_o (sram_dat_o),
        .b_ack_o (sram_ack_o)
    );

    logic sram_sel, slv1_sel;
    localparam SRAM_MASK = ~32'(SRAM_SIZE-1);
    wb_decoder wb_decoder(
        .adr_i           (dmem_adr_o),
        .slv0_adr_prefix (32'h8000_0000),
        .slv0_adr_mask   (SRAM_MASK),
        .acmp0           (sram_sel),
        .slv1_adr_prefix (32'h0000_0000),
        .slv1_adr_mask   (32'hFFFF_FFFF),
        .acmp1           (slv1_sel)
    );
    
    assign probe_cyc    = dmem_cyc_o;
    assign probe_stb    = dmem_stb_o;
    assign probe_we     = dmem_we_o;
    assign probe_sel    = dmem_sel_o;
    assign probe_adr    = dmem_adr_o;
    assign probe_dat_i  = dmem_dat_i;
    assign probe_dat_o  = dmem_dat_o;
    assign probe_ack    = dmem_ack_i;

endmodule
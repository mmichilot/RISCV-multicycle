`timescale 1ns / 1ps

// Original Top w/o Wishbone Architecture
module top_orig (
    input clk,
    input rst_n,

    input logic external_int,

    // scope data memory bus
    output logic        scope_read,
    output logic        scope_write,
    output logic        scope_ready,
    output logic [3:0]  scope_byte_en,
    output logic [31:0] scope_addr,
    output logic [31:0] scope_wdata,
    output logic [31:0] scope_rdata
);

    // Core Interrupts
    logic timer_int, software_int;
    logic [31:0] interrupts;
    assign interrupts[11] = external_int;
    assign interrupts[7]  = timer_int;
    assign interrupts[3]  = software_int;

    logic imem_read, imem_ready;
    logic [31:0] imem_addr, imem_rdata;

    logic dmem_read, dmem_write, dmem_ready;
    logic [3:0] dmem_byte_en;
    logic [31:0] dmem_addr, dmem_rdata, dmem_wdata;

    logic sram_read, sram_write, sram_ready;
    logic [31:0] sram_rdata;

    core core (
        .clk,
        .rst_n,

        .imem_read,
        .imem_addr,
        .imem_rdata,
        .imem_ready,

        .dmem_read,
        .dmem_write,
        .dmem_addr,
        .dmem_byte_en,
        .dmem_wdata,
        .dmem_rdata,
        .dmem_ready,

        .interrupts
    );


    sram #(
        .SIZE_BYTES(2_097_152)
    ) sram (
        .A_clk   (clk),
        .A_read  (imem_read),
        .A_addr  (imem_addr[20:0]),
        .A_rdata (imem_rdata),
        .A_ready (imem_ready),

        .B_clk     (clk),
        .B_read    (dmem_read),
        .B_write   (dmem_write),
        .B_byte_en (dmem_byte_en),
        .B_addr    (dmem_addr[20:0]),
        .B_wdata   (dmem_wdata),
        .B_rdata   (dmem_rdata),
        .B_ready   (dmem_ready)
    );

    assign scope_read    = dmem_read;
    assign scope_write   = dmem_write;
    assign scope_byte_en = dmem_byte_en;
    assign scope_addr    = dmem_addr;
    assign scope_wdata   = dmem_wdata;
    assign scope_rdata   = dmem_rdata;

endmodule
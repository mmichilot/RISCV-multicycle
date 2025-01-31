`timescale 1ns / 1ps

module wb_core (
    input clk,
    input rst_n,

    // Instruction Interface
    output logic        imem_cyc_o,
    output logic        imem_stb_o,
    input  logic        imem_stall_i,
    output logic        imem_we_o,
    output logic [31:0] imem_adr_o,
    output logic [3:0]  imem_sel_o,
    output logic [31:0] imem_dat_o,
    input  logic [31:0] imem_dat_i,
    input  logic        imem_ack_i,

    // Data Interface
    output logic        dmem_cyc_o,
    output logic        dmem_stb_o,
    input  logic        dmem_stall_i,
    output logic        dmem_we_o,
    output logic [31:0] dmem_adr_o,
    output logic [3:0]  dmem_sel_o,
    output logic [31:0] dmem_dat_o,
    input  logic [31:0] dmem_dat_i,
    input  logic        dmem_ack_i,

    input logic [31:0] interrupts
);

    // Core interfaces
    logic imem_read, imem_ready;
    logic [31:0] imem_addr, imem_rdata;

    logic dmem_read, dmem_write, dmem_ready;
    logic [3:0] dmem_byte_en;
    logic [31:0] dmem_addr, dmem_rdata, dmem_wdata;

    core core(
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

    wb_adapter #(
        .RDATA_REG(1)
    ) imem_adapter (
        .clk_i(clk),
        .rst_i(~rst_n),

        .mem_read    (imem_read),
        .mem_write   ('0),
        .mem_addr    (imem_addr),
        .mem_byte_en (4'b1111),
        .mem_wdata   ('0),
        .mem_rdata   (imem_rdata),
        .mem_ready   (imem_ready),

        .wb_cyc_o   (imem_cyc_o),
        .wb_stb_o   (imem_stb_o),
        .wb_stall_i (imem_stall_i),
        .wb_we_o    (imem_we_o),
        .wb_adr_o   (imem_adr_o),
        .wb_sel_o   (imem_sel_o),
        .wb_dat_o   (imem_dat_o),
        .wb_dat_i   (imem_dat_i),
        .wb_ack_i   (imem_ack_i)
    );

    wb_adapter #(
        .RDATA_REG(1)
    ) dmem_adapter (
        .clk_i(clk),
        .rst_i(~rst_n),

        .mem_read    (dmem_read),
        .mem_write   (dmem_write),
        .mem_addr    (dmem_addr),
        .mem_byte_en (dmem_byte_en),
        .mem_wdata   (dmem_wdata),
        .mem_rdata   (dmem_rdata),
        .mem_ready   (dmem_ready),

        .wb_cyc_o   (dmem_cyc_o),
        .wb_stb_o   (dmem_stb_o),
        .wb_stall_i (dmem_stall_i),
        .wb_we_o    (dmem_we_o),
        .wb_adr_o   (dmem_adr_o),
        .wb_sel_o   (dmem_sel_o),
        .wb_dat_o   (dmem_dat_o),
        .wb_dat_i   (dmem_dat_i),
        .wb_ack_i   (dmem_ack_i)
    );

endmodule
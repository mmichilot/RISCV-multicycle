`timescale 1ns / 1ps

module top
    (
        input clk,
        input rst_n,

        output logic dmem_read,
        output logic dmem_write,
        output logic [1:0] dmem_size,
        output logic [31:0] dmem_addr,
        output logic [31:0] dmem_rdata,
        output logic [31:0] dmem_wdata
    );

    // Bus signals
    logic        s_imem_read;
    logic [31:0] s_imem_addr;
    logic [31:0] s_imem_rdata;
    logic        s_imem_done;

    core core(
        .clk,
        .rst_n,

        .imem_read(s_imem_read),
        .imem_addr(s_imem_addr),
        .imem_rdata(s_imem_rdata),
        .imem_done(s_imem_done),

        .data_read,
        .data_write,
        .data_size,
        .data_addr,
        .data_write_data,
        .data_read_data
    );

    sram #(
        .SIZE_BYTES(425_984)
    ) sram (
        .clk,

        .A_read_i(s_inst_read),
        .A_addr_i(s_inst_addr),
        .A_rdata_o(s_inst_data),

        .read_B(data_read),
        .write_B(data_write),
        .size_B(data_size),
        .addr_B(data_addr),
        .wr_data_B(data_write_data),
        .rd_data_B(data_read_data)
    );

endmodule

`timescale 1ns / 1ps

module top
    (
        input clk,
        input rst_n,

        output logic data_read,
        output logic data_write,
        output logic data_sign,
        output logic [1:0] data_size,
        output logic [31:0] data_addr,
        output logic [31:0] data_write_data,
        output logic [31:0] data_read_data
    );
    
    // Bus signals
    logic s_inst_read;
    logic [31:0] s_inst_addr;
    logic [31:0] s_inst_data;

    core core(
        .clk,
        .rst_n,

        .inst_read(s_inst_read),
        .inst_addr(s_inst_addr),
        .inst_data(s_inst_data),

        .data_read,
        .data_write,
        .data_sign,
        .data_size,
        .data_addr,
        .data_write_data,
        .data_read_data
    );

    sram sram(
        .clk,
        
        .read_A(s_inst_read),
        .addr_A(s_inst_addr),
        .data_A(s_inst_data),

        .read_B(data_read),
        .write_B(data_write),
        .sign_B(data_sign),
        .size_B(data_size),
        .addr_B(data_addr),
        .wr_data_B(data_write_data),
        .rd_data_B(data_read_data)
    );
    
endmodule

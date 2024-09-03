`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: M. Michilot
// 
// Create Date: 08/20/2021
// Design Name: Basic CPU Wrapper
// Module Name: top
// Project Name: OTTER CPU
// Target Devices:
// Tool Versions: 
// Description: Basic CPU Wrapper to be used with Verilator testbench
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top
    (
        input         clk_i,
        input         rst_i,

        input bit [31:0] mem_signature_begin,
        input bit [31:0] mem_signature_end,
        input bit [31:0] mem_mailbox,
        input string     mem_file
    );

    // Note: yosys throws warnings about interface signals being implicitly
    //       declared. If 'default_nettype none' is used, yosys throws an error
    //       instead.
    // Temp. Solution: Don't use 'default_nettype none' until issue is resolved
    // Issue: Currently OPEN on Yosys GitHub
    //       https://github.com/YosysHQ/yosys/issues/1053

    // Bus signals
    logic s_inst_read;
    logic [31:0] s_inst_addr;
    logic [31:0] s_inst_data;

    logic s_data_read;
    logic s_data_write;
    logic s_data_sign;
    logic [1:0] s_data_size;
    logic [31:0] s_data_addr;
    logic [31:0] s_data_write_data;
    logic [31:0] s_data_read_data;

    core core(
        .clk(clk_i),
        .rst(rst_i),
        .error(1'b0),

        .inst_read(s_inst_read),
        .inst_addr(s_inst_addr),
        .inst_data(s_inst_data),

        .data_read(s_data_read),
        .data_write(s_data_write),
        .data_sign(s_data_sign),
        .data_size(s_data_size),
        .data_addr(s_data_addr),
        .data_write_data(s_data_write_data),
        .data_read_data(s_data_read_data)
    );

    sram sram(
        .clk(clk_i),
        
        .read_A(s_inst_read),
        .addr_A(s_inst_addr),
        .data_A(s_inst_data),

        .read_B(s_data_read),
        .write_B(s_data_write),
        .sign_B(s_data_sign),
        .size_B(s_data_size),
        .addr_B(s_data_addr),
        .wr_data_B(s_data_write_data),
        .rd_data_B(s_data_read_data)
    );

    initial begin
        $display("SIMULATION START");

        // Load memory into sram
        $display("\nLoading memory file: %s", mem_file);
        $readmemh(mem_file, sram.mem);

        $display("\nMemory Address passed from Verilator");
        $display("Memory Mailbox: 0x%08X", mem_mailbox);
        $display("Signature Begin: 0x%08X", mem_signature_begin);
        $display("Signature End: 0x%08X", mem_signature_end);
        $display();
    end

    

    logic mailbox_write;
    /* verilator lint_off UNUSED */
    logic [31:0] mailbox_data;
    /* verilator lint_on UNUSED */
    assign mailbox_write = sram.write_B && (sram.addr_B == mem_mailbox);
    assign mailbox_data  = sram.wr_data_B;

    parameter MAX_CYCLE_COUNT = 100_000;

    int cycleCnt = 0;
    always @(negedge clk_i) begin
        cycleCnt <= cycleCnt + 1;

        if (s_inst_read) 
            $display("inst_addr: 0x%08X | inst: 0x%08X", s_inst_addr, sram.mem[s_inst_addr >> 2]);

        if (cycleCnt == MAX_CYCLE_COUNT) begin
            $display("Max cycle count reached, terminating..."); 
            dump_signature();
            $finish;
        end
        
        if (mailbox_write && (mailbox_data[7:0] == 8'hFF || mailbox_data[7:0] == 8'h01)) begin
            $display("SIMULATION FINISHED");
            dump_signature();
            $finish;
        end
    end

    task dump_signature ();
        integer fp, i, sig_start, sig_end;
        
        fp = $fopen("otter.signature", "w");
        
        sig_start = mem_signature_begin / 4;
        sig_end = mem_signature_end / 4;
        for (i = sig_start; i < sig_end; i++) begin
            $fwrite(fp, "%08X\n", sram.mem[i]);
        end

        $fclose(fp);
    endtask

endmodule

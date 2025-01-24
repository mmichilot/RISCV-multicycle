`timescale 1ns / 1ps

module top
    (
        input         clk,
        input         rst_n,

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
    logic        s_imem_read;
    logic [31:0] s_imem_addr;
    logic [31:0] s_imem_rdata;
    logic        s_imem_ready;

    logic        s_dmem_read;
    logic        s_dmem_write;
    logic [3:0]  s_dmem_byte_en;
    logic [31:0] s_dmem_addr;
    logic [31:0] s_dmem_wdata;
    logic [31:0] s_dmem_rdata;
    logic        s_dmem_ready;

    // Interrupts
    logic [31:0] interrupts;

    core core(
        .clk,
        .rst_n,

        .imem_read(s_imem_read),
        .imem_addr(s_imem_addr),
        .imem_rdata(s_imem_rdata),
        .imem_ready(s_imem_ready),

        .dmem_read(s_dmem_read),
        .dmem_write(s_dmem_write),
        .dmem_byte_en(s_dmem_byte_en),
        .dmem_addr(s_dmem_addr),
        .dmem_wdata(s_dmem_wdata),
        .dmem_rdata(s_dmem_rdata),
        .dmem_ready(s_dmem_ready),

        .interrupts
    );

    sram #(
        .SIZE_BYTES(2_097_152)
    ) sram (
        .clk,

        .A_read(s_imem_read),
        .A_addr(s_imem_addr),
        .A_rdata(s_imem_rdata),
        .A_ready(s_imem_ready),

        .B_read(s_dmem_read),
        .B_write(s_dmem_write),
        .B_byte_en(s_dmem_byte_en),
        .B_addr(s_dmem_addr),
        .B_wdata(s_dmem_wdata),
        .B_rdata(s_dmem_rdata),
        .B_ready(s_dmem_ready)
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
    assign mailbox_write = s_dmem_write && (s_dmem_addr == mem_mailbox);
    assign mailbox_data  = s_dmem_wdata;

    parameter MAX_CYCLE_COUNT = 100_000;

    int cycleCnt = 0;
    always @(negedge clk) begin
        cycleCnt <= cycleCnt + 1;

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

    task dump_memory();
        integer fp, i, mem_start, mem_end;

        fp = $fopen("mem.dump", "w");
        mem_start = 0;
        mem_end = 2_097_152 / 4;
        for (i = mem_start; i < mem_end; i = i + 1)
            $fwrite(fp, "%08X\n", sram.mem[i]);
    endtask

endmodule

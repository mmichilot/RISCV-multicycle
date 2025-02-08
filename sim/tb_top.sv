`timescale 1ns / 1ps
`default_nettype none

module tb_top
    (
        input         clk,
        input         rst_n,

        input bit [31:0] mem_signature_begin,
        input bit [31:0] mem_signature_end,
        input bit [31:0] mem_mailbox,
        input string     mem_file
    );
    
    top #(
        .SRAM_SIZE(2_097_152)
    ) top (
        .clk,
        .rst_n,

        .external_int(1'b0)
    );

    initial begin
        $display("SIMULATION START");

        // Load memory into sram
        $display("\nLoading memory file: %s", mem_file);
        $readmemh(mem_file, top.sram.mem);

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
    assign mailbox_write = top.wb_cyc_o & top.wb_stb_o & top.wb_we_o & (top.wb_adr_o == mem_mailbox);
    assign mailbox_data  = top.wb_dat_o;

    parameter MAX_CYCLE_COUNT = 500_000;

    int cycleCnt = 0;
    always @(negedge clk) begin
        cycleCnt <= cycleCnt + 1;

        if (cycleCnt == MAX_CYCLE_COUNT) begin
            $display("Max cycle count reached, terminating...");
            dump_memory();
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
            $fwrite(fp, "%08X\n", top.sram.mem[i]);
        end

        $fclose(fp);
    endtask

    task dump_memory();
        integer fp, i, mem_start, mem_end;

        fp = $fopen("otter.signature", "w");
        mem_start = 0;
        mem_end = $size(top.sram.mem);
        for (i = mem_start; i < mem_end; i = i + 1)
            $fwrite(fp, "%08X\n", top.sram.mem[i]);
    endtask

endmodule

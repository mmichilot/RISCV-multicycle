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

    logic [31:0] interrupts;

    logic wb_cyc_o, wb_stb_o, wb_ack_i, wb_we_o;
    logic [3:0] wb_sel_o;
    logic [31:0] wb_adr_o, wb_dat_o, wb_dat_i;
    core core(
        .clk,
        .rst_n,

        .wb_cyc_o,
        .wb_stb_o,
        .wb_stall_i (0),
        .wb_ack_i,
        .wb_we_o,
        .wb_sel_o,
        .wb_adr_o,
        .wb_dat_o,
        .wb_dat_i,

        .interrupts
    );

    wb_sram #(
        .SIZE_BYTES (2_097_152)
    ) sram(
        .wb_clk_i (clk),
        .wb_cyc_i (wb_cyc_o),
        .wb_stb_i (wb_stb_o),
        .wb_adr_i (wb_adr_o[20:0]),
        .wb_we_i  (wb_we_o),
        .wb_sel_i (wb_sel_o),
        .wb_dat_i (wb_dat_o),
        .wb_dat_o (wb_dat_i),
        .wb_ack_o (wb_ack_i)
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
    assign mailbox_write = wb_cyc_o & wb_stb_o & wb_we_o & (wb_adr_o == mem_mailbox);
    assign mailbox_data  = wb_dat_o;

    parameter MAX_CYCLE_COUNT = 200_000;

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
            $fwrite(fp, "%08X\n", sram.mem[i]);
        end

        $fclose(fp);
    endtask

    task dump_memory();
        integer fp, i, mem_start, mem_end;

        fp = $fopen("otter.signature", "w");
        mem_start = 0;
        mem_end = $size(sram.mem);
        for (i = mem_start; i < mem_end; i = i + 1)
            $fwrite(fp, "%08X\n", sram.mem[i]);
    endtask

endmodule

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

    // Memory
    localparam SRAM_BYTES = 2_097_152;
    localparam SRAM_MASK = SRAM_BYTES - 1;
    localparam SRAM_WIDTH = $clog2(SRAM_BYTES);
    logic [31:0] mem [SRAM_BYTES / 4];

    always_ff @(posedge clk) begin
        int random_delay;
        random_delay = $random % 10;

        wb_ack_i <= 0;
        if (wb_cyc_o & wb_stb_o & ~wb_ack_i) begin
            integer i;
            for (i = 0; i < 4; i++) begin
                if (wb_we_o & wb_sel_o[i])
                    mem[wb_adr_o[SRAM_WIDTH-1:2]][8*i +: 8] <= wb_dat_o[8*i +: 8];
            end
            wb_dat_i <= mem[wb_adr_o[SRAM_WIDTH-1:2]];

            repeat (random_delay) @(posedge clk);
            wb_ack_i <= 1;
        end
    end

    initial begin
        $display("SIMULATION START");

        // Load memory into sram
        $display("\nLoading memory file: %s", mem_file);
        $readmemh(mem_file, mem);

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
            $display("SIMULATION FAILED");
            $display("Max cycle count reached, terminating...");
            dump_memory();
            $finish;
        end

        if (mailbox_write && (mailbox_data[7:0] == 8'hFF || mailbox_data[7:0] == 8'h01)) begin
            $display("SIMULATION PASSED");
            dump_signature();
            $finish;
        end
    end

    function void dump_signature ();
        integer fp, i, sig_start, sig_end;

        fp = $fopen("otter.signature", "w");

        sig_start = (SRAM_MASK & mem_signature_begin) / 4;
        sig_end = (SRAM_MASK & mem_signature_end) / 4;
        for (i = sig_start; i < sig_end; i++) begin
            $fwrite(fp, "%08X\n", mem[i]);
        end

        $fclose(fp);
    endfunction

    function void dump_memory();
        integer fp, i, mem_start, mem_end;

        fp = $fopen("mem.dump", "w");
        mem_start = 0;
        mem_end = $size(mem);
        for (i = mem_start; i < mem_end; i = i + 1)
            $fwrite(fp, "%08X\n", mem[i]);
    endfunction

endmodule

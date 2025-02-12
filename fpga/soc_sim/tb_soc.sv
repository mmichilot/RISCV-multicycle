`timescale 1ns / 1ps
`default_nettype none

module tb_soc
    (
        input         clk,
        input         rst_n,

        input bit [31:0] mem_mailbox,
        input string     firmware_file
    );

    logic [7:0] leds;

    soc soc (
        .clk,
        .rst_n,

        .leds
    );


    initial begin
        $display("Memory Mailbox: 0x%08X", mem_mailbox);
        $display();

        $display("SIMULATION START");
    end

    logic mailbox_write;
    /* verilator lint_off UNUSED */
    logic [31:0] mailbox_data;
    /* verilator lint_on UNUSED */
    assign mailbox_write = soc.wb_cyc_o & soc.wb_stb_o & soc.wb_we_o & (soc.wb_adr_o == mem_mailbox);
    assign mailbox_data  = soc.wb_dat_o;

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
            dump_memory();
            $finish;
        end
    end


    task dump_memory();
        integer fp, i, mem_start, mem_end;

        fp = $fopen("mem.dump", "w");
        mem_start = 0;
        mem_end = $size(soc.sram.mem);
        for (i = mem_start; i < mem_end; i = i + 1)
            $fwrite(fp, "%08X\n", soc.sram.mem[i]);
    endtask

endmodule

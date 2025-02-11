`timescale 1ns / 1ps

// Core Local INTerrupt Controller w/ Wishbone Interface
// Set of memory-mapped registers that control timer and software interrupts
module clint (
        input clk,
        input rst_n,

        // Memory Interface
        input  logic        wb_cyc_i,
        input  logic        wb_stb_i,
        input  logic        wb_we_i,
        input  logic [15:0] wb_adr_i,
        input  logic [3:0]  wb_sel_i,
        input  logic [31:0] wb_dat_i,
        output logic [31:0] wb_dat_o,
        output logic        wb_ack_o,

        // Interrupts
        output logic software_int,
        output logic timer_int
    );

    // Registers
    logic [31:0] msip_q, msip_n;
    logic [31:0] mtime_q, mtime_n;
    logic [31:0] mtimeh_q, mtimeh_n;
    logic [31:0] mtimecmp_q, mtimecmp_n;
    logic [31:0] mtimecmph_q, mtimecmph_n;

    logic [63:0] mtime, mtimecmp;
    assign mtime = {mtimeh_q, mtime_q};
    assign mtimecmp = {mtimecmph_q, mtimecmp_q};

    // Address Spaces
    typedef enum logic [15:0] {
        MSIP      = 16'h0000,
        MTIME     = 16'h4000,
        MTIMEH    = 16'h4004,
        MTIMECMP  = 16'hBFF8,
        MTIMECMPH = 16'hBFFC
     } clint_addr_e;

    // Reads are async so ack immediately
    assign wb_ack_o = wb_cyc_i & wb_stb_i;

    // Read
    always_comb begin : reg_read
        unique case (wb_adr_i)
            MSIP:      wb_dat_o = {31'b0, msip_q[0]};
            MTIME:     wb_dat_o = mtime_q;
            MTIMEH:    wb_dat_o = mtimeh_q;
            MTIMECMP:  wb_dat_o = mtimecmp_q;
            MTIMECMPH: wb_dat_o = mtimecmph_q;
            default:   wb_dat_o = '0;
        endcase
    end


    always_comb begin : setup_reg_write
        integer i;

        msip_n      = msip_q;
        mtimecmp_n  = mtimecmp_q;
        mtimecmph_n = mtimecmph_q;
        {mtimeh_n, mtime_n} = mtime + 1;

        for (i = 0; i < 4; i++) begin
            logic we;
            we = wb_cyc_i & wb_stb_i & wb_we_i & wb_sel_i[i];
            unique case (wb_adr_i)
                MSIP:      if (we) msip_n[0] = wb_dat_i[0];
                MTIME:     if (we) mtime_n[8*i +: 8] = wb_dat_i[8*i +: 8];
                MTIMEH:    if (we) mtimeh_n[8*i +: 8] = wb_dat_i[8*i +: 8];
                MTIMECMP:  if (we) mtimecmp_n[8*i +: 8] = wb_dat_i[8*i +: 8];
                MTIMECMPH: if (we) mtimecmph_n[8*i +: 8] = wb_dat_i[8*i +: 8];
                default: ;
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin : reg_write
        if (~rst_n) begin
            msip_q      <= '0;
            mtime_q     <= '0;
            mtimeh_q    <= '0;
            mtimecmp_q  <= '0;
            mtimecmph_q <= '0;
        end else begin
            msip_q      <= msip_n;
            mtime_q     <= mtime_n;
            mtimeh_q    <= mtimeh_n;
            mtimecmp_q  <= mtimecmp_n;
            mtimecmph_q <= mtimecmph_n;
        end
    end

    assign software_int = msip_q[0];
    assign timer_int = mtime >= mtimecmp;

endmodule

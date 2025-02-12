`timescale 1ns / 1ps
`include "defs.svh"

module csr (
    input clk,
    input rst_n,

    // CSR Interface
    input  logic        csr_we,
    input  logic [1:0]  csr_op,
    input  logic [11:0] csr_reg,
    input  logic [31:0] csr_wdata,
    output logic [31:0] csr_rdata,

    // From core
    input logic [31:0] pc,
    input logic [31:0] instruction,
    input logic [31:0] misaligned_addr,
    input logic        trap_finish,

    // To core
    output logic [31:0] mtvec,
    output logic [31:0] mepc,

    // From interrupt controller
    input  logic [31:0] mip,
    input  logic [31:0] trap_cause,
    input  logic        trap_pending,

    // To interrupt controller
    output logic [31:0] mie,
    output logic        irq_en
    );

    // Setup write data
    logic [31:0] s_csr_wdata;
    always_comb begin
        unique case (csr_op)
            WRITE:   s_csr_wdata = csr_wdata;
            SET:     s_csr_wdata = csr_rdata | csr_wdata;
            CLEAR:   s_csr_wdata = csr_rdata & (~csr_wdata);
            default: s_csr_wdata = csr_rdata;
        endcase
    end

    ////////////////////////////////////////////////
    //   ____            _     _                  //
    //  |  _ \ ___  __ _(_)___| |_ ___ _ __ ___   //
    //  | |_) / _ \/ _` | / __| __/ _ \ '__/ __|  //
    //  |  _ <  __/ (_| | \__ \ ||  __/ |  \__ \  //
    //  |_| \_\___|\__, |_|___/\__\___|_|  |___/  //
    //             |___/                          //
    ////////////////////////////////////////////////
    logic [31:0] mtvec_q, mtvec_n;
    logic [31:0] mstatush_q, mstatush_n;
    logic [31:0] mscratch_q, mscratch_n;
    logic [31:0] mstatus_q, mstatus_n;
    logic [31:0] mepc_q, mepc_n;
    logic [31:0] mcause_q, mcause_n;
    logic [31:0] mtval_q, mtval_n;
    logic [31:0] mie_q, mie_n;



    ///////////////////////////////
    //   ____                _   //
    //  |  _ \ ___  __ _  __| |  //
    //  | |_) / _ \/ _` |/ _` |  //
    //  |  _ <  __/ (_| | (_| |  //
    //  |_| \_\___|\__,_|\__,_|  //
    ///////////////////////////////
    always_comb begin : csr_read
        unique case (csr_reg)
            MVENDORID: csr_rdata = '0;
            MARCHID:   csr_rdata = '0;
            MIMPID:    csr_rdata = '0;
            MHARTID:   csr_rdata = '0;
            MISA:      csr_rdata = 32'h4000_0100;
            MTVEC:     csr_rdata = mtvec_q;
            MSTATUSH:  csr_rdata = mstatush_q;
            MSCRATCH:  csr_rdata = mscratch_q;
            MSTATUS:   csr_rdata = mstatus_q;
            MEPC:      csr_rdata = mepc_q;
            MCAUSE:    csr_rdata = mcause_q;
            MTVAL:     csr_rdata = mtval_q;
            MIP:       csr_rdata = mip;
            MIE:       csr_rdata = mie_q;
            default:   csr_rdata = '0;
        endcase
    end


    //////////////////////////////////
    //  __        __    _ _         //
    //  \ \      / / __(_) |_ ___   //
    //   \ \ /\ / / '__| | __/ _ \  //
    //    \ V  V /| |  | | ||  __/  //
    //     \_/\_/ |_|  |_|\__\___|  //
    //////////////////////////////////

    // 1. Setup the next data to write into CSRs
    always_comb begin : setup_csr_write
        mtvec_n    = mtvec_q;
        mstatush_n = mstatush_q;
        mscratch_n = mscratch_q;
        mstatus_n  = mstatus_q;
        mepc_n     = mepc_q;
        mcause_n   = mcause_q;
        mtval_n    = mtval_q;
        mie_n      = mie_q;

        // Software writes
        unique case (csr_reg)
            MTVEC:    if (csr_we) mtvec_n = s_csr_wdata;
            MSTATUSH: if (csr_we) mstatush_n = s_csr_wdata;
            MSCRATCH: if (csr_we) mscratch_n = s_csr_wdata;
            MSTATUS:  if (csr_we) mstatus_n  = s_csr_wdata;
            MEPC:     if (csr_we) mepc_n = s_csr_wdata;
            MCAUSE:   if (csr_we) mcause_n = s_csr_wdata;
            MTVAL:    if (csr_we) mtval_n = s_csr_wdata;
            MIE:      if (csr_we) mie_n = s_csr_wdata;
            default: ;
        endcase

        // Hardware writes (takes priority over SW writes)
        if (trap_pending) begin
            mstatus_n[3] = 0;
            mstatus_n[7] = mstatus_q[3];
            mepc_n = pc;
            mcause_n = trap_cause;

            if (~trap_cause[31]) begin
                case (trap_cause[4:0])
                    ENV_BREAK:    mtval_n = pc;
                    ILLEGAL_INST: mtval_n = instruction;
                    INST_ADDR_MISALIGN,
                    LOAD_ADDR_MISALIGN,
                    STORE_ADDR_MISALIGN: mtval_n = misaligned_addr;
                    default: ;
                endcase
            end

        end else if (trap_finish) begin
            mstatus_n[3] = mstatus_q[7];
            mstatus_n[7] = 1;
        end
    end

    // 2. Actually write CSRs
    always_ff @(posedge clk or negedge rst_n ) begin : csr_write
        if (~rst_n) begin
            mtvec_q    <= '0;
            mstatush_q <= '0;
            mscratch_q <= '0;
            mstatus_q  <= 32'h0000_1800;
            mepc_q     <= '0;
            mcause_q   <= '0;
            mtval_q    <= '0;
            mie_q      <= '0;
        end else begin
            mtvec_q    <= mtvec_n;
            mstatush_q <= mstatush_n;
            mscratch_q <= mscratch_n;
            mstatus_q  <= mstatus_n;
            mepc_q     <= mepc_n;
            mcause_q   <= mcause_n;
            mtval_q    <= mtval_n;
            mie_q      <= mie_n;
        end
    end

    assign irq_en = mstatus_q[3];
    assign mie    = mie_q;
    assign mtvec  = mtvec_q;
    assign mepc   = mepc_q;

endmodule

`timescale 1ns / 1ps
`include "defs.svh"

module csr (
    input clk,
    input rst_n,

    // CSR Interface
    input        csr_write,
    input [1:0]  csr_op,
    input [11:0] csr_addr,
    input [31:0] csr_wr_data,
    output logic [31:0] csr_rd_data,

    // Trap Information
    input [31:0] pc,
    input [31:0] instruction,
    input [31:0] misaligned_addr,

    input trap_start,
    input trap_finish,
    input [31:0] trap_cause,
    output logic [31:0] trap_vector,
    output logic [31:0] interrupted_pc,

    output interrupts_enabled
    );

    // Read-only CSRs
    logic [31:0] mvendorid = '0;
    logic [31:0] marchid   = '0;
    logic [31:0] mimpid    = '0;
    logic [31:0] mhartid   = '0;

    // Setup write data
    logic [31:0] s_wr_data;
    always_comb begin
        unique case (csr_op)
            WRITE:   s_wr_data = csr_wr_data;
            SET:     s_wr_data = csr_rd_data | csr_wr_data;
            CLEAR:   s_wr_data = csr_rd_data & (~csr_wr_data);
            default: s_wr_data = csr_wr_data;
        endcase
    end

    /*
     * CSR Registers w/o Hardware Writes
     */
    logic [31:0] misa     = 32'h40000100;
    logic [31:0] mtvec    = '0;
    logic [31:0] mstatush = '0;
    logic [31:0] mscratch = '0;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            misa     <= 32'h40000100;
            mtvec    <= '0;
            mstatush <= '0;
            mscratch <= '0;
        end else if (csr_write) begin
            unique case (csr_addr)
                MISA:     misa     <= s_wr_data;
                MTVEC:    mtvec    <= s_wr_data;
                MSTATUSH: mstatush <= s_wr_data;
                MSCRATCH: mscratch <= s_wr_data;
                default: ;
            endcase
        end
    end

    /*
     * CSR Registers w/ Hardware Writes
     */

     // MSTATUS
    logic [31:0] mstatus = '0;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            mstatus <= '0;
        else if (trap_start) begin // MIE <- 0 and MPIE <- MIE
            mstatus[3] <= 0;
            mstatus[7] <= mstatus[3];
            mstatus[12:11] <= 2'b11;
        end else if (trap_finish) begin // MIE <- MPIE and MPIE <- 0
            mstatus[3] <= mstatus[7];
            mstatus[7] <= 0;
            mstatus[12:11] <= 2'b00;
        end else if (csr_write && csr_addr == MSTATUS)
            mstatus <= s_wr_data;
    end

    // MEPC
    logic [31:0] mepc = '0;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            mepc <= '0;
        else if (trap_start)
            mepc <= pc;
        else if (csr_write && csr_addr == MEPC)
            mepc <= { s_wr_data[31:2], 2'b00 };
    end

    // MCAUSE 
    logic [31:0] mcause = '0;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            mcause <= '0;
        else if (trap_start)
            mcause <= trap_cause;
        else if (csr_write && csr_addr == MCAUSE)
            mcause <= s_wr_data;
    end

    // MTVAL
    logic [31:0] mtval = '0;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            mtval <= '0;
        else if (trap_start && !trap_cause[31]) begin
            case (trap_cause[4:0])
                ENV_BREAK:    mtval <= pc;
                ILLEGAL_INST: mtval <= instruction;
                INST_ADDR_MISALIGN, 
                LOAD_ADDR_MISALIGN,
                STORE_ADDR_MISALIGN: mtval <= misaligned_addr;
                default: ;
            endcase
        end else if (csr_write && csr_addr == MTVAL)
            mtval <= s_wr_data;
    end

    /*
     * CSR Read MUX
     */
    always_comb begin
        unique case (csr_addr)
            MVENDORID: csr_rd_data = mvendorid;
            MARCHID:   csr_rd_data = marchid;
            MIMPID:    csr_rd_data = mimpid;
            MHARTID:   csr_rd_data = mhartid;
            MSTATUS:   csr_rd_data = mstatus;
            MISA:      csr_rd_data = misa;
            MTVEC:     csr_rd_data = mtvec;
            MSTATUSH:  csr_rd_data = mstatush;
            MSCRATCH:  csr_rd_data = mscratch;
            MEPC:      csr_rd_data = { mepc[31:2], 2'b00 };
            MCAUSE:    csr_rd_data = mcause;
            MTVAL:     csr_rd_data = mtval;
            default:   csr_rd_data = '0;
        endcase
    end

    assign trap_vector = mtvec;
    assign interrupts_enabled = mstatus[3];
    assign interrupted_pc = mepc;

endmodule

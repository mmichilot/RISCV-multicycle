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

    // Interrupts & Exceptions
    input [31:0] interrupts,
    input illegal_inst,
    input inst_addr_misalign,
    input load_addr_misalign,
    input store_addr_misalign,
    input env_call,
    input env_break,

    // Core Information
    input [31:0] pc,
    input [31:0] instruction,
    input [31:0] misaligned_addr,

    // Trap Interface
    output logic trap_pending,
    input trap_start,
    input trap_finish,
    output logic [31:0] trap_vector,
    output logic [31:0] trap_return
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

    // MIP (read-only)
    logic [31:0] mip = '0;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            mip <= '0;
        else
            mip <= interrupts;
    end

    // MIE
    logic [31:0] mie = '0;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            mie <= '0;
        else if (csr_write && csr_addr == MIE)
            mie <= s_wr_data;
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
            MIP:       csr_rd_data = mip;
            MIE:       csr_rd_data = mie;
            default:   csr_rd_data = '0;
        endcase
    end

    /*
     * Trap Handling
     */
    logic interrupts_enabled, interrupt_pending, exception_pending;
    assign interrupts_enabled = mstatus[3];
    assign interrupt_pending = |(mip & mie) & interrupts_enabled;
    assign exception_pending = illegal_inst | inst_addr_misalign | load_addr_misalign | store_addr_misalign | env_call | env_break;

    // Determine exception code based on priority
    // (External > Timer > Software > Exceptions)
    logic [4:0] exception_code;
    always_comb begin
        exception_code = HARDWARE_ERROR; // Default to hardware error
        if (interrupt_pending) begin
            if (mip[11])     exception_code = EXTERNAL_INT;
            else if (mip[7]) exception_code = TIMER_INT;
            else if (mip[3]) exception_code = SOFTWARE_INT;
        end else if (exception_pending) begin
            if (illegal_inst)             exception_code = ILLEGAL_INST;
            else if (inst_addr_misalign)  exception_code = INST_ADDR_MISALIGN;
            else if (env_call)            exception_code = ENV_CALL;
            else if (env_break)           exception_code = ENV_BREAK;
            else if (load_addr_misalign)  exception_code = LOAD_ADDR_MISALIGN;
            else if (store_addr_misalign) exception_code = STORE_ADDR_MISALIGN;
        end
    end

    logic [31:0] trap_cause;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            trap_cause <= 32'(HARDWARE_ERROR);
        else if (trap_pending)
            trap_cause <= {interrupt_pending, 31'(exception_code)};
    end

    assign trap_vector = mtvec;
    assign trap_return = mepc;
    assign trap_pending = interrupt_pending | exception_pending;

endmodule

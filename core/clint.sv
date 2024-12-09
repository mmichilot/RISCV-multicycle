`timescale 1ns / 1ps
`include "defs.svh"

/*
 * Core Local INTerruptor (CLINT)
 */
module clint (
    input clk,
    input rst_n,

    // CSR Interface
    input        csr_write,
    input [1:0]  csr_op,
    input [11:0] csr_addr,
    input [31:0] csr_wr_data,
    output logic [31:0] csr_rd_data,

    // External Interrupts
    input interrupts_enabled,
    input [31:0] interrupts,

    // Exceptions
    input illegal_inst,
    input inst_addr_misalign,
    input load_addr_misalign,
    input store_addr_misalign,
    input env_call,
    input env_break,

    // Core Trap Interface
    output logic trap_pending,
    output logic [31:0] trap_cause
    );

    logic interrupt_pending, exception_pending;
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

    assign trap_pending = interrupt_pending | exception_pending;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            trap_cause <= 32'(HARDWARE_ERROR);
        else if (trap_pending)
            trap_cause <= {interrupt_pending, 31'(exception_code)};
    end

    /**
     * CSR Registers
     */

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

    // Setup write data
    logic [31:0] s_wr_data;
    always_comb begin
        unique case (csr_op)
            WRITE:   s_wr_data = csr_wr_data;
            SET:     s_wr_data = csr_rd_data | csr_wr_data;
            CLEAR:   s_wr_data = csr_rd_data & (~csr_wr_data);
            default: s_wr_data = '0;
        endcase
    end

    // CSR read
    always_comb begin
        unique case (csr_addr)            
            MIE:     csr_rd_data = mie;
            MIP:     csr_rd_data = mip;
            default: csr_rd_data = '0;
        endcase
    end

endmodule

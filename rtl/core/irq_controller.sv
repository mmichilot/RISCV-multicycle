`timescale 1ns/1ps
`include "defs.svh"

module irq_controller (
    input clk,
    input rst_n,

    input  logic irq_en,
    input  logic [31:0] mie,
    output logic [31:0] mip,

    // Interrupts & Exceptions
    input logic [31:0] interrupts,
    input logic illegal_inst,
    input logic inst_addr_misalign,
    input logic load_addr_misalign,
    input logic store_addr_misalign,
    input logic env_call,
    input logic env_break,
    
    output logic        trap_pending,
    output logic [31:0] trap_cause
);

    /*
     * MIP CSR
     */
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            mip <= '0;
        else
            mip <= interrupts;
    end

    logic interrupt_pending, exception_pending;
    assign interrupt_pending = |(mip & mie) & irq_en;
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

    assign trap_cause   = {interrupt_pending, 31'(exception_code)};
    assign trap_pending = interrupt_pending | exception_pending;

endmodule

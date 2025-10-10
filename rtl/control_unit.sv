`timescale 1ns / 1ps
`include "defs.svh"

module control_unit (
    input clk,
    input rst_n,
    // verilator lint_off UNUSED
    input [31:0] inst,
    // verilator lint_on UNUSED

    // Trap signals
    input interrupt_pending,
    input exception_pending,
    output logic trap_start,
    output logic trap_finish,

    // Control Signals
    output logic       pc_write,
    output logic       mem_request,
    output logic [1:0] mem_op,
    input  logic       mem_done,
    output logic       reg_write,
    output logic       csr_write
);

    logic [6:0] opcode;
    assign opcode = inst[6:0];

    logic [2:0] func3;
    assign func3 = inst[14:12];

    typedef enum logic [3:0] {FETCH, DECODE, EXECUTE, MEMORY, WB} state_e;
    state_e current_state, next_state;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= FETCH;
        else        current_state <= next_state;
    end


    always_comb begin
        // Defaults
        mem_request = 0;
        mem_op      = INST_READ;
        pc_write    = 0;
        reg_write   = 0;
        csr_write   = 0;
        next_state  = current_state;
        trap_start  = 0;
        trap_finish = 0;

        unique case (current_state)
            FETCH: begin
                if (interrupt_pending) begin
                    pc_write   = 1;
                    trap_start = 1;
                    next_state = FETCH;
                end else begin
                    mem_request = 1;
                    next_state = DECODE;
                end
            end

            DECODE: begin
                if (!mem_done) begin
                    mem_op     = INST_READ;
                    next_state = DECODE;
                end else if (exception_pending) begin
                    pc_write   = 1;
                    trap_start = 1;
                    next_state = FETCH;
                end else
                    next_state = EXECUTE;
            end

            EXECUTE: begin
                unique case(opcode)
                    LUI, AUIPC, OP_IMM, OP, JAL, JALR: begin
                        pc_write  = 1;
                        reg_write = 1;
                        next_state = FETCH;
                    end

                    BRANCH, FENCE: begin
                        pc_write = 1;
                        next_state = FETCH;
                    end

                    LOAD, STORE: begin
                        mem_request = 1;
                        mem_op      = (opcode == LOAD) ? DATA_READ : DATA_WRITE;
                        next_state  = MEMORY;
                    end

                    SYSTEM: begin
                        pc_write = 1;
                        if (func3 != '0) begin // CSR
                            reg_write = 1;
                            csr_write = 1;
                        end else if (inst[31:20] == MRET)
                            trap_finish = 1;
                        
                        next_state = FETCH;
                    end

                    default: ;
                endcase
            end

            MEMORY: begin
                if (!mem_done) begin
                    mem_op     = (opcode == LOAD) ? DATA_READ : DATA_WRITE;
                    next_state = MEMORY;
                end else if (opcode == LOAD)
                    next_state = WB;
                else begin
                    pc_write = 1;
                    next_state = FETCH;
                end
            end

            WB: begin
                pc_write   = 1;
                reg_write  = 1;
                next_state = FETCH;
            end
        endcase
    end

endmodule

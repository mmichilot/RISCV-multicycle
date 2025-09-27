`timescale 1ns / 1ps
`include "defs.svh"

module control_unit (
        input clk,
        input rst_n,
        // verilator lint_off UNUSED
        input [31:0] inst,
        // verilator lint_on UNUSED

        input take_branch,

        // Trap signals
        input trap_pending,
        output logic trap_start,
        output logic trap_finish,

        // Exceptions
        output logic illegal_inst,

        input [31:0] mem_addr,
        output logic inst_addr_misalign,
        output logic load_addr_misalign,
        output logic store_addr_misalign,

        output logic env_call,
        output logic env_break,

        // Control Signals
        output logic pc_write,
        output logic imem_read,
        output logic dmem_read,
        output logic dmem_write,
        output logic reg_write,
        output logic csr_write,

        input logic cpu_stall
    );

    logic [6:0] opcode;
    assign opcode = inst[6:0];

    logic [2:0] func3;
    assign func3 = inst[14:12];

    logic [11:0] func12;
    assign func12 = inst[31:20];

    typedef enum logic [3:0] {FETCH, EXECUTE, MEM, WB, TRAP} state_e;
    state_e current_state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= FETCH;
        else
            current_state <= next_state;
    end


    always_comb begin : output_logic
        // Default values
        imem_read  = 0;
        dmem_read  = 0;
        pc_write   = 0;
        dmem_write = 0;
        reg_write  = 0;
        csr_write  = 0;

        trap_finish = 0;

        inst_addr_misalign = 0;
        load_addr_misalign = 0;
        store_addr_misalign = 0;
        env_call = 0;
        env_break = 0;
        illegal_inst = 0;

        unique case (current_state)
            // Fetch instruction
            FETCH: imem_read = 1;

            // Execute instruction
            EXECUTE: begin
                unique case(opcode)
                    LUI, AUIPC, OP_IMM, OP: begin
                        pc_write  = 1;
                        reg_write = 1;
                    end

                    JAL: begin
                        pc_write = 1;
                        reg_write = 1;
                        inst_addr_misalign = mem_addr[1:0] != 2'b00;
                    end

                    JALR: begin
                        pc_write = 1;
                        reg_write = 1;
                        inst_addr_misalign = mem_addr[1] != 0;

                    end

                    BRANCH: begin
                        pc_write = 1;
                        inst_addr_misalign = mem_addr[1:0] != 2'b00 && take_branch;
                    end

                    FENCE: pc_write = 1;

                    LOAD: begin
                        dmem_read = 1;
                        case (inst[13:12])
                            WORD: load_addr_misalign = |mem_addr[1:0];
                            HALF: load_addr_misalign = mem_addr[0];
                            default: ;
                        endcase
                    end

                    STORE: begin
                        dmem_write = 1;
                        pc_write = 1; // Only update PC when write has completed
                        case (inst[13:12])
                            WORD: store_addr_misalign = |mem_addr[1:0];
                            HALF: store_addr_misalign = mem_addr[0];
                            default: ;
                        endcase
                    end

                    SYSTEM: begin
                        // MRET / ECALL / EBREAK
                        if (func3 == '0) begin
                            pc_write = 1;
                            unique case (func12)
                                ECALL:   env_call = 1;
                                EBREAK:  env_break = 1;
                                MRET:    trap_finish  = 1;
                                default: illegal_inst = 1;
                            endcase

                        // CSR
                        end else begin
                            pc_write  = 1;
                            reg_write = 1;
                            csr_write = 1;
                        end
                    end

                    // Unknown OPCODE
                    default: illegal_inst = 1;
                endcase
            end

            DMEM:

            // Writeback for LOAD-type instructions
            WB: begin
                reg_write = 1;
                pc_write = 1;
            end

            // Setup core for trap
            TRAP: begin
                pc_write = 1;
                trap_start = 1;
            end
        endcase
    end

    always_comb begin : next_state_logic
        unique case (current_state)
            FETCH: begin
                if (trap_pending) next_state = TRAP;
                else              next_state = IMEM;
            end

            IMEM:
                if (cpu_stall) next_state = IMEM;
                else           next_state = EXECUTE;

            EXECUTE: begin
                if (opcode == LOAD | opcode == STORE)
                    next_state = DMEM;
                else if (cpu_stall)
                    next_state = EXECUTE;
                else
                    next_state = FETCH;
            end

            DMEM: begin
                if (cpu_stall) 
                    next_state = DMEM;
                else if (opcode == LOAD)
                    next_state = WB;
                else 
                    next_state = FETCH;
            end

            WB: next_state = FETCH;

            TRAP: next_state = FETCH;

            default: next_state = FETCH;
        endcase
    end

    logic _unused_ok = 1'b0 && &{1'b0,
                        mem_addr[31:2],
                        1'b0};

endmodule

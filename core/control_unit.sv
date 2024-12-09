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
    input [31:0] trap_cause,
    output logic trap_start,
    output logic trap_finish,

    // Exceptions
    output logic illegal_inst,

    input [31:0] inst_addr,
    output logic inst_addr_misalign,
    
    input [31:0] data_addr,
    input [1:0]  data_size,
    input data_addr_misalign,
    output logic load_addr_misalign,
    output logic store_addr_misalign,

    output logic env_call,
    output logic env_break,

    // CPU State signals
    output logic pc_write,
    output logic inst_read,
    output logic data_read,
    output logic data_write,
    output logic reg_write,
    output logic csr_write
    );

    logic [6:0] opcode;
    assign opcode = inst[6:0];

    logic [2:0] func3;
    assign func3 = inst[14:12];

    logic [11:0] func12;
    assign func12 = inst[31:20];
    
    typedef enum logic [2:0] {FETCH, EXECUTE, WB, HALT, TRAP} state_e;
    state_e current_state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)            
            current_state <= FETCH;
        else if (trap_pending && current_state != TRAP) 
            current_state <= TRAP;
        else
            current_state <= next_state;
    end 

    // Internal signals for CPU state
    logic s_pc_write, s_data_write, s_reg_write, s_csr_write;

    always_comb begin : output_logic
        // Default values
        inst_read  = 0;
        data_read  = 0;
        s_pc_write   = 0;
        s_data_write = 0;
        s_reg_write  = 0;
        s_csr_write  = 0;
        
        trap_start = 0;
        trap_finish = 0;

        inst_addr_misalign = 0;
        load_addr_misalign = 0;
        store_addr_misalign = 0;
        env_call = 0;
        env_break = 0;
        illegal_inst = 0;

        unique case (current_state)
            // Fetch instruction
            FETCH: inst_read = 1;

            // Execute instruction
            EXECUTE: begin
                unique case(opcode)
                    LUI, AUIPC, OP_IMM, OP: begin
                        s_pc_write  = 1;
                        s_reg_write = 1;
                    end

                    JAL: begin
                        s_pc_write = 1;
                        s_reg_write = 1;
                        inst_addr_misalign = inst_addr[1:0] != 2'b00;
                    end

                    JALR: begin
                        s_pc_write = 1;
                        s_reg_write = 1;
                        inst_addr_misalign = inst_addr[1] != 0;

                    end

                    BRANCH: begin
                        s_pc_write = 1;
                        inst_addr_misalign = inst_addr[1:0] != 2'b00 && take_branch;
                    end

                    FENCE: s_pc_write = 1;
                    
                    LOAD: begin 
                        data_read = 1;
                        load_addr_misalign = data_addr_misalign;
                    end
                    
                    STORE: begin
                        s_pc_write   = 1;
                        s_data_write = 1;
                        store_addr_misalign = data_addr_misalign;
                    end

                    SYSTEM: begin
                        // MRET / ECALL / EBREAK
                        if (func3 == '0) begin
                            s_pc_write = 1;
                            unique case (func12)
                                ECALL:   env_call = 1;
                                EBREAK:  env_break = 1;
                                MRET:    trap_finish  = 1;
                                default: illegal_inst = 1;
                            endcase
                        
                        // CSR
                        end else begin
                            s_pc_write  = 1;
                            s_reg_write = 1;
                            s_csr_write = 1;
                        end
                    end

                    // Unknown OPCODE
                    default: illegal_inst = 1;
                endcase
            end

            // Writeback for LOAD-type instructions
            WB: begin
                s_reg_write = 1;
                s_pc_write = 1;
            end

            // Disable all control signals when halted
            HALT: begin
                inst_read  = 0;
                data_read  = 0;
                s_pc_write   = 0;
                s_data_write = 0;
                s_reg_write  = 0;
                s_csr_write  = 0;
            end

            // Initiate trap handling
            TRAP: begin
                s_pc_write = 1;
                trap_start = 1;
            end
        endcase
    end

    // Prevent CPU state from updating if there is a trap pending
    always_comb begin : gate_CPU_state
        if (trap_pending) begin
            pc_write   = 0;
            reg_write  = 0;
            data_write = 0;
            csr_write  = 0;
        end else begin
            pc_write   = s_pc_write;
            reg_write  = s_reg_write;
            data_write = s_data_write;
            csr_write  = s_csr_write;
        end
    end

    always_comb begin : next_state_logic        
        unique case (current_state)
            FETCH: next_state = EXECUTE;

            EXECUTE: begin
                if (opcode == LOAD) 
                    next_state = WB;
                else 
                    next_state = FETCH;
            end

            WB: next_state = FETCH;
            
            HALT: next_state = HALT;
            
            TRAP: next_state = FETCH;

            default: next_state = HALT;
        endcase
    end
    
endmodule

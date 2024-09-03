`timescale 1ns / 1ps
`include "defs.svh"

module control_unit (
    input clk,
    input rst,
    // verilator lint_off UNUSED
    input [31:0] inst,
    // verilator lint_on UNUSED
    input error,

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

    typedef enum logic [1:0] {FETCH, EXECUTE, WB, HALT} state_e;
    state_e current_state, next_state;

    always_ff @(posedge clk) begin
        if (rst)        current_state <= FETCH;
        else if (error) current_state <= HALT;
        else            current_state <= next_state;
    end 
                       
    always_comb begin : output_logic
        // Default values
        pc_write   = 0;
        inst_read  = 0;
        data_read  = 0;
        data_write = 0;
        reg_write  = 0;
        csr_write  = 0;

        unique case (current_state)
            // Fetch instruction
            FETCH: inst_read = 1;

            // Execute instruction
            EXECUTE: begin
                unique case(opcode)
                    LUI, AUIPC, OP_IMM, OP, JAL, JALR: begin
                        pc_write  = 1;
                        reg_write = 1;
                    end

                    BRANCH, FENCE: pc_write = 1;
                    
                    LOAD: data_read = 1;
                    
                    STORE: begin
                        pc_write   = 1;
                        data_write = 1;
                    end

                    SYSTEM: begin
                        pc_write  = 1;
                        reg_write = func3 != '0;
                        csr_write = func3 != '0;
                    end

                    default: ;
                endcase
            end

            // Writeback for LOAD-type instructions
            WB: begin                
                reg_write = 1;
                pc_write  = 1;
            end

            // Disable all control signals when halted
            HALT: begin
                pc_write   = 0;
                inst_read  = 0;
                data_read  = 0;
                data_write = 0;
                reg_write  = 0;
                csr_write  = 0;
            end
        endcase
    end

    always_comb begin : next_state_logic
        next_state = current_state;

        unique case (current_state)
            FETCH:   next_state = EXECUTE;
            EXECUTE: begin 
                if (opcode == LOAD) next_state = WB;
                else next_state = FETCH;
            end
            WB:      next_state = FETCH;
            HALT:    next_state = HALT;
            default: next_state = HALT;
        endcase
    end
    
endmodule

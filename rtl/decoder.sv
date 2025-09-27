`timescale 1ns / 1ps
`include "defs.svh"

module decoder(
    input [6:0] opcode,
    input [2:0] func3,
    // verilator lint_off UNUSED
    input [6:0] func7,
    // verilator lint_on UNUSED

    input take_branch,
    input trap_start,
    input trap_finish,
    input cpu_stall,

    output logic [2:0] immed_type,

    output logic [1:0] alu_a_src,
    output logic alu_b_src,
    output logic [3:0] alu_op,
    output logic [1:0] reg_src,
    output logic [2:0] pc_src
    );

    // Immediate MUX
    always_comb begin
        unique case(opcode)
           LUI,AUIPC: immed_type = U_IMMED;
           JAL:       immed_type = J_IMMED;
           BRANCH:    immed_type = B_IMMED;
           STORE:     immed_type = S_IMMED;
           OP_IMM, LOAD, SYSTEM: immed_type = I_IMMED;
           default:   immed_type = '0;
        endcase
    end

    // ALU Source MUX
    always_comb begin
        unique case(opcode)
            LUI: begin
                alu_a_src = ZERO;
                alu_b_src = IMMED;
            end

            AUIPC, JAL, BRANCH: begin
                alu_a_src = CURR_PC;
                alu_b_src = IMMED;
            end

            JALR, LOAD, STORE, OP_IMM: begin
                alu_a_src = RS1;
                alu_b_src = IMMED;
            end

            OP: begin
                alu_a_src = RS1;
                alu_b_src = RS2;
            end

            default: begin
                alu_a_src = '0;
                alu_b_src = '0;
            end
        endcase
    end

    // Register File Source MUX
    always_comb begin
        unique case(opcode)
            LUI, AUIPC, OP_IMM, OP: reg_src = ALU;
            JAL, JALR:              reg_src = NEXT_PC;
            LOAD, STORE:            reg_src = MEM;
            SYSTEM:                 reg_src = CSR;
            default:                reg_src = '0;
        endcase
    end

    // PC Source MUX
    always_comb begin
        if (trap_start)       pc_src = CSR_MTVEC;
        else if (trap_finish) pc_src = CSR_MEPC;
        else if (cpu_stall)   pc_src = CURR_PC;  
        else begin
            unique case(opcode)
                LUI, AUIPC, OP_IMM, OP, LOAD, STORE: pc_src = PC_PLUS_4;
                JAL:  pc_src = ALU_OUT;
                JALR: pc_src = LSB_ZERO;
                BRANCH:    pc_src = take_branch ? ALU_OUT : PC_PLUS_4;
                default:   pc_src = PC_PLUS_4;
            endcase
        end
    end

    // ALU Operation
    localparam SHIFT_RIGHT = 3'b101;
    always_comb begin
        unique case(opcode)
            LUI, AUIPC, JAL, JALR, BRANCH, LOAD, STORE : alu_op = ADD;
            OP: alu_op = {func7[5], func3};
            OP_IMM: alu_op = (func3 == SHIFT_RIGHT) ? {func7[5], func3} : {1'b0, func3};
            default:    alu_op = '0;
        endcase
    end

endmodule

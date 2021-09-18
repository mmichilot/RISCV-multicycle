`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2019 11:51:23 AM
// Design Name: 
// Module Name: ControlUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module control_unit(
    input clk,
    input rst,
    input [6:0] opcode,
    input error,

    output logic enBranch,
    output logic pcUpdate,
    output logic irWrite,
    output logic addrSrc,
    output logic memWrite,
    output logic memRead,
    output logic [1:0] regSrc,
    output logic regWrite,
    output logic [1:0] aluSrcA,
    output logic [1:0] aluSrcB,
    output logic aluCtrl
    );

    /* verilator lint_off UNUSED */
    enum logic [6:0] {
        LUI      = 7'b0110111,
        AUIPC    = 7'b0010111,
        JAL      = 7'b1101111,
        JALR     = 7'b1100111,
        BRANCH   = 7'b1100011,
        LOAD     = 7'b0000011,
        STORE    = 7'b0100011,
        OP_IMM   = 7'b0010011,
        OP       = 7'b0110011,
        SYSTEM   = 7'b1110011
    } opcode_e;

    enum logic {PC_OUT,ALU_OUT} addrSrc_e;
    enum logic [1:0] {PC,ALU,MEM} regSrc_e;
    enum logic [1:0] {CURR_PC,OLD_PC,RS1,ZERO} aluSrcA_e;
    enum logic [1:0] {RS2,IMMED,FOUR} aluSrcB_e;
    enum logic {ADD_OP,ALU_OP} aluCtrl_e;
    
    /* verilator lint_on UNUSED */

    typedef enum logic[2:0] {MEMREAD,FETCH,EXECUTE,WB,HALT} state_e;
    state_e state, next;

    always_ff @(posedge clk) begin :  present_state_logic
        if (rst)        state <= MEMREAD;
        else if (error) state <= HALT;
        else            state <= next;
    end 
                       
    always_comb begin : output_logic
        enBranch = 0;
        pcUpdate = 0;
        irWrite  = 0;
        addrSrc  = 0;
        memWrite = 0;
        memRead  = 0;
        regSrc   = 0;
        regWrite = 0;
        aluSrcA  = 0;
        aluSrcB  = 0;
        aluCtrl  = 0;

        case (state)
            MEMREAD: begin
                addrSrc = PC_OUT;
                memRead = 1;
            end

            FETCH: begin
                irWrite  = 1;

                aluSrcA  = CURR_PC;
                aluSrcB  = FOUR;
                aluCtrl  = ADD_OP;
                pcUpdate = 1;
            end

            EXECUTE: begin
                case(opcode)
                    LUI: begin
                        aluSrcA = ZERO;
                        aluSrcB = IMMED;
                        aluCtrl = ADD_OP;

                        regSrc   = ALU;
                        regWrite = 1;
                    end

                    AUIPC: begin
                        aluSrcA = OLD_PC;
                        aluSrcB = IMMED;
                        aluCtrl = ADD_OP;

                        regSrc   = ALU;
                        regWrite = 1;
                    end

                    JAL: begin
                        aluSrcA = OLD_PC;
                        aluSrcB = IMMED;
                        aluCtrl = ADD_OP;

                        regSrc   = PC;
                        regWrite = 1;

                        pcUpdate = 1;
                    end

                    JALR: begin
                        aluSrcA = RS1;
                        aluSrcB = IMMED;
                        aluCtrl = ADD_OP;

                        regSrc   = PC;
                        regWrite = 1;

                        pcUpdate = 1;
                    end

                    BRANCH: begin
                        aluSrcA = OLD_PC;
                        aluSrcB = IMMED;
                        aluCtrl = ADD_OP;

                        enBranch = 1;
                    end

                    LOAD: begin
                        aluSrcA = RS1;
                        aluSrcB = IMMED;
                        aluCtrl = ADD_OP;

                        addrSrc = ALU_OUT;
                        memRead = 1;
                    end

                    STORE: begin
                        aluSrcA = RS1;
                        aluSrcB = IMMED;
                        aluCtrl = ADD_OP;

                        addrSrc   = ALU_OUT;
                        memWrite  = 1;
                    end

                    OP_IMM: begin
                        aluSrcA = RS1;
                        aluSrcB = IMMED;
                        aluCtrl = ALU_OP;

                        regSrc   = ALU;
                        regWrite = 1;
                    end

                    OP: begin
                        aluSrcA = RS1;
                        aluSrcB = RS2;
                        aluCtrl = ALU_OP;

                        regSrc   = ALU;
                        regWrite = 1;
                    end

                    default: begin
                        enBranch = 0;
                        pcUpdate = 0;
                        irWrite  = 0;
                        addrSrc  = 0;
                        memWrite = 0;
                        memRead  = 0;
                        regSrc   = 0;
                        regWrite = 0;
                        aluSrcA  = 0;
                        aluSrcB  = 0;
                        aluCtrl  = 0;
                    end
                endcase
            end

            WB: begin
                aluSrcA = RS1;
                aluSrcB = IMMED;
                aluCtrl = ADD_OP;

                addrSrc = ALU_OUT;

                regSrc   = MEM;
                regWrite = 1;
            end

            HALT: begin
                enBranch = 0;
                pcUpdate = 0;
                irWrite  = 0;
                addrSrc  = 0;
                memWrite = 0;
                memRead  = 0;
                regSrc   = 0;
                regWrite = 0;
                aluSrcA  = 0;
                aluSrcB  = 0;
                aluCtrl  = 0;
            end

            default: begin
                enBranch = 0;
                pcUpdate = 0;
                irWrite  = 0;
                addrSrc  = 0;
                memWrite = 0;
                memRead  = 0;
                regSrc   = 0;
                regWrite = 0;
                aluSrcA  = 0;
                aluSrcB  = 0;
                aluCtrl  = 0;
            end
        endcase
    end

    always_comb begin : next_state_logic
        case (state)
            MEMREAD: next = FETCH;
            FETCH:   next = EXECUTE;
            EXECUTE: begin 
                if (opcode == LOAD) next = WB;
                else next = MEMREAD;
            end
            WB:      next = MEMREAD;
            HALT:    next = HALT;
            default: next = HALT;
        endcase
    end
    
endmodule

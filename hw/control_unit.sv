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

    output logic pcUpdate,
    output logic irWrite,
    output logic addrSrc,
    output logic memWrite,
    output logic memRead,
    output logic [1:0] regSrc,
    output logic regWrite,
    output logic [2:0] immedSrc,
    output logic [1:0] aluSrcA,
    output logic [1:0] aluSrcB,
    output logic [2:0] aluOp
    );

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

    typedef enum logic[2:0] {MEMREAD,FETCH,EXECUTE,WB,HALT} state_e;
    state_e state, next;

    always_ff @(posedge clk) begin :  present_state_logic
        if (rst)        state <= MEMREAD;
        else if (error) state <= HALT;
        else            state <= next;
    end 
                       
    always_comb begin : output_logic
        pcUpdate = 0;
        regWrite = 0;
        memWrite = 0;
        memRead  = 0;
        irWrite  = 0;

        case (state)
            MEMREAD: begin

                memRead = 1;
            end

            FETCH: begin
                irWrite  = 1;
                pcUpdate = 1;
            end

            EXECUTE: begin
                regWrite = 1;
            end

            WB: begin
                memWrite = 1;
            end

            HALT: begin
                pcUpdate = 0;
                regWrite = 0;
                memWrite = 0;
                memRead  = 0;
                irWrite  = 0;
            end

            default: begin
                pcUpdate = 0;
                regWrite = 0;
                memWrite = 0;
                memRead  = 0;
                irWrite  = 0;
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

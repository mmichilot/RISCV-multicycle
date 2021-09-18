`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: J. Callenes
// 
// Create Date: 01/27/2019 09:22:55 AM
// Design Name: 
// Module Name: CU_Decoder
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

module decoder(
    input [6:0] opcode,
    input [2:0] func3,
    /* verilator lint_off UNUSED */
    input [6:0] func7,
    /* verilator lint_on UNUSED */
    input aluCtrl,

    output logic [2:0] immedSrc,
    output logic [3:0] aluOp
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

    enum logic [2:0] {
        ADD_FUNC  = 3'b000,
        SLT_FUNC  = 3'b010,
        SLTU_FUNC = 3'b011,
        XOR_FUNC  = 3'b100,
        OR_FUNC   = 3'b110,
        AND_FUNC  = 3'b111,
        SLL_FUNC  = 3'b001,
        SRL_FUNC  = 3'b101
    } func3_e;

    enum logic [2:0] {I_IMMED,S_IMMED,B_IMMED,U_IMMED,J_IMMED} immedSrc_e;
    enum logic {ADD_OP,ALU_OP} aluCtrl_e;

    enum logic [3:0] {
        ADD,
        SUB,
        SLL,
        SLT,
        SLTU,
        XOR,
        SRL,
        SRA,
        OR,
        AND
    } aluOp_e;

    /* verilator lint_on UNUSED */

    always_comb begin : immedSrc_logic
        case(opcode)
           LUI,AUIPC: immedSrc = U_IMMED;
           JAL:       immedSrc = J_IMMED;
           BRANCH:    immedSrc = B_IMMED;
           LOAD:      immedSrc = I_IMMED;
           STORE:     immedSrc = S_IMMED;
           OP_IMM:    immedSrc = I_IMMED;
           default:   immedSrc = 0;
        endcase
    end

    always_comb begin : aluOp_logic
        case(aluCtrl)
            ADD_OP: aluOp = ADD;
            ALU_OP: begin
                case(func3)
                    ADD_FUNC:  aluOp = ({opcode[5],func7[5]} == 2'b11) ? SUB : ADD;
                    SLT_FUNC:  aluOp = SLT;
                    SLTU_FUNC: aluOp = SLTU;
                    XOR_FUNC:  aluOp = XOR;
                    OR_FUNC:   aluOp = OR;
                    AND_FUNC:  aluOp = AND;
                    SLL_FUNC:  aluOp = SLL;
                    SRL_FUNC:  aluOp = (func7[5]) ? SRA : SRL;
                endcase
            end
            default: aluOp = ADD;
        endcase
    end

endmodule

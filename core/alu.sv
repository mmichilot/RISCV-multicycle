`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: J. Callenes 
// 
// Create Date: 06/07/2018 05:03:50 PM
// Design Name: 
// Module Name: arithLogicUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module alu(
    input [3:0] aluOp,
    input [31:0] a,b,
    output logic [31:0] out
    );
    
    /* verilator lint_off UNUSED */
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
    
    always_comb begin
        case(aluOp)
            ADD:  out = a + b;
            SUB:  out = a - b;
            SLL:  out = a << b;
            SLT:  out = signed'(a) < signed'(b) ? 1 : 0;
            SLTU: out = a < b ? 1 : 0;
            XOR:  out = a ^ b;
            SRL:  out = a >> b;
            SRA:  out = a >>> b;
            OR:   out = a | b;
            AND:  out = a & b;
            default: out = 0;
        endcase
    end
endmodule

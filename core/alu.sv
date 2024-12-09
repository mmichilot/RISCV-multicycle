`timescale 1ns / 1ps
`include "defs.svh"

module alu(
    input [3:0] op,
    input [31:0] a,b,
    output logic [31:0] out
    );
    
    always_comb begin
        unique case(op)
            ADD:  out = a + b;
            SUB:  out = a - b;
            SLL:  out = a << b[4:0];
            SLT:  out = signed'(a) < signed'(b) ? 32'd1 : 32'd0;
            SLTU: out = a < b ? 32'd1 : 32'd0;
            XOR:  out = a ^ b;
            SRL:  out = a >> b[4:0];
            SRA:  out = signed'(a) >>> b[4:0];
            OR:   out = a | b;
            AND:  out = a & b;
            default: out = '0;
        endcase
    end
endmodule

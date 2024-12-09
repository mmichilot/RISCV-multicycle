`timescale 1ns / 1ps
`include "defs.svh"

module immed_gen 
    (
        // verilator lint_off UNUSED
        input [31:0] inst,
        // verilator lint_on UNUSED
        input [2:0]  immed_type,

        output logic [31:0] immed
    );

    always_comb begin
        case(immed_type)
            I_IMMED: immed = 32'(signed'(inst[31:20]));
            S_IMMED: immed = 32'(signed'({inst[31:25],inst[11:7]}));
            B_IMMED: immed = 32'(signed'({inst[31],inst[7],inst[30:25],inst[11:8],1'b0}));
            U_IMMED: immed = {inst[31:12], 12'b0};
            J_IMMED: immed = 32'(signed'({inst[31],inst[19:12],inst[20],inst[30:21],1'b0}));
            default: immed = '0;
        endcase
    end

endmodule

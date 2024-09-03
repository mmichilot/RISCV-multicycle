`timescale 1ns / 1ps
`include "defs.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: M. Michilot
// 
// Create Date: 01/27/2019 08:37:11 AM
// Design Name: OTTER Immediate Generator
// Module Name: immed_gen
// Project Name: OTTER CPU
// Target Devices: N/A
// Tool Versions: 
// Description: Generates the immediates
// 
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

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

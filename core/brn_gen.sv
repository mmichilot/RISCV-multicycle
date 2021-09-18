`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: M. Michilot
// 
// Create Date: 01/27/2019 08:37:11 AM
// Design Name: Branch Condition Generator
// Module Name: brn_gen
// Project Name: OTTER CPU
// Target Devices: N/A
// Tool Versions: 
// Description: Generates the conditional branch signal
// 
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module brn_gen
    (
        input [31:0] rs1,
        input [31:0] rs2,
        input [2:0] func3,

        output logic takeBranch
    );

    /* verilator lint_off UNUSED */
    enum logic [2:0] {
        BEQ  = 3'b000,
        BNE  = 3'b001,
        BLT  = 3'b100,
        BGE  = 3'b101,
        BLTU = 3'b110,
        BGEU = 3'b111
    } brnFunc_e;
    /* verilator lint_on UNUSED */

    logic result;

    always_comb begin : comparator
        case(func3)
            BEQ,BNE: result = (rs1 == rs2);
            BLT,BGE: result = (signed'(rs1) < signed'(rs2));
            BLTU,BGEU : result = (rs1 < rs2);
            default: result = 0;
        endcase
    end

    always_comb begin : output_set
        case(func3)
            BEQ,BLT,BLTU: takeBranch = result;
            BNE,BGE,BGEU: takeBranch = ~result;
            default: takeBranch = 0;
        endcase
    end

endmodule

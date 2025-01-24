`timescale 1ns / 1ps

module branch_gen
    (
        input [31:0] rs1,
        input [31:0] rs2,
        input [2:0] func3,

        output logic take_branch
    );

    /* verilator lint_off UNUSED */
    enum logic [2:0] {
        BEQ  = 3'b000,
        BNE  = 3'b001,
        BLT  = 3'b100,
        BGE  = 3'b101,
        BLTU = 3'b110,
        BGEU = 3'b111
    } branch_func_e;
    /* verilator lint_on UNUSED */

    logic result;

    always_comb begin : comparator
        case(func3)
            BEQ,BNE:   result = (rs1 == rs2);
            BLT,BGE:   result = (signed'(rs1) < signed'(rs2));
            BLTU,BGEU: result = (rs1 < rs2);
            default:   result = 0;
        endcase
    end

    always_comb begin : output_set
        case(func3)
            BEQ,BLT,BLTU: take_branch = result;
            BNE,BGE,BGEU: take_branch = ~result;
            default:      take_branch = 0;
        endcase
    end

endmodule

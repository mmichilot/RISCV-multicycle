`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: M. Michilot
// 
// Create Date: 01/27/2019 08:37:11 AM
// Design Name: OTTER Size and Extend
// Module Name: sz_ex
// Project Name: OTTER CPU
// Target Devices: N/A
// Tool Versions: 
// Description: Combo logic that splices and extends data
// 
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module sz_ex (
    input [31:0] data,
    
    input [1:0] byte_sel,
    input [1:0] size,
    input sign,

    output logic [31:0] out
);

    /* verilator lint_off UNUSED */
    enum logic {
        SIGNED = 1'b0,
        UNSIGNED = 1'b1
    } sign_e;

    enum logic [1:0] {
        BYTE = 2'b00,
        HALF = 2'b01,
        WORD = 2'b10
    } size_e;
    /* verilator lint_on UNUSED */

    always_comb begin
        out = data;

        case(sign)
            SIGNED: begin
                case(size)
                    BYTE:    out = 32'(signed'(data[8*byte_sel +: 8]));
                    HALF:    out = 32'(signed'(data[8*byte_sel +: 16]));
                    default: out = data;
                endcase
            end

            UNSIGNED: begin
                case (size)
                    BYTE:    out = 32'(data[8*byte_sel +: 8]);
                    HALF:    out = 32'(data[8*byte_sel +: 16]);
                    default: out = data;
                endcase
            end
        endcase
    end

endmodule

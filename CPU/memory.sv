`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: J. Callenes, M. Michilot
// 
// Create Date: 01/27/2019 08:37:11 AM
// Design Name: OTTER Basic Memory
// Module Name: memory
// Project Name: OTTER CPU
// Target Devices: N/A
// Tool Versions: 
// Description: Basic memory module for the OTTER CPU
// 
// Dependencies: bram - Used to initialize and infer
//                      single-port block RAM w/ Byte Enable.
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module memory 
    #(
        parameter ADDR_WIDTH = 13,
        parameter BUS_WIDTH = 32,
    )

    (
        input clk,
        input we,
        input [BUS_WIDTH-1:0] addr,
        input [BUS_WIDTH-1:0] data,
        output logic [BUS_WIDTH-1:0] out,

        input [1:0] size,
        input sign,
        output logic error
    );

    localparam MAX_ADDR = (2**ADDR_WIDTH)-1;

    enum {
        BYTE = 2'b00,
        HALF = 2'b01,
        WORD = 2'b10
    } e_size;

    enum {
        SIGNED = 1'b0,
        UNSIGNED = 1'b1
    } e_sign;

    // Signals
    logic [ADDR_WIDTH-1:0] s_addr;
    logic [3:0] s_we;
    logic [BUS_WIDTH-1:0] s_out;
    logic [1:0] byte_sel = addr[1:0];

    // RAM Instantiation
    (* keep=1 *)
    (* keep_hierarchy=1 *)
    bram #(
        .RAM_ADDR_WIDTH(ADDR_WIDTH),
        .RAM_BUS_WIDTH(BUS_WIDTH)
    ) ram (
        .clk(clk),
        .we(s_we),
        .addr(s_addr),
        .data(data),
        .out(s_out)
    );

    assign s_addr = {addr[ADDR_WIDTH-1:2], 2'b0};

    always_comb begin : addr_check
        error = 0;
 
        if (addr > MAX_ADDR) // Address space 
            error = 1;
        else if (size == WORD && addr[1:0] != 2'b0) // Word boundary
            error = 1;
        else if (size == HALF && addr[0] != 0) // Half-word boundary
            error = 1;
    end

    always_comb begin : byte_en_set
        s_we = 4'b0;

        if (we) begin
            case(size)
                BYTE: s_we[byte_sel] = 1'b1;
                HALF: s_we[byte_sel +: 2] = 2'b1;
                WORD: s_we = 4'b1;
            endcase
        end 
    end

    always_comb begin : splice_output
        out = s_out;

        case(sign)
            SIGNED: begin
                case(size)
                    BYTE: out = 32'(signed'(s_out[8*byte_sel +: 8]));
                    HALF: out = 32'(signed'(s_out[8*byte_sel +: 16]));
                endcase
            end

            UNSIGNED: begin
                case (size)
                    BYTE: out = 32'(s_out[8*byte_sel +: 8]);
                    HALF: out = 32'(s_out[8*byte_sel +: 16]);
                endcase
            end
        endcase
    end

endmodule
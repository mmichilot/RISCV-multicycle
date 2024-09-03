`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: J. Callenes, M. Michilot
// 
// Create Date: 01/27/2019 08:37:11 AM
// Design Name: SRAM memory module
// Module Name: sram
// Project Name: OTTER CPU
// Target Devices: N/A
// Tool Versions: 
// Description: SRAM used for memory
// Interface: Wishbone
// Dependencies: bram - Used to initialize and infer
//                      single-port block RAM w/ Byte Enable.
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module sram
    #(
        parameter ADDR_WIDTH = 25,
        parameter BUS_WIDTH = 32
    ) (
        input clk,

        // Port A (Read)
        input read_A,
        // verilator lint_off UNUSED
        input [31:0] addr_A,
        // verilator lint_on UNUSED
        output logic [31:0] data_A,

        // Port B (Write w/ Byte Enable + Read w/ Byte Slicing)
        input read_B,
        input write_B,
        input sign_B,
        input [1:0] size_B,
        // verilator lint_off UNUSED
        input [31:0] addr_B,
        // verilator lint_on UNUSED
        input [31:0] wr_data_B,
        output logic [31:0] rd_data_B
    );

    localparam RAM_ADDR_WIDTH = ADDR_WIDTH-2;

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

    // Raw memory block
    (* syn_ramstyle="block_ram" *)
    logic [BUS_WIDTH-1:0] mem [0:(2**RAM_ADDR_WIDTH)-1];

    // Signals
    logic [BUS_WIDTH-1:0] s_addr_A, s_addr_B;
    logic [BUS_WIDTH-1:0] s_data_A ,s_data_B;
    logic [3:0] s_we;
    logic [1:0] byte_sel;

    assign s_addr_A = addr_A >> 2;
    assign s_addr_B = addr_B >> 2;
    assign byte_sel = addr_B[1:0];

    // Setup write data
    logic [31:0] s_write_data;
    always_comb begin
        s_write_data = '0;
        case (size_B)
            BYTE: s_write_data = wr_data_B << (8 * byte_sel);
            HALF: s_write_data = wr_data_B << (16 * byte_sel[1]);
            WORD: s_write_data = wr_data_B;
            default: s_write_data = wr_data_B;
        endcase
    end
    
    // Setup write-enable bits for write data
    always_comb begin
        s_we = '0;
        if (write_B) begin
            case (size_B)
                BYTE: s_we = (4'b0001 << byte_sel);
                HALF: s_we = (4'b0011 << byte_sel);
                WORD: s_we = 4'b1111;
                default: s_we = '0; 
            endcase
        end
    end

    // Bit slicing for read data
    always_comb begin
        case(sign_B)
            SIGNED: begin
                case(size_B)
                    BYTE:    rd_data_B = 32'(signed'(s_data_B[8*byte_sel +: 8]));
                    HALF:    rd_data_B = 32'(signed'(s_data_B[8*byte_sel +: 16]));
                    default: rd_data_B = s_data_B;
                endcase
            end

            UNSIGNED: begin
                case (size_B)
                    BYTE:    rd_data_B = 32'(s_data_B[8*byte_sel +: 8]);
                    HALF:    rd_data_B = 32'(s_data_B[8*byte_sel +: 16]);
                    default: rd_data_B = s_data_B;
                endcase
            end
        endcase
    end

   // Port A (Instruction)
    always_ff @(posedge clk) begin
        // Read
        if (read_A)
            s_data_A <= mem[s_addr_A[RAM_ADDR_WIDTH-1:0]];
    end

    // Port B (Data)
    always_ff @(posedge clk) begin
        // Read
        if (read_B)
            s_data_B <= mem[s_addr_B[RAM_ADDR_WIDTH-1:0]];
      
        // Write
        if (s_we > 0) begin
            integer i;
            for (i = 0; i < 4; i++) begin
                if (s_we[i])
                    mem[s_addr_B][8*i +: 8] <= s_write_data[8*i +: 8];
            end
        end
    end

    assign data_A = s_data_A;

endmodule

`timescale 1ns / 1ps

module csr (
    input clk,
    input rst,

    input [1:0]  op,
    input [11:0] addr,
    input we,
    input [31:0] wr_data,
    
    output logic [31:0] rd_data
    );

    // verilator lint_off UNUSED
    enum logic [1:0] {
        NOP   = 2'b00,
        WRITE = 2'b01,
        SET   = 2'b10, 
        CLEAR = 2'b11
    } csr_op_e;
    // verilator lint_on UNUSED

    typedef enum logic [11:0] {
        MVENDORID = 12'hF11,
        MARCHID   = 12'hF12,
        MIMPID    = 12'hF13,
        MHARTID   = 12'hF14,
        MSTATUS   = 12'h300,
        MISA      = 12'h301,
        MIE       = 12'h304,
        MTVEC     = 12'h305,
        MEPC      = 12'h341
    } mcsr_e;

    // Machine-level CSRs
    logic [31:0] mvendorid = '0;
    logic [31:0] marchid = '0;
    logic [31:0] mimpid = '0;
    logic [31:0] mhartid = '0;
    logic [31:0] mstatus = '0;
    logic [31:0] misa = 32'h40000100;
    logic [31:0] mie = '0;
    logic [31:0] mtvec = '0;
    logic [31:0] mepc = '0;

    // CSR read
    always_comb begin
        unique case (addr)
            MVENDORID: rd_data = mvendorid;
            MARCHID:   rd_data = marchid;
            MIMPID:    rd_data = mimpid;
            MHARTID:   rd_data = mhartid;
            MSTATUS:   rd_data = mstatus;
            MISA:      rd_data = misa;
            MIE:       rd_data = mie;
            MTVEC:     rd_data = mtvec;
            MEPC:      rd_data = mepc;
            default:   rd_data = '0;
        endcase
    end

    // Setup write data (Write, Set, or Clear)
    logic [31:0] wr_data_int;
    always_comb begin
        unique case (op)
            WRITE: wr_data_int = wr_data;
            SET:   wr_data_int = rd_data | wr_data;
            CLEAR: wr_data_int = rd_data & (~wr_data);
            default: ;
        endcase
    end

    // CSR write
    always_ff @(posedge clk) begin
        if (rst) begin
            mstatus <= '0;
            misa    <= 32'h40000100;
            mie     <= '0;
            mtvec   <= '0;
            mepc    <= '0;
        end else if (we) begin
            unique case (addr)
                MSTATUS: mstatus <= wr_data_int;
                MISA:    misa    <= wr_data_int;
                MIE:     mie     <= wr_data_int;
                MTVEC:   mtvec   <= wr_data_int;
                MEPC:    mepc    <= wr_data_int;
                default: ;
            endcase
        end
    end

endmodule

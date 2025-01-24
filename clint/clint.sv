`timescale 1ns / 1ps

module clint
    #(
        parameter BASE_ADDR = 32'h0200_0000
    )(
        input clk,
        input rst_n,

        // Memory Interface
        input read,
        input write,
        input [31:0] addr,
        input [1:0] size,
        output logic [31:0] read_data,
        input [31:0] write_data,

        // Interrupts
        output logic software_int,
        output logic timer_int
    );



    // MSIP
    localparam MSIP_ADDR = BASE_ADDR + 'h0;
    logic msip;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            msip <= 1'b0;
        else if (write && addr == MSIP_ADDR)
            msip <= write_data[0];
    end

    assign software_int = msip;

    // MTIME
    localparam MTIME_BASE_ADDR = BASE_ADDR + 'hBFF8;
    localparam MTIME_LO_ADDR = MTIME_BASE_ADDR;
    localparam MTIME_HI_ADDR = MTIME_BASE_ADDR + 4;
    logic [63:0] mtime;
    assign mtime = {mtime_hi, mtime_lo};
    logic [31:0] mtime_hi_next, mtime_lo_next;
    assign {mtime_hi_next, mtime_lo_next} = mtime + 1;

    logic [31:0] mtime_lo;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            mtime_lo <= '0;
        else if (write && addr == MTIME_LO_ADDR)
            mtime_lo <= write_data;
        else
            mtime_lo <= mtime_lo_next;
    end

    logic [31:0] mtime_hi;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            mtime_hi <= '0;
        else if (write && addr == MTIME_HI_ADDR)
            mtime_hi <= write_data;
        else
            mtime_hi <= mtime_hi_next;
    end

    // MTIMECMP
    localparam MTIMECMP_BASE_ADDR = BASE_ADDR + 'h4000;
    localparam MTIMECMP_LO_ADDR = MTIMECMP_BASE_ADDR;
    localparam MTIMECMP_HI_ADDR = MTIMECMP_BASE_ADDR + 4;
    logic [63:0] mtimecmp;
    assign mtimecmp = {mtimecmp_hi, mtimecmp_lo};

    logic [31:0] mtimecmp_lo;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            mtimecmp_lo <= '0;
        else if (write && addr == MTIMECMP_LO_ADDR)
            mtimecmp_lo <= write_data;
    end

    logic [31:0] mtimecmp_hi;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            mtimecmp_hi <= '0;
        else if (write && addr == MTIMECMP_HI_ADDR)
            mtimecmp_hi <= write_data;
    end

    assign timer_int = mtime >= mtimecmp;

    // Read
    always_comb begin
        read_data = '0;
        if (read) begin
            unique case (addr)
                MSIP_ADDR:        read_data = 32'(msip);
                MTIME_LO_ADDR:    read_data = mtime_lo;
                MTIME_HI_ADDR:    read_data = mtime_hi;
                MTIMECMP_LO_ADDR: read_data = mtimecmp_lo;
                MTIMECMP_HI_ADDR: read_data = mtimecmp_hi;
                default: ;
            endcase
        end
    end

endmodule

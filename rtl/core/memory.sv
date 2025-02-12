`timescale 1ns/1ps
`include "defs.svh"

module memory (
    input clk_i,
    input rst_i,

    input  logic        imem_read,
    output logic        imem_ready,
    input  logic [31:0] imem_addr,
    output logic [31:0] instruction,

    input  logic        dmem_read,
    input  logic        dmem_write,
    output logic        dmem_ready,
    input  logic [1:0]  dmem_size,
    input  logic        dmem_sign,
    input  logic [31:0] dmem_addr,
    input  logic [31:0] dmem_wdata,
    output logic [31:0] data,

    // Wishbone interface
    output logic        wb_cyc_o,
    output logic        wb_stb_o,
    input  logic        wb_stall_i,
    input  logic        wb_ack_i,
    output logic        wb_we_o,
    output logic [3:0]  wb_sel_o,
    output logic [31:0] wb_adr_o,
    output logic [31:0] wb_dat_o,
    input  logic [31:0] wb_dat_i
);

    /*
     * Wishbone Handshake
     */
    typedef enum logic [1:0] {IDLE, REQUEST, WAIT4ACK} state_e;

    state_e current_state, next_state;
    always_ff @(posedge clk_i) begin : state_reg
        if (rst_i) current_state <= IDLE;
        else       current_state <= next_state;
    end

    logic mem_request;
    assign mem_request = imem_read | dmem_read | dmem_write;

    always_comb begin : next_state_logic
        case (current_state)
            IDLE:     next_state = (mem_request & ~wb_ack_i) ? REQUEST : IDLE;

            REQUEST: begin
                if (~wb_stall_i & wb_ack_i) // For async ack
                    next_state = IDLE;
                else if (~wb_stall_i)
                    next_state = WAIT4ACK;
                else
                    next_state = REQUEST;
            end

            WAIT4ACK: next_state = wb_ack_i ? IDLE : WAIT4ACK;

            default:  next_state = current_state;
        endcase
    end

    always_comb begin : output_logic
        case (current_state)
            IDLE: begin
                wb_cyc_o = 0;
                wb_stb_o = 0;
            end

            REQUEST: begin
                wb_cyc_o = 1;
                wb_stb_o = 1;
            end

            WAIT4ACK: begin
                wb_cyc_o = 1;
                wb_stb_o = 0;
            end

            default: begin
                wb_cyc_o = 0;
                wb_stb_o = 0;
            end
        endcase
    end

    // Invalidate a wishbone transfer if memory request ever goes low and an ack
    // has not been received.
    // For example, an interrupt occurs during a transfer to a synchronous device
    logic invalid_req;
    always_ff @(posedge clk_i) begin
        if ((current_state != IDLE) && !mem_request && !wb_ack_i)
            invalid_req <= '1;
        else if (invalid_req & wb_ack_i)
            invalid_req <= '0;
    end

    /*
     * Wishbone MUX
     */
    always_comb begin
        if (imem_read) begin
            wb_adr_o = imem_addr;
            wb_we_o  = 0;
            wb_sel_o = 4'b1111;
        end else if (dmem_read | dmem_write) begin
            wb_adr_o = dmem_addr;
            wb_we_o  = dmem_write;
            case (dmem_size)
                BYTE:    wb_sel_o = (4'b0001 << dmem_addr[1:0]);
                HALF:    wb_sel_o = (4'b0011 << dmem_addr[1:0]);
                WORD:    wb_sel_o = 4'b1111;
                default: wb_sel_o = 4'b0000;
            endcase
        end else begin
            wb_adr_o = '0;
            wb_we_o  = 0;
            wb_sel_o = 4'b0000;
        end
    end

    /*
     * Wishone DAT_O() Setup
     */
    always_comb begin
        case (dmem_size)
            BYTE:    wb_dat_o = dmem_wdata << (8 * dmem_addr[1:0]);
            HALF:    wb_dat_o = dmem_wdata << (16 * dmem_addr[1]);
            WORD:    wb_dat_o = dmem_wdata;
            default: wb_dat_o = dmem_wdata;
        endcase
    end


    /*
     * Wishbone DAT_I() Setup
     */
    logic [31:0] data_next;
    always_comb begin
        case(dmem_sign)
            SIGNED: begin
                case(dmem_size)
                    BYTE:    data_next = 32'(signed'(wb_dat_i[8*dmem_addr[1:0] +: 8]));
                    HALF:    data_next = 32'(signed'(wb_dat_i[8*dmem_addr[1:0] +: 16]));
                    default: data_next = wb_dat_i;
                endcase
            end

            UNSIGNED: begin
                case (dmem_size)
                    BYTE:    data_next = 32'(wb_dat_i[8*dmem_addr[1:0] +: 8]);
                    HALF:    data_next = 32'(wb_dat_i[8*dmem_addr[1:0] +: 16]);
                    default: data_next = wb_dat_i;
                endcase
            end
        endcase
    end

    /*
     * Instruction and Data Registers
     */
    assign imem_ready = imem_read & wb_ack_i & ~invalid_req;
    always_ff @(posedge clk_i) begin : inst_reg
        if (rst_i)
            instruction <= '0;
        else if (wb_ack_i & imem_read)
            instruction <= wb_dat_i;
    end

    assign dmem_ready = (dmem_read | dmem_write) & wb_ack_i & ~invalid_req;
    always_ff @(posedge clk_i) begin : data_reg
        if (rst_i)
            data <= '0;
        else if (wb_ack_i & dmem_read)
            data <= data_next;
    end

endmodule
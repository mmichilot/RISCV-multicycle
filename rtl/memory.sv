`timescale 1ns/1ps
`include "defs.svh"

module memory (
    input clk_i,
    input rst_i,


    // CPU interface
    input  logic        mem_request,
    input  logic [1:0]  mem_op,
    input  logic        mem_sign,
    input  logic [1:0]  mem_size,
    input  logic [31:0] mem_addr,
    input  logic [31:0] mem_wdata,
    output logic        mem_done,
    output logic [31:0] instruction,
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
     * Memory FSM
     * - IDLE: no outstanding memory requests
     * - REQUEST: memory request received from CPU, waiting for destination to be ready
     * - WAIT4ACK: destination has accepted request, waiting for destination to finish
     * - DONE: signal CPU that memory request is done and it can advance
     */
    typedef enum logic [1:0] {IDLE, REQUEST, WAIT4ACK, DONE} state_e;
    state_e current_state, next_state;
    always_ff @(posedge clk_i) begin : state_reg
        if (rst_i) current_state <= IDLE;
        else       current_state <= next_state;
    end

    always_comb begin : output_logic 
        case (current_state)
            IDLE: begin
                wb_cyc_o = 0;
                wb_stb_o = 0;
                mem_done = 0;
            end

            REQUEST: begin
                wb_cyc_o = 1;
                wb_stb_o = 1;
                mem_done = 0;
            end

            WAIT4ACK: begin
                wb_cyc_o = 1;
                wb_stb_o = 0;
                mem_done = 0;
            end

            DONE: begin
                wb_cyc_o = 0;
                wb_stb_o = 0;
                mem_done = 1;
            end
        endcase
    end

    always_comb begin : next_state_logic
        case (current_state)
            IDLE: begin
                if (mem_request) next_state = REQUEST;
                else             next_state = IDLE;
            end

            REQUEST: begin
                if (!wb_stall_i && wb_ack_i) next_state = DONE;
                else if (!wb_stall_i)        next_state = WAIT4ACK;
                else                         next_state = REQUEST;
            end

            WAIT4ACK: begin
                if (wb_ack_i) next_state = DONE;
                else          next_state = WAIT4ACK;
            end

            DONE: next_state = IDLE;
        endcase
    end

    // wb_sel_o
    always_comb begin
        case (mem_op)
            INST_READ: wb_sel_o = 4'b1111;

            DATA_READ, DATA_WRITE: begin
                case (mem_size)
                    BYTE:    wb_sel_o = (4'b0001 << mem_addr[1:0]);
                    HALF:    wb_sel_o = (4'b0011 << mem_addr[1:0]);
                    WORD:    wb_sel_o = 4'b1111;
                    default: wb_sel_o = 4'b0000;
                endcase
            end
            
            default: wb_sel_o = '0;
        endcase
    end

    // wb_we_o
    always_comb begin
        case (mem_op)
            INST_READ, DATA_READ: wb_we_o = 0;
            DATA_WRITE:           wb_we_o = 1;
            default:              wb_we_o = 0;
        endcase
    end

    // wb_adr_o
    assign wb_adr_o = mem_addr;

    // wb_dat_o
    always_comb begin
        case (mem_size)
            BYTE:    wb_dat_o = mem_wdata << (8 * mem_addr[1:0]);
            HALF:    wb_dat_o = mem_wdata << (16 * mem_addr[1]);
            WORD:    wb_dat_o = mem_wdata;
            default: wb_dat_o = mem_wdata;
        endcase
    end

    // wb_dat_i
    logic [31:0] data_q;
    always_comb begin
        case(mem_sign)
            SIGNED: begin
                case(mem_size)
                    BYTE:    data_q = 32'(signed'(wb_dat_i[8*mem_addr[1:0] +: 8]));
                    HALF:    data_q = 32'(signed'(wb_dat_i[8*mem_addr[1:0] +: 16]));
                    default: data_q = wb_dat_i;
                endcase
            end

            UNSIGNED: begin
                case (mem_size)
                    BYTE:    data_q = 32'(wb_dat_i[8*mem_addr[1:0] +: 8]);
                    HALF:    data_q = 32'(wb_dat_i[8*mem_addr[1:0] +: 16]);
                    default: data_q = wb_dat_i;
                endcase
            end
        endcase
    end

    /*
     * Instruction and Data Registers
     */
    always_ff @(posedge clk_i) begin : inst_reg
        if (rst_i)
            instruction <= '0;
        else if (wb_ack_i && (mem_op == INST_READ))
            instruction <= wb_dat_i;
    end

    always_ff @(posedge clk_i) begin : data_reg
        if (rst_i)
            data <= '0;
        else if (wb_ack_i & (mem_op == DATA_READ))
            data <= data_q;
    end

endmodule

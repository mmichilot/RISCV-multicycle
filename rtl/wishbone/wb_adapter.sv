`timescale 1ns / 1ps

// Wishbone adapter for the core
module wb_adapter #(
        parameter RDATA_REG = 0
    ) (
    input clk_i,
    input rst_i,

    input logic         mem_read,
    input logic         mem_write,
    input logic  [31:0] mem_addr,
    input logic  [3:0]  mem_byte_en,
    input logic  [31:0] mem_wdata,
    output logic [31:0] mem_rdata,
    output logic        mem_ready,

    output logic        wb_cyc_o,
    output logic        wb_stb_o,
    input  logic        wb_stall_i,
    output logic        wb_we_o,
    output logic [31:0] wb_adr_o,
    output logic [3:0]  wb_sel_o,
    output logic [31:0] wb_dat_o,
    input logic  [31:0] wb_dat_i,
    input logic         wb_ack_i
);

typedef enum logic [1:0] {IDLE, REQUEST, WAIT4ACK} state_e;

state_e current_state, next_state;
always_ff @(posedge clk_i) begin : state_reg
    if (rst_i) current_state <= IDLE;
    else       current_state <= next_state;
end

always_comb begin : next_state_logic
    case (current_state)
        IDLE:     next_state = (mem_read | mem_write) & ~mem_ready ? REQUEST : IDLE;
        REQUEST: begin
            if (~wb_stall_i) next_state = wb_ack_i ? IDLE : WAIT4ACK;
            else             next_state = REQUEST;
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

generate
    if (RDATA_REG) begin
        always_ff @(posedge clk_i) begin
            if (wb_cyc_o & wb_ack_i & ~wb_we_o)
                    mem_rdata <= wb_dat_i;
        end
    end else begin
        always_comb begin
            
            mem_rdata = wb_dat_i;
        end
    end
endgenerate

assign wb_we_o  = mem_write;
assign wb_adr_o = mem_addr;
assign wb_sel_o = mem_byte_en;
assign wb_dat_o = mem_wdata;
assign mem_ready = wb_ack_i;

endmodule

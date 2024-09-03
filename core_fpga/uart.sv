`include "buses.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: M. Michilot
// 
// Create Date: 08/20/2021
// Design Name: UART Controller
// Module Name: uart
// Project Name: OTTER CPU
// Target Devices:
// Tool Versions: 
// Description: Connects to the OTTER CPU to control the CPU and capture
//              data on the memory bus.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
////////////////////////////////////////////////////////////////////////////////////

module uart (
    input clk,
    input RX,
    output logic TX,

    output cpu_clk,
    output cpu_rst,

    input [31:0] bus_addr,
    input [31:0] bus_rdata,
    input [31:0] bus_wdata
    );

    // Baud rate generator
    logic uart_clk;
    integer clk_count;
    always_ff @(posedge clk) begin : baud_gen
        if (clk_count == 2500) begin
            uart_clk <= ~uart_clk;
            clk_count <= 0;
        end else
            clk_count <= clk_count + 1;
    end

    enum logic [2:0] {
        RST_CPU     = 1,
        STEP_CPU    = 2,
        READ_ADDR   = 3,
        READ_RDATA  = 4,
        READ_WDATA  = 5
    } commands_e;

    // UART Transceiver
    logic [7:0] rx_data;
    logic [7:0] tx_data;
    logic [3:0] bit_count;

    logic [1:0] byte_sel;
    logic [31:0] buffer;


    
    typedef enum logic [2:0] {IDLE,READ,EXECUTE,START,TRANSMIT,STOP} state_e;
    state_e state;
 
    always_ff @(posedge uart_clk) begin
        case (state)
            IDLE: begin
                byte_sel  <= 0;
                cpu_clk   <= 0;
                cpu_rst   <= 0;
                TX        <= 1;
                tx_data   <= 0;
                rx_data   <= 0;
                bit_count <= 0;

                if (RX == 1'b0) state <= READ;
                else            state <= IDLE;
            end

            READ: begin
                rx_data    <= rx_data >> 1;
                rx_data[7] <= RX;
                bit_count  <= bit_count + 1;

                if (bit_count < 7) state <= READ;
                else               state <= EXECUTE;
            end

            EXECUTE: begin
                case (rx_data[2:0])
                    RST_CPU: begin
                        cpu_rst <= 1;
                        cpu_clk <= 1;

                        state <= IDLE;
                    end

                    STEP_CPU: begin
                        cpu_clk <= 1;
                        
                        state   <= IDLE;
                    end

                    READ_ADDR: begin
                        buffer <= bus_addr;

                        state <= START;
                    end

                    READ_RDATA: begin
                        buffer <= bus_rdata;

                        state <= START;
                    end

                    READ_WDATA: begin
                        buffer <= bus_wdata;

                        state <= START;
                    end

                    default: begin
                        cpu_clk <= 0;
                        cpu_rst <= 0;

                        state   <= IDLE;
                    end
                endcase
            end

            START: begin
                tx_data <= buffer[8*byte_sel +: 8];
                TX <= 1'b0;
                bit_count <= 0;
                state <= TRANSMIT;
            end

            TRANSMIT: begin
                TX      <= tx_data[0];
                tx_data <= tx_data >> 1;
                bit_count <= bit_count + 1;

                if (bit_count < 7) state <= TRANSMIT;
                else               state <= STOP;
            end

            STOP: begin
                byte_sel <= byte_sel + 1;
                TX <= 1'b1;

                if (byte_sel < 3) state <= START;
                else              state <= IDLE;
            end

            default: begin
                byte_sel  <= 0;
                cpu_clk   <= 0;
                cpu_rst   <= 0;
                TX        <= 1;
                tx_data   <= 0;
                rx_data   <= 0;
                bit_count <= 0;
                state     <= IDLE;
            end
        endcase
    end

endmodule

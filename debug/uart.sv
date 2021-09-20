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

    enum logic [1:0] {
        RST_CPU     = 2'b01,
        STEP_CPU    = 2'b10,
        READ_BUS    = 2'b11
    } commands_e;

    // UART Transceiver
    logic [7:0] rx_data;
    logic [7:0] tx_data;
    logic [3:0] bit_count;

    logic [1:0] hold_rst;
    
    typedef enum logic [1:0] {IDLE,READ,EXECUTE,TRANSMIT} state_e;
    state_e state;
 
    always_ff @(posedge uart_clk) begin
        case (state)
            IDLE: begin
                cpu_clk <= 0;
                cpu_rst <= 0;
                TX      <= 1;
                tx_data <= 0;
                rx_data <= 0;
                bit_count <= 0;
                hold_rst  <= 0;

                if (RX == 1'b0) state <= READ;
                else            state <= IDLE;
            end

            READ: begin
                
                if (bit_count < 8) begin
                    rx_data    <= rx_data >> 1;
                    rx_data[7] <= RX;
                    bit_count  <= bit_count + 1;
                    state <= READ;
                end else               
                    state <= EXECUTE;
            end

            EXECUTE: begin
                case (rx_data[1:0]) 
                    RST_CPU: begin
                        cpu_rst <= 1;
                        cpu_clk <= ~cpu_clk;
                        hold_rst <= hold_rst + 1;
                        if (hold_rst < 2) state <= EXECUTE;
                        else              state <= IDLE;
                    end

                    STEP_CPU: begin
                        cpu_clk <= 1;
                        state   <= IDLE;
                    end

                    READ_BUS: begin
                        tx_data <= bus_rdata[7:0];
                        TX      <= 1'b0;
                        bit_count <= 0;
                        state <= TRANSMIT;
                    end

                    default: begin
                        cpu_clk <= 0;
                        cpu_rst <= 0;
                        state   <= IDLE;
                    end
                endcase
                
            end

            TRANSMIT: begin
                if (bit_count < 8) begin 
                    TX      <= tx_data[0];
                    tx_data <= tx_data >> 1;
                    bit_count <= bit_count + 1;
                    state <= TRANSMIT;
                end else               
                    state <= IDLE;
            end

            default: begin
                tx_data <= 0;
                rx_data <= 0;
                bit_count <= 0;
            end
        endcase
    end

endmodule

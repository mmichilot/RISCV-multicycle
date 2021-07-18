`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: J. Calllenes
//           P. Hummel
//           M. Michilot
// 
// Create Date: 01/20/2019 10:36:50 AM
// Design Name: 
// Module Name: OTTER_SoC
// Project Name: OTTER-SoC
// Target Devices: OrangeCrab r2.0
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module OTTER_MCU(
    input CLK48,
    input RESET,
    input BTN
    );
       
    // INPUT PORT IDS ////////////////////////////////////////////////////////
    // Right now, the only possible inputs are the switches
    // In future labs you can add more MMIO, and you'll have
    // to add constants here for the mux below
           
    // OUTPUT PORT IDS ///////////////////////////////////////////////////////
    // In future labs you can add more MMIO
    
    // Signals for connecting OTTER_MCU to OTTER_wrapper /////////////////////////
    logic s_interrupt;
    logic s_reset;  
   
    // Signals for IOBUS
    logic [31:0] IOBUS_out, IOBUS_in, IOBUS_addr;
    logic IOBUS_wr;

    // Connect Signals ////////////////////////////////////////////////////////////
    assign s_reset = RESET;
    assign s_interrupt = BTN;

    // Declare OTTER_CPU ///////////////////////////////////////////////////////
    OTTER_CPU CPU(
        .CLK(CLK48),
        .RESET(s_reset),
        .INTR(s_interrupt), 
        .IOBUS_OUT(IOBUS_out),
        .IOBUS_IN(IOBUS_in),
        .IOBUS_ADDR(IOBUS_addr),
        .IOBUS_WR(IOBUS_wr),
    );
                       


    // Connect Board peripherals (Memory Mapped IO devices) to IOBUS /////////////////////////////////////////
endmodule

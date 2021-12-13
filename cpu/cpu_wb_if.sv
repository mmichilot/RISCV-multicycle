`include "buses.svh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: M. Michilot
// 
// Create Date: 08/20/2021
// Design Name:OTTER Wishbone Interface
// Module Name: cpu_wb_if
// Project Name: OTTER CPU
// Target Devices:
// Tool Versions: 
// Description: Implements a wishbone interface for the CPU
// 
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module cpu_wb_if (
    // Signals from CPU
    input memRead,
    input memWrite,
    input sign,
    input [1:0] size,
    input [31:0] addr,
    input [31:0] data_out,

    // Signals to CPU
    output logic clk,
    output logic rst,
    output logic error,
    output logic [31:0] data_in,

    // Wishbone bus
    wishbone_bus.primary bus
);

// Assign CPU signals to WISHBONE bus
assign clk = bus.wb_clk_i;
assign rst = bus.wb_rst_i;
assign data_in = bus.wb_data_i

always_ff (posedge bus.wb_clk_i) begin
    error = 0;
    // CPU initiatiates a transfer cycle
    if (memRead ) {
        bus.wb_cyc <= 1;
        bus.wb_stb <= 1;
    } else if (memWrite) {

    } else {
        bus.wb_cyc = 0;
    }
end



endmodule

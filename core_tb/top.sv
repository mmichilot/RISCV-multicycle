`include "../core/core"
`include "../memory/memory"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: M. Michilot
// 
// Create Date: 08/20/2021
// Design Name: Basic CPU Wrapper
// Module Name: top
// Project Name: OTTER CPU
// Target Devices:
// Tool Versions: 
// Description: Basic CPU Wrapper to be used with Verilator testbench
// 
// Dependencies: None
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module top
    (
        input clk,
        input rst
    );

    logic error;
    logic busWrite;
    logic busRead;
    logic [1:0] data_size;
    logic [31:0] bus_addr;
    logic [31:0] bus_in;
    logic [31:0] bus_out;

    core core(.*);

    memory mem(
    	.clk                 ,
        .rd    (busRead     ),
        .we    (busWrite    ),
        .addr  (bus_addr    ),
        .data  (bus_in     ),
        .size  (data_size   ),
        .out   (bus_out      ),
        .error (error       )
    );
    
    // Set up tracing
    initial begin
       if($test$plusargs("trace") != 0) begin
           $display("[%0t] Tracing to logs/vlt_dump.vcd...\n", $time);
           $dumpfile("logs/vlt_dump.vcd");
           $dumpvars();
       end
       $display("[%0t] Module running...\n", $time);
    end

endmodule

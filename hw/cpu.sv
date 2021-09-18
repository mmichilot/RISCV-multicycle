`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  J. Callenes
// 
// Create Date: 01/04/2019 04:32:12 PM
// Design Name: 
// Module Name: OTTER_CPU
// Project Name: 
// Target Devices: 
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

module cpu
    (
        input clk,
        input rst,
        input error,

        // Data bus (Both instruction and data)
        output logic busWrite,
        output logic busRead,
        output logic [31:0] bus_addr,
        output logic [31:0] bus_in,
        input logic [31:0] bus_out
    ); 

    // -- Signals --
    
    // Control Unit
    logic pcUpdate, irWrite, addrSrc, regWrite, aluCtrl, enBranch;
    logic [1:0] regSrc, aluSrcA, aluSrcB;

    // Decoder
    logic [2:0] immedSrc;
    logic [3:0] aluOp;

    // Datapath
    /* verilator lint_off UNUSED */
    logic [31:0] inst;
    /* verilator lint_on UNUSED */


    (* keep_hierarchy=1 *)
    control_unit control_unit(
        // Inputs
    	.clk      (clk      ),
        .rst      (rst      ),
        .opcode   (inst[6:0]),
        .error    (error),

        // Outputs
        .enBranch (enBranch ),
        .pcUpdate (pcUpdate ),
        .irWrite  (irWrite  ),
        .addrSrc  (addrSrc  ),
        .memWrite (busWrite ),
        .memRead  (busRead  ),
        .regSrc   (regSrc   ),
        .regWrite (regWrite ),
        .aluSrcA  (aluSrcA  ),
        .aluSrcB  (aluSrcB  ),
        .aluCtrl  (aluCtrl  )
    );

    (* keep_hierarchy=1 *)
    decoder decoder(
        // Inputs
    	.opcode    (inst[6:0]),
        .func3     (inst[14:12]),
        .func7     (inst[31:25]),
        .aluCtrl   (aluCtrl   ),

        // Outputs
        .immedSrc  (immedSrc  ),
        .aluOp     (aluOp     )
    );

    (* keep_hierarchy=1 *)
    datapath datapath(
        // Inputs
    	.clk      (clk      ),
        .rst      (rst      ),
        .data_in  (bus_out),
        .enBranch (enBranch ),
        .pcUpdate (pcUpdate ),
        .irWrite  (irWrite  ),
        .addrSrc  (addrSrc  ),
        .regSrc   (regSrc   ),
        .regWrite (regWrite ),
        .immedSrc (immedSrc ),
        .aluSrcA  (aluSrcA  ),
        .aluSrcB  (aluSrcB  ),
        .aluOp    (aluOp    ),

        // Outputs
        .inst_out (inst ),
        .addr     (bus_addr     ),
        .data_out (bus_in)
    );

endmodule

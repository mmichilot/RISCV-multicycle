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
        input logic rst
    ); 

    // -- Signals --
    
    // Control Unit
    logic pcUpdate, irWrite, addrSrc, memWrite, memRead, regWrite;
    logic [1:0] regSrc, aluSrcA, aluSrcB, aluCtrl;

    // Decoder
    logic [2:0] immedSrc;
    logic [3:0] aluOp;

    // Datapath
    logic [31:0] addr, inst;

    // Memory
    logic mem_error;
    logic [31:0] mem_out, mem_in;

    // -- Deprecated --
    logic br_lt,br_eq,br_ltu;
    //Branch Condition Generator
    always_comb
    begin
        br_lt=0; br_eq=0; br_ltu=0;
    end

    control_unit control_unit(
        // Inputs
    	.clk      (clk      ),
        .rst      (rst      ),
        .opcode   (inst[6:0]),
        .error    (mem_error),

        // Outputs
        .pcUpdate (pcUpdate ),
        .irWrite  (irWrite  ),
        .addrSrc  (addrSrc  ),
        .memWrite (memWrite ),
        .memRead  (memRead  ),
        .regSrc   (regSrc   ),
        .regWrite (regWrite ),
        .aluSrcA  (aluSrcA  ),
        .aluSrcB  (aluSrcB  ),
        .aluCtrl  (aluCtrl  )
    );

    decoder decoder(
        // Inputs
    	.opcode    (inst[6:0]),
        .func3     (inst[14:12]),
        .func7     (inst[31:25]),
        .aluCtrl   (aluCtrl   ),
        .CU_BR_EQ  (br_eq  ),
        .CU_BR_LT  (br_lt ),
        .CU_BR_LTU (br_ltu ),

        // Outputs
        .immedSrc  (immedSrc  ),
        .aluOp     (aluOp     )
    );

    datapath datapath(
        // Inputs
    	.clk      (clk      ),
        .rst      (rst      ),
        .data_in  (mem_out  ),
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
        .addr     (addr     ),
        .inst_out (inst ),
        .data_out (mem_in )
    );

    memory u_memory(
        // Inputs
    	.clk   (clk   ),
        .we    (memWrite    ),
        .addr  (addr  ),
        .data  (mem_in  ),
        .size  (inst[13:12]  ),
        .sign  (inst[14]  ),

        // Outputs
        .out   (mem_out   ),
        .error (mem_error )
    );

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: J. Callenes
// 
// Create Date: 01/27/2019 08:37:11 AM
// Design Name: 
// Module Name: bram_dualport
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

//port 1 is read only (instructions - used in fetch stage)
//port 2 is read/write (data - used in writeback stage)

 module memory
    #(
        parameter ACTUAL_WIDTH = 15 // 32K x 8 
    )

    ( 
        input clk,
    
        input rd_addr1,
        input rd_addr2,
        input wr_data,

        input [31:0] addr1,     //Instruction Memory Port
        input [31:0] addr2,     //Data Memory Port
       
        input [31:0] data,

        input [1:0] size,
        input sign,

        output logic [31:0] addr1_data,
        output logic [31:0] addr2_data,
        output logic err
    );

    enum logic [1:0] {
        BYTE = 2'b00,
        HALF = 2'b01,
        WORD = 2'b10
    } e_size;

    enum logic {
        UNSIGNED = 1'b1,
        SIGNED   = 1'b0
    } e_sign;

    // Signals
    logic s_rd_addr1;
    logic s_rd_addr2;
    logic s_wr_data;

    // Buffers 
    logic [31:0] addr2_data_buf;
    
    // Map 32-bit address to 15-bit address
    logic [ACTUAL_WIDTH-1:0] inst_addr, data_addr; 
    assign inst_addr = {addr1[ACTUAL_WIDTH-1:2],2'b0};
    assign data_addr = addr2[ACTUAL_WIDTH-1:0];
    
    // Raw memory block
    logic [7:0] mem [0:2**ACTUAL_WIDTH-1];
    
    // Initialize memory
    initial begin
        $readmemh("mem.txt", mem, 0, 2**ACTUAL_WIDTH-1);
    end 

    //Check for misalligned or out of bounds memory accesses
    always_comb begin
        err = ((addr1 >= 2**ACTUAL_WIDTH) || 
               (addr2 >= 2**ACTUAL_WIDTH) || 
                addr1[1:0] != 2'b0) ? 1 : 0;

        if (!err) begin
            case(size)
                HALF: err = addr2[0]; // Not aligned on 2-byte boundary
                WORD: err = (addr2[1:0] != 2'b0); // Not aligned on 4-byte boundary
                default: err = 0;
            endcase
        end
    end

    // Determine if address is in memory address space
    always_comb begin
        if (addr2 >= 32'h11000000 || err) begin
            s_wr_data = 0; // disable R/W to mem
            s_rd_addr1 = 0;
            s_rd_addr2 = 0;
        end
        else begin 
            s_wr_data = wr_data;
            s_rd_addr1 = rd_addr1;
            s_rd_addr2 = rd_addr2;
        end    
    end 

    // Read data
    always_ff @(posedge clk) begin
        if (s_rd_addr2)
            addr2_data <= addr2_data_buf;

        if (s_rd_addr1)
            addr1_data <= {mem[inst_addr+3],mem[inst_addr+2],mem[inst_addr+1],mem[inst_addr]}; 
    end
    
    // Concat bytes to generate difference data sizes
    always_comb begin
            
        case(sign)
            SIGNED: case(size)
                BYTE: addr2_data_buf = {{24{mem[data_addr][7]}},mem[data_addr]}; // lb
                HALF: addr2_data_buf = {{16{mem[data_addr+1][7]}},mem[data_addr+1],mem[data_addr]}; // lh
                WORD: addr2_data_buf = {mem[data_addr+3],mem[data_addr+2],mem[data_addr+1],mem[data_addr]}; // lw
                default: addr2_data_buf = 0;
            endcase
                        
            UNSIGNED: case(size)
                BYTE: addr2_data_buf = {{24{1'b0}},mem[data_addr]}; // lbu
                HALF: addr2_data_buf = {{16{1'b0}},mem[data_addr+1],mem[data_addr]}; //lhu
                WORD: addr2_data_buf = {mem[data_addr+3],mem[data_addr+2],mem[data_addr+1],mem[data_addr]};
                default: addr2_data_buf = 0;
            endcase

        endcase
    end

    integer i,j;

    // Write data
    always_ff @(posedge clk) begin
        if(s_wr_data) begin
            j=0;
            for(i=0;i<NUM_COL;i=i+1) begin
                if(weA[i]) begin
                        case(MEM_SIZE)
                            0: memory[memAddr2][i*COL_WIDTH +: COL_WIDTH] <= MEM_DIN2[7:0]; //MEM_DIN2[(3-i)*COL_WIDTH +: COL_WIDTH]
                            1: begin 
                                    memory[memAddr2][i*COL_WIDTH +: COL_WIDTH] <= MEM_DIN2[j*COL_WIDTH +: COL_WIDTH];
                                    j=j+1;
                               end
                            2: memory[memAddr2][i*COL_WIDTH +: COL_WIDTH] <= MEM_DIN2[i*COL_WIDTH +: COL_WIDTH];
                            default:  memory[memAddr2][i*COL_WIDTH +: COL_WIDTH] <= MEM_DIN2[i*COL_WIDTH +: COL_WIDTH];
                        endcase
                end
            end
        end
    end 
*/
 endmodule

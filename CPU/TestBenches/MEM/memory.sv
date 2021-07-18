//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Matthew Michilot
// 
// Create Date: 01/27/2019 08:37:11 AM
// Design Name: Memory (using BRAM banks)
// Module Name: memory
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

 module bram
    #(
        parameter ADDR_WIDTH = 14, // 16K x 32 -> 65KB
        parameter DATA_WIDTH = 8
    )

    ( 
        input clk,

        input rd,
        input [ADDR_WIDTH-1:0] addr, 
        output logic[DATA_WIDTH-1:0] dout,

        input wr,
        input [DATA_WIDTH-1:0] din

        //input [1:0] size,
        //input sign
        //output logic err
    );

    // Raw memory block
    (* syn_ramstyle="block_ram" *)
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
    
    // Read/Write
    always_ff @(posedge clk) begin
        if (rd)
            dout <= mem[addr];

        else if (wr)
            mem[addr] <= din;
    end 
endmodule

module memory
    (
        input clk,
    
        input rd,
        input [13:0] addr,
        output logic [31:0] dout,

        input wr,
        input [31:0] din,

        input [1:0] size,
        input sign,
        output err
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
    logic s_rd;
    logic s_wr;

    // Banks of BRAM
    bram bank0 (
        .clk(clk),
        .rd(s_rd),
        .addr(addr),
        .dout(dout[7:0]),
        .wr(s_wr),
        .din(din[7:0])
    );

    bram bank1 (
        .clk(clk),
        .rd(s_rd),
        .addr(addr),
        .dout(dout[15:8]),
        .wr(s_wr),
        .din(din[15:8])
    );

    bram bank2 (
        .clk(clk),
        .rd(s_rd),
        .addr(addr),
        .dout(dout[23:16]),
        .wr(s_wr),
        .din(din[23:16])
    );

       bram bank3 (
        .clk(clk),
        .rd(s_rd),
        .addr(addr),
        .dout(dout[31:24]),
        .wr(s_wr),
        .din(din[31:24])
    );     
        
    //Check for misalligned or out of bounds memory accesses
    always_comb begin
        err = (addr >= (1<<14));

        if (!err) begin
            case(size)
                HALF: err = addr[0]; // Not aligned on 2-byte boundary
                WORD: err = (addr[1:0] != 2'b0); // Not aligned on 4-byte boundary
                default: err = 0;
            endcase
        end
    end

    // Disable memory if address is not valid
    always_comb begin
        if (err) begin
            s_wr = 0;
            s_rd = 0;
        end
        else begin 
            s_wr = wr;
            s_rd = rd;
        end    
    end 
    
endmodule
    
    /*
    // Concat bytes to generate difference data sizes
    always_comb begin
        case(sign)
            SIGNED: case(size)
                BYTE: addr2_data_buf = 32'(signed'(mem[data_addr])); // lb
                HALF: addr2_data_buf = 32'(signed'({mem[data_addr+1],mem[data_addr]})); // lh
                WORD: addr2_data_buf = {mem[data_addr+3],mem[data_addr+2],mem[data_addr+1],mem[data_addr]}; // lw
                default: addr2_data_buf = 0;
            endcase
                        
            UNSIGNED: case(size)
                BYTE: addr2_data_buf = 32'(mem[data_addr]); // lbu
                HALF: addr2_data_buf = 32'({mem[data_addr+1],mem[data_addr]}); //lhu
                WORD: addr2_data_buf = {mem[data_addr+3],mem[data_addr+2],mem[data_addr+1],mem[data_addr]};
                default: addr2_data_buf = 0;
            endcase
        endcase
    end
    */


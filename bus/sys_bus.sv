interface sys_bus #(parameter  WIDTH = 32) (input clk);
    logic error;
    logic wr;
    logic rd;
    logic [1:0] size;
    logic [WIDTH-1:0] addr;
    logic [WIDTH-1:0] rdata;
    logic [WIDTH-1:0] wdata;

    modport primary (
        input error, rdata, clk,
        output wr, rd, size, addr, wdata
    );

    modport secondary (
        input wr, rd, size, addr, wdata, clk,
        output rdata, error
    );

endinterface

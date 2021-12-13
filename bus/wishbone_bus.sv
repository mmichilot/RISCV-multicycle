interface wishbone_bus #(parameter  WIDTH = 32)
(
    input wb_rst_i,
    input wb_clk_i
);
    // Wishbone Signals
    logic wb_we;
    logic [(WIDTH/8)-1:0] wb_sel;
    logic wb_stb;
    logic wb_ack;
    logic wb_cyc;

    logic [WIDTH-1:0] wb_adr;
    logic [WIDTH-1:0] wb_dat_i;
    logic [WIDTH-1:0] wb_dat_o;
    

    modport primary (
        input  wb_rst_i, wb_clk_i, wb_ack, wb_dat_i,

        output wb_we, wb_stb, wb_cyc, wb_sel, 
               wb_adr, wb_dat_o
    );

    modport secondary (
        input  wb_rst_i, wb_clk_i, wb_adr, wb_dat_o,
               wb_we, wb_sel, wb_stb, wb_cyc,

        output wb_dat_i,wb_ack
    );

endinterface

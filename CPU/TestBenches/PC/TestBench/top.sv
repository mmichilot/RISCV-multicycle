module tb;
    reg clk;

    always #10 clk =~ clk;
    pc_if   _if(clk);
    prog_cntr (.clk(clk)
               .rstn(_if.rstn)
               .ld(_if.ld)
               .data(_if.data)
               .count(_if.count));

    test t0;

    initial begin
        {clk, _if.rstn} <= 0;

        #20 _if.rstn <= 1;
        t0 = new
        t0.e0.vif = _vif;
        t0.run();

        #200 $finish
    end

    initial begin
        $dumpvars;
        $dumpfile("dump.vcd");
    end
endmodule

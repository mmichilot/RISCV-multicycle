class Packet;
    rand bit            rstn;
    rand bit            ld;
    rand bit [31:0]     data;
    bit [31:0]          count;

    function void print(string tag="");
        $display ("T=%0t  %s rstn=%0d ld=%0d data=0x%0h count=0x%0h",
                    $time, rstn, ld, data, count);
    endfunction
endclass 

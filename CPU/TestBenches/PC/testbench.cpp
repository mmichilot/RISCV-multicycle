#include <iostream>
#include <fstream>

#include <backends/cxxrtl/cxxrtl_vcd.h>

#include "prog_cntr.cpp"

using namespace std;

int main() {
    cxxrtl_design::p_prog__cntr top;

    cxxrtl::debug_items all_debug_items;

    top.debug_info(all_debug_items);

    cxxrtl::vcd_writer vcd;
    vcd.timescale(1, "us");

    vcd.add(all_debug_items);

    ofstream waves("prog_cntr.vcd");

    top.p_rstn.set<bool>(0);
    top.p_ld.set<bool>(0);
    top.p_data.set<unsigned int>(0x1234);

    top.step();
    vcd.sample(0);

    for(int cycles=0;cycles<1000;++cycles) {
        
        if (cycles==10) top.p_rstn.set<bool>(1);

        if (cycles==20) top.p_ld.set<bool>(1);
        if (cycles==21) top.p_ld.set<bool>(0);

        if (cycles==40) top.p_rstn.set<bool>(0);
        if (cycles==41) top.p_rstn.set<bool>(1);

        if (cycles==50) {
            top.p_data.set<unsigned int>(0xFFFFFFF0);
            top.p_ld.set<bool>(1);
        }

        if (cycles==51) top.p_ld.set<bool>(0);

        top.p_clk.set<bool>(1);
        top.step();
        vcd.sample(cycles*2 + 0);

        top.p_clk.set<bool>(0);
        top.step();
        vcd.sample(cycles*2 + 1);

        waves << vcd.buffer;
        vcd.buffer.clear();
    }
}

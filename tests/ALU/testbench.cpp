#include <iostream>
#include <fstream>

#include <backends/cxxrtl/cxxrtl_vcd.h>

#include "alu.cpp"

using namespace std;

int main() {
    cxxrtl_design::p_alu top;

    cxxrtl::debug_items all_debug_items;

    top.debug_info(all_debug_items);

    cxxrtl::vcd_writer vcd;
    vcd.timescale(1, "us");

    vcd.add(all_debug_items);

    ofstream waves("alu.vcd");

    top.p_a.set<unsigned int>(0);
    top.p_b.set<unsigned int>(0);
    top.p_op.set<unsigned int>(0);

    top.step();
    vcd.sample(0);

    for(int cycles=0;cycles<1000;++cycles) {
        
        if (cycles==10)
            top.p_a.set<unsigned int>(50);

        top.step();
        vcd.sample(cycles*2 + 0);

        top.step();
        vcd.sample(cycles*2 + 1);

        waves << vcd.buffer;
        vcd.buffer.clear();
    }
}

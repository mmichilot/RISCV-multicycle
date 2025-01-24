#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <string>

#include <verilated.h>

#include "testbench.h"
#include "Vtb_top.h"
#include "verilated_fst_c.h"



/**
 * Taken from Cores-VeeR-EL2 RISCOF TB
 * https://github.com/chipsalliance/Cores-VeeR-EL2/blob/main/testbench/test_tb_top.cpp
 */
std::map<std::string, uint64_t> load_symbols(const std::string& fileName) {
    // Open the symbol list file
    std::ifstream fp(fileName);
    if (!fp.good()) {
        std::cerr << "Error loading symbols from '" << fileName << "'" << std::endl;
        exit(EXIT_FAILURE);
    }

    // Parse lines
    std::map<std::string, uint64_t> symbols;
    for (std::string line; std::getline(fp, line);) {
        // Remove any trailing whitespaces
        auto pos = line.find_last_not_of(" \r\n\t");
        line = line.substr(0, pos + 1);

        // Get address
        auto apos = line.find_first_of(" \r\n\t");
        const auto astr = line.substr(0, apos);

        // Get name
        auto npos = line.find_last_of(" \r\n\t");
        const auto nstr = line.substr(npos + 1);

        symbols[nstr] = strtol(astr.c_str(), nullptr, 16);
    }

    return symbols;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    auto tb = std::unique_ptr<TESTBENCH<Vtb_top>>(new TESTBENCH<Vtb_top>());

    tb->trace("trace.fst");

    std::map<std::string, uint64_t> symbols;

    // Parse arguments
    // Adapted from https://github.com/chipsalliance/Cores-VeeR-EL2/blob/main/testbench/test_tb_top.cpp
    for (int i = 1; i < argc; i++) {
        char* arg = argv[i];

        if ((strcmp(arg, "--symbols") == 0) && ((i + 1) < argc)) {
            symbols = load_symbols(argv[i + 1]);

            const auto begin_sig = symbols.find("begin_signature");
            const auto end_sig = symbols.find("end_signature");
            const auto mailbox = symbols.find("tohost");

            if (begin_sig != symbols.end() && end_sig != symbols.end() && mailbox != symbols.end()) {
                tb->m_core->mem_signature_begin = begin_sig->second;
                tb->m_core->mem_signature_end = end_sig->second;
                tb->m_core->mem_mailbox = mailbox->second;
            }
        }

        if ((strcmp(arg, "--memory-file") == 0) && ((i + 1) < argc)) {
            const std::string mem_file = argv[i + 1];
            tb->m_core->mem_file = mem_file;
        }
    }

    tb->reset();

    while (!tb->done()) {
        tb->tick();
    };

    return 0;
}   


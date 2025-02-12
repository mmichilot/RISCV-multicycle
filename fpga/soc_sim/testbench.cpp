#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <string>

#include <verilated.h>

#include "testbench.h"
#include "Vtb_soc.h"
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
    auto tb = std::unique_ptr<TESTBENCH<Vtb_soc>>(new TESTBENCH<Vtb_soc>());

    tb->trace("trace.fst");

    uint32_t mem_mailbox = 0x02020000;

    // Parse arguments
    // Adapted from https://github.com/chipsalliance/Cores-VeeR-EL2/blob/main/testbench/test_tb_top.cpp
    for (int i = 1; i < argc; i++) {
        char* arg = argv[i];

        if ((strcmp(arg, "--mailbox") == 0) && ((i + 1) < argc)) {
            mem_mailbox = std::stoi(argv[i + 1], NULL, 16);
        }

        if ((strcmp(arg, "--firmware") == 0 && ((i + 1) < argc))) {
            const std::string firmware_file = argv[i + 1];
            tb->m_soc->firmware_file = firmware_file;
        }
    }

    tb->m_soc->mem_mailbox = mem_mailbox;

    tb->reset();

    while (!tb->done()) {
        tb->tick();
    };

    return 0;
}

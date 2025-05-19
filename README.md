# Multicycle RISC-V CPU
This is an implementation of multicycle RISC-V CPU. It supports RV32I_Zicsr and interrupts. Tested with [RISCOF](https://riscof.readthedocs.io/en/latest/intro.html).

## Dependencies
- [Verilator](https://verilator.org/guide/latest/install.html)
- [RISCOF](https://riscof.readthedocs.io/en/latest/installation.html#install-riscof)
- [Spike](https://github.com/riscv-software-src/riscv-isa-sim)
- [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
    - Use `--enable-multilib` when building

## Running Tests
Note: Make sure the Spike and toolchain binaries are visible via `$PATH`
```
$ git clone https://github.com/mmichilot/RISCV-multicycle
$ cd RISCV-multicycle
$ make
```
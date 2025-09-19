import os
import logging

import riscof.utils as utils
from riscof.pluginTemplate import pluginTemplate

logger = logging.getLogger()

class multicycle(pluginTemplate):
    __model__   = "multicycle"
    __version__ = "1.0"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        config = kwargs.get('config')
        if config is None:
            print("Please enter input file paths in configuration.")
            raise SystemExit(1)

        self.num_jobs      = str(config['jobs'] if 'jobs' in config else 1)
        self.dut_exe       = os.path.abspath(config['dut_exe'])
        self.pluginpath    = os.path.abspath(config['pluginpath'])
        self.isa_spec      = os.path.abspath(config['ispec'])
        self.platform_spec = os.path.abspath(config['pspec'])

        if 'target_run' in config and config['target_run']=='0':
            self.target_run = False
        else:
            self.target_run = True

    def initialise(self, suite, workdir, env):
        self.work_dir = workdir
        self.suite_dir = suite

        self.compile_cmd = 'riscv-none-elf-gcc -mno-relax -march={0}\
            -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -g\
            -T ' + self.pluginpath + '/env/link.ld\
            -I ' + self.pluginpath + '/env/\
            -I ' + env + ' {2} -o {3} {4}'

        self.dump_cmd    = 'riscv-none-elf-objdump -x -S -s {0} > program.dump'
        self.binary_cmd  = 'riscv-none-elf-objcopy -O binary --only-section=.data* --only-section=.text* {0} program.bin'
        self.hex_cmd     = 'hexdump -v -e \'1/4 "%08x\\n"\' program.bin > program.hex'
        self.symbols_cmd = 'riscv-none-elf-nm -g -B -n {0} > program.sym'

    def build(self, isa_yaml, platform_yaml):
        ispec = utils.load_yaml(isa_yaml)['hart0']
        self.xlen = ('64' if 64 in ispec['supported_xlen'] else '32')

        self.isa = 'rv' + self.xlen
        if "I" in ispec["ISA"]:
            self.isa += 'i'
        if "M" in ispec["ISA"]:
            self.isa += 'm'
        if "F" in ispec["ISA"]:
            self.isa += 'f'
        if "D" in ispec["ISA"]:
            self.isa += 'd'
        if "C" in ispec["ISA"]:
            self.isa += 'c'

        self.compile_cmd = self.compile_cmd+' -mabi='+('lp64 ' if 64 in ispec['supported_xlen'] else 'ilp32 ')

    def runTests(self, testlist):
        makefile = self.work_dir + "/Makefile." + self.name[:-1]
        if os.path.exists(makefile):
            os.remove(makefile)
        

        make = utils.makeUtil(makefilePath=os.path.join(self.work_dir, "Makefile." + self.name[:-1]))
        make.makeCommand = 'make -k -j' + self.num_jobs

        for testname in testlist:
            testentry = testlist[testname]

            test     = testentry['test_path']
            test_dir = testentry['work_dir']

            elf = 'test.elf'

            sig_file = os.path.join(test_dir, self.name[:-1] + ".signature")
            compile_macros= ' -D' + " -D".join(testentry['macros'])
            isa = testentry['isa'].lower()

            cmds = [self.compile_cmd.format(isa, self.xlen, test, elf, compile_macros),
                    self.dump_cmd.format(elf),
                    self.binary_cmd.format(elf),
                    self.hex_cmd,
                    self.symbols_cmd.format(elf)]


            if self.target_run:
                simcmd = [
                    self.dut_exe + " --symbols program.sym --memory-file program.hex",
                    f'mv otter.signature {sig_file}'
                ]
            else:
                simcmd = [
                    'echo "NO RUN"'
                ]

            execute = f'@cd {testentry["work_dir"]};'
            execute += '; '.join(cmds + simcmd)

            make.add_target(execute)

        make.execute_all(self.work_dir)

        if not self.target_run:
            raise SystemExit(0)

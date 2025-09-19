import os
import logging

import riscof.utils as utils
from riscof.pluginTemplate import pluginTemplate

logger = logging.getLogger()

class spike(pluginTemplate):
    __model__   = "spike"
    __version__ = "1.0"

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        config = kwargs.get('config')
        if config is None:
            print("Please enter input file paths in configuration.")
            raise SystemExit(1)

        self.num_jobs      = str(config['jobs'] if 'jobs' in config else 1)
        self.dut_exe       = os.path.join(config['PATH'] if 'PATH' in config else "","spike")
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

        self.compile_cmd = self.compile_cmd + ' -mabi='+('lp64 'if 64 in ispec['supported_xlen'] else 'ilp32')

    def runTests(self, testlist):

        makefile = self.work_dir + "/Makefile." + self.name[:-1]
        if os.path.exists(makefile):
            os.remove(makefile)

        make = utils.makeUtil(makefilePath=makefile)
        make.makeCommand = 'make -k -j' + self.num_jobs

        for testname in testlist:
            testentry = testlist[testname]
            
            test     = testentry['test_path']
            test_dir = testentry['work_dir']

            elf = 'test.elf'

            sig_file = os.path.join(test_dir, self.name[:-1] + ".signature")
            compile_macros = ' -D' + ' -D'.join(testentry['macros'])
            isa = testentry['isa'].lower()

            cmd = self.compile_cmd.format(isa, self.xlen, test, elf, compile_macros)

            if self.target_run:
                simcmd = self.dut_exe + ' --isa={0} +signature={1} +signature-granularity=4 {2}'.format(self.isa, sig_file, elf)
            else:
                simcmd = 'echo "NO RUN"'

            execute = '@cd {0}; {1}; {2};'.format(testentry['work_dir'], cmd, simcmd)

            make.add_target(execute)
        
        make.execute_all(self.work_dir)

        if not self.target_run:
            raise SystemExit(0)
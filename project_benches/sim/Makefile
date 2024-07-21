export ECE745_PROJECT_HOME ?= $(PWD)/../..

include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile

GEN_TRANS_TYPE ?= i2cmb_test
TEST_SEED ?= 1234567890
CLI_DO_COMMANDS = -do " \
                    set NoQuitOnFinish 1; \
                    run -all; \
	 	            do save_coverage.do $(GEN_TRANS_TYPE); \
                    quit -f;" 

DEBUG_DO_COMMANDS = -do " \
                    set NoQuitOnFinish 1; \
                    do wave.do;\
                    run -a;"\

clean:
	rm -rf work

clean_all:
	rm -rf work *.wlf transcript 
	rm -f *.ucdb
	rm -rf covhtmlreport

comp_I2C_MB:
	vcom +cover=bcefsx ../rtl/iicmb_int_pkg.vhd
	vcom +cover=bcefsx ../rtl/iicmb_pkg.vhd
	vcom +cover=bcefsx ../rtl/mbyte.vhd
	vcom +cover=bcefsx ../rtl/mbit.vhd
	vcom +cover=bcefsx ../rtl/bus_state.vhd
	vcom +cover=bcefsx ../rtl/filter.vhd
	vcom +cover=bcefsx ../rtl/conditioner.vhd
	vcom +cover=bcefsx ../rtl/conditioner_mux.vhd
	vcom +cover=bcefsx ../rtl/iicmb_m.vhd
	vcom +cover=bcefsx ../rtl/regblock.vhd
	vcom +cover=bcefsx ../rtl/wishbone.vhd
	vcom +cover=bcefsx ../rtl/iicmb_m_wb.vhd

run_cli:
	vsim -c -coverage -sv_seed $(TEST_SEED) $(CLI_DO_COMMANDS) +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

cli: clean compile optimize run_cli

comp_bench: comp_ncsu_pkg comp_wb_pkg comp_i2c_pkg comp_i2cmb_env_pkg
	vlog +define+$(OPT) ../testbench/top.sv

merge_coverage:
	xml2ucdb -format Excel ./i2cmb_test_plan.xml ./i2cmb_test_plan.ucdb
	vcover merge -stats=none -strip 0 -totals sim_and_testplan_merged.ucdb ./*.ucdb 

optimize:
	vopt +cover=bcefsx +acc top -o optimized_debug_top_tb

compile: comp_I2C_MB comp_bench optimize

simulate:
	vsim  -i -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do" optimized_debug_top_tb

sim_display:
	vsim  -c -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do" optimized_debug_top_tb

debug_3step: clean compile simulate

regress:
	./regress.sh

view_coverage:
	vsim -viewcov ./sim_and_testplan_merged.ucdb

display: clean compile sim_display

debug:
	qrun -64 -gui -visualizer -onfinish stop -classdebug -uvmcontrol=all -msgmode both -permit_unmatched_virtual_intf -l run.log -f lab1_filelist.f -sv_seed 123456 -msglimit error -msglimitcount 20 -do "set IterationLimit 140000; set NoQuitOnFinish 1; coverage attribute -name TESTNAME -value test_top; coverage save -onexit test_top.ucdb; do wave.do" -debug,livesim -qwavedb=+signal+memory=1024+report+parameter+class+assertion+uvm_schematic+msg+classmemory=1024+statictaskfunc -top top -covermultiuserenv -designfile design.bin 



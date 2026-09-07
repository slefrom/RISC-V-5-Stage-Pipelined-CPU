SIM ?= verilator
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES = \
	$(PWD)/../rtl/rv_pkg.sv \
	$(PWD)/../rtl/alu.sv \
	$(PWD)/../rtl/regfile.sv \
	$(PWD)/../rtl/fetch.sv \
	$(PWD)/../rtl/decode.sv \
	$(PWD)/../rtl/execute.sv \
	$(PWD)/../rtl/memory.sv \
	$(PWD)/../rtl/writeback.sv \
	$(PWD)/../rtl/hazard_unit.sv \
	$(PWD)/../rtl/forwarding_unit.sv \
	$(PWD)/../rtl/top.sv

TOPLEVEL ?= top
MODULE ?= tb_top
SIM_BUILD ?= sim_build_$(TOPLEVEL)

EXTRA_ARGS += --trace --trace-structs -Wno-CASEINCOMPLETE

include $(shell cocotb-config --makefiles)/Makefile.sim


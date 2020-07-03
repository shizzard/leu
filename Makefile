SHELL          = /bin/bash
EXECUTABLES    = lux
K := $(foreach exec,$(EXECUTABLES),$(if $(shell which $(exec)),,$(error "No `$(exec)` found in PATH")))

RUNDIR        := $(shell pwd)
REBAR          = $(RUNDIR)/rebar3
LUX            = $(shell which lux)
LEU            = $(RUNDIR)/leu
LUX_LOGS_DIR   = lux_logs
LUX_TESTS_DIR  = test/lux
ERL_BUILD_DIR  = _build

.PHONY: all get-deps compile release lux-test clean dialyze
.EXPORT_ALL_VARIABLES:


all: get-deps compile

get-deps:
	$(REBAR) as prod get-deps

compile:
	$(REBAR) as prod compile

escriptize: get-deps compile
	$(REBAR) as prod escriptize
	ln -sf $(ERL_BUILD_DIR)/prod/bin/leu $(LEU)

release:
	$(REBAR) as prod release

lux-test: compile
	export LEU=$(LEU)
	export RUNDIR=$(LEU)
	$(LUX) $(shell find $(LUX_TESTS_DIR) -name '*.lux')

clean:
	$(REBAR) clean

full-clean: clean
	rm -rf $(LUX_LOGS_DIR) $(ERL_BUILD_DIR)
	rm -f leu


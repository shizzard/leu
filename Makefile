SHELL          = /bin/bash
EXECUTABLES    = lux
K := $(foreach exec,$(EXECUTABLES),$(if $(shell which $(exec)),,$(error "No `$(exec)` found in PATH")))

REBAR          = ./rebar3
LUX            = $(shell which lux)
LUX_LOGS_DIR   = lux_logs
LUX_TESTS_DIR  = test/lux

.PHONY: all get-deps compile release lux-test clean dialyze
.EXPORT_ALL_VARIABLES:


all: get-deps compile

get-deps:
	$(REBAR) get-deps

compile:
	$(REBAR) compile

release:
	$(REBAR) release

lux-test: compile
	$(LUX) $(shell find $(LUX_TESTS_DIR) -name '*.lux')

clean:
	$(REBAR) clean
	rm -rf $(LUX_LOGS_DIR)

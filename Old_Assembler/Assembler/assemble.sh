#! /bin/bash

PARAMS="../../Octavo/Misc/params.v"

VSIM_ACTIONS="run -all ; quit"

clear
vlib work
vlog -mfcu -incr -lint -novopt $PARAMS $1
vsim -c -do "$VSIM_ACTIONS" do_thread_pc do_test SIMD_do_test


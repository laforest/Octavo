#! /bin/bash

PARAMS="../Octavo_raw/Misc/params.v"

clear
qverilog -mfcu -incr -lint -novopt $PARAMS $1
#rm qverilog.log


#!/bin/bash

source venv/bin/activate
nix-shell -p openfpgaloader -p nextpnr -p yosys -p yosys-ghdl

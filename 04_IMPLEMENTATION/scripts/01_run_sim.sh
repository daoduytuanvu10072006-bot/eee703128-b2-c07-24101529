#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"; cd "$ROOT"
echo "===== DANG MO PHONG RTL ====="
iverilog -g2012 -o sim.vvp rtl/project.sv tb/tb.sv
vvp sim.vvp | tee simulation.log
echo "Xong! Log luu tai simulation.log"

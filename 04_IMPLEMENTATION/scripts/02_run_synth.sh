#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"; cd "$ROOT"
echo "===== DANG TONG HOP YOSYS ====="
yosys -p "read_verilog -sv rtl/project.sv; synth -top tt_um_c07_dual_channel; stat" 

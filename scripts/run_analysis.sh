#!/usr/bin/env bash
# Runs the CO2 analysis script end‐to‐end

set -euo pipefail

# Load environment if present
if [[ -f .env ]]; then
  export $(grep -v '^#' .env | xargs)
fi

echo "[$(date)] Running CO₂ analysis…"
Rscript CO2_Analysis.R
echo "[$(date)] Analysis complete."

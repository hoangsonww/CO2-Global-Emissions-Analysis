#!/usr/bin/env bash
# Fetch the OWID CO2 dataset and save locally

DATA_DIR="${DATA_DIR:-./data}"
URL="https://raw.githubusercontent.com/owid/co2-data/master/owid-co2-data.csv"
OUT="$DATA_DIR/owid-co2-data.csv"

mkdir -p "$DATA_DIR"
echo "[$(date)] Downloading CO2 data…"
curl -sSL "$URL" -o "$OUT"
echo "Saved to $OUT"

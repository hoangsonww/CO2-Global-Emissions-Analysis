#!/usr/bin/env bash
# Fetch data, run analysis, then render the RMarkdown report

set -euo pipefail

echo "===== Build Report ====="
./scripts/fetch_co2.sh
./scripts/run_analysis.sh

echo "Rendering RMarkdown report..."
Rscript -e "rmarkdown::render('CO2_Analysis.Rmd', output_file='CO2_report.html')"
echo "Report built at CO2_report.html"

# Global CO₂ Emissions Analysis

A comprehensive R-based analysis that fetches and processes global CO₂ emissions data (per-capita and total) from Our World in Data (OWID), generates a suite of 12 exploratory and analytical plots, and performs a regression of per-capita emissions on GDP per capita.

## Table of Contents

1. [Project Overview](#project-overview)  
2. [Features & Charts](#features--charts)  
3. [Prerequisites](#prerequisites)  
4. [Installation](#installation)  
5. [Usage](#usage)  
6. [Script Breakdown](#script-breakdown)  
7. [Interpreting the Outputs](#interpreting-the-outputs)  
8. [Extending & Customizing](#extending--customizing)  
9. [Data Source & Citations](#data-source--citations)  
10. [License](#license)  

---

## Project Overview

This repository contains:

- **`CO2_Analysis.R`**: A self-contained R script that  
  1. Downloads the OWID CO₂ dataset (yearly, since 1750)  
  2. Cleans & prepares: CO₂ per capita, total CO₂, GDP per capita, date conversion  
  3. Produces 12 visualizations exploring temporal trends, economic relationships, top emitters, quartile analyses, cumulative sums, and year-over-year changes  
  4. Fits a linear regression model: CO₂ per capita ~ GDP per capita, with summary statistics and an annotated plot  

- **`report.Rmd`**: An R Markdown report that weaves narrative, code, and plots into a shareable HTML document.

- **`scripts/`**, **`Makefile`**, **`Dockerfile`**, **`docker-compose.yml`**, and **`.env.example`** to automate data fetching, analysis, report building, and containerized execution.

---

## Features & Charts

1. **Global Trend**  
   - Line plot of global average CO₂ per capita over time  
2. **GDP vs. CO₂**  
   - Scatter of GDP per capita vs. CO₂ per capita (latest) with LOESS smoothing  
3. **Regression Analysis**  
   - Linear model summary printed to console  
   - Scatter + regression line with R² and p-value annotation  
4. **Top 10 Emitters (per capita)**  
   - Horizontal bar chart of the 10 highest per-capita emitters  
5. **Top 5 Time Series**  
   - Line plots of CO₂ per capita over time for the top 5 countries  
6. **Quartile Boxplot**  
   - CO₂ per capita by GDP per capita quartile (boxplot)  
7. **Quartile Violin**  
   - Distribution of CO₂ per capita by GDP quartile (violin plot)  
8. **Quartile Heatmap**  
   - Heatmap of average CO₂ per capita by year & GDP quartile  
9. **Cumulative Sum**  
   - Cumulative sum of per-capita CO₂ over time  
10. **Year-over-Year Change**  
    - Line plot of YOY % change in global average CO₂ per capita  
11. **Total vs. Per Capita**  
    - Scatter of total CO₂ emissions vs. per-capita emissions (log scale)  
12. **Global Time Series**  
    - (Already #1) — the core global trend  

<p align="center">
  <img 
</p>

---

## Prerequisites

- **R** ≥ 4.0  
- Internet access to fetch OWID data  

### R Packages

- `ggplot2`, `dplyr`, `lubridate`, `tidyr`, `forcats`, `scales`, `viridis`, `zoo`, `corrplot`  

The main script auto-installs any missing packages.

---

## Installation

1. **Clone** this repository:

   ```bash
   git clone https://github.com/yourusername/co2-analysis.git
   cd co2-analysis
````

2. **Optional**: copy `.env.example` → `.env` to set `DATA_DIR` if you prefer a custom data folder.

---

## Usage

### From R or RStudio

```r
# Set working directory to the project root
setwd("path/to/co2-analysis")

# Source the analysis script
source("CO2_Analysis.R")
```

All charts will render in sequence and the regression summary will print to the console.

### Via Make

```bash
make report
```

This will:

1. Fetch the CO₂ CSV into `data/`
2. Run `CO2_Analysis.R`
3. Render `CO2_Analysis.Rmd` → `CO2_report.html`

### Via Docker

```bash
docker-compose up --build
```

This runs the entire pipeline in a reproducible container.

---

## Script Breakdown

1. **Setup**

   * Defines package list, auto-installs, and loads libraries.
2. **Data Fetch & Prep**

   * Downloads OWID CSV, filters to years ≥1960, computes `co2_pc`, `total_co2`, `gdp_pc`.
   * Derives `date` from `year`.
3. **Visualization Sections**

   * **Global trend**, **GDP relationship**, **top emitter charts**, **quartile analyses**, **cumulative sums**, **YOY change**, **total vs. per-capita**.
4. **Regression**

   * Fits `lm(co2_pc ~ gdp_pc)`, prints `summary()`, and generates an annotated plot.

---

## Interpreting the Outputs

* **Global Average**: captures long-term trends in per-capita emissions.
* **GDP vs CO₂**: shows the positive correlation between wealth and emissions.
* **Top Emitters**: highlights the countries with the highest per-capita footprint.
* **Quartile Plots**: reveal distributional differences across income strata.
* **Cumulative & YOY**: expose acceleration or deceleration in emission growth.
* **Regression**: quantifies how much GDP per capita explains variation in emissions.

---

## Extending & Customizing

* **Adjust filters** (e.g., include earlier years).
* **Swap color palettes** or themes.
* **Add new predictors** (population density, energy mix).
* **Save plots** by adding `ggsave()` calls.
* **Integrate regional maps** using `sf` and `rnaturalearth`.

---

## Data Source & Citations

* **Our World in Data** CO₂ dataset:
  [https://github.com/owid/co2-data](https://github.com/owid/co2-data)
* **R & Packages**: R Core Team (2023). R: A language and environment for statistical computing.
* **Visualization**: Wickham H. et al. “ggplot2: Elegant Graphics for Data Analysis.”

---

## License

This project is released under the **MIT License**. See [LICENSE](LICENSE) for details.

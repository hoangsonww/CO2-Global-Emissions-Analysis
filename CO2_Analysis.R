# =================================================================================
# CO2_Analysis.R
#
# This script performs a comprehensive analysis of global CO2 emissions data 
# sourced from Our World in Data (OWID). It:
#   1. Downloads the OWID CO2 dataset (yearly CO2 emissions by country since 1750)
#   2. Cleans and prepares key variables:
#      - CO2 emissions per capita
#      - Total CO2 emissions
#      - GDP per capita
#      - Date conversion
#   3. Generates a suite of visualizations to explore:
#      • Global trends over time (average per-capita CO2)
#      • Country-level snapshots (latest per-capita and total emissions)
#      • Relationships between CO2 and economic indicators (GDP)
#      • Top emitters, quartile analyses, and cumulative sums
#      • Year-over-year changes and heatmaps by GDP quartile
#   4. Fits and reports a linear regression model predicting CO2 per capita 
#      from GDP per capita, with summary statistics and annotated plot.
#
# Dependencies:
#   - ggplot2, dplyr, lubridate, tidyr, forcats, scales, viridis, rnaturalearth, 
#     rnaturalearthdata, sf, zoo, corrplot
#
# Usage:
#   1. Ensure R ≥ 4.0 is installed and internet access is enabled.
#   2. Run this script in R or RStudio: `source("CO2_Analysis.R")`
#   3. All charts will display in sequence and the regression summary prints to console.
#
# Data Source:
#   https://github.com/owid/co2-data
# =================================================================================

# 0. Install & load packages
pkgs <- c("ggplot2","dplyr","lubridate","forcats","tidyr","scales")
for(pkg in pkgs) if(!requireNamespace(pkg, quietly=TRUE)) install.packages(pkg)
lapply(pkgs, library, character.only=TRUE)

# 1. Fetch & prepare OWID CO2 data
url <- "https://raw.githubusercontent.com/owid/co2-data/master/owid-co2-data.csv"
co2_raw <- read.csv(url, stringsAsFactors=FALSE)

co2 <- co2_raw %>%
  filter(!is.na(co2_per_capita), !is.na(gdp), population > 0, year >= 1960) %>%
  transmute(
    country   = country,
    iso_code  = iso_code,
    date      = as.Date(paste0(year, "-01-01")),
    year      = year,
    co2_pc    = co2_per_capita,
    total_co2 = co2,                # Mt
    gdp_pc    = gdp / population
  )

# Latest per-country
latest <- co2 %>%
  group_by(iso_code, country) %>%
  slice_max(year, n=1, with_ties=FALSE) %>%
  ungroup()

# 2. Global time-series: average CO2 per capita
global_ts <- co2 %>%
  group_by(date) %>%
  summarize(avg_co2_pc = mean(co2_pc, na.rm=TRUE), .groups="drop")
p1 <- ggplot(global_ts, aes(date, avg_co2_pc)) +
  geom_line(color="forestgreen") +
  labs(title="Global Average CO2 per Capita Over Time",
       x="Date", y="t CO2 per Capita") +
  theme_minimal()
print(p1)

# 3. Scatter: GDP per cap vs CO2 per cap (latest)
p2 <- ggplot(latest, aes(gdp_pc, co2_pc)) +
  geom_point(alpha=0.5) +
  geom_smooth(method="loess", se=FALSE, color="darkred") +
  labs(title="GDP per Capita vs CO2 per Capita (Latest)",
       x="GDP per Capita (USD)", y="t CO2 per Capita") +
  theme_minimal()
print(p2)

# 4. Regression plot + summary
model <- lm(co2_pc ~ gdp_pc, data=latest)
cat("\n===== Regression Summary =====\n"); print(summary(model))
p3 <- ggplot(latest, aes(gdp_pc, co2_pc)) +
  geom_point(alpha=0.3) +
  geom_smooth(method="lm", se=TRUE, color="blue") +
  labs(
    title="Linear Regression: CO2 per Capita ~ GDP per Capita",
    subtitle=paste0("R²=", round(summary(model)$r.squared,3),
                    "; p=", signif(summary(model)$coefficients[2,4],3)),
    x="GDP per Capita (USD)", y="t CO2 per Capita"
  ) +
  theme_minimal()
print(p3)

# 5. Top 10 countries by CO2 per capita
top10_pc <- latest %>% arrange(desc(co2_pc)) %>% slice_head(n=10)
p4 <- ggplot(top10_pc, aes(fct_reorder(country, co2_pc), co2_pc)) +
  geom_col(fill="darkslateblue") +
  coord_flip() +
  labs(title="Top 10 Countries by CO2 per Capita (Latest)",
       x="", y="t CO2 per Capita") +
  theme_minimal()
print(p4)

# 6. Time-series: CO2 per cap for top 5 emitters
top5 <- top10_pc$iso_code[1:5]
ts_top5 <- co2 %>% filter(iso_code %in% top5)
p5 <- ggplot(ts_top5, aes(date, co2_pc, colour=country)) +
  geom_line() +
  labs(title="CO2 per Capita Over Time: Top 5 Countries",
       x="Date", y="t CO2 per Capita", colour="Country") +
  theme_minimal()
print(p5)

# 7. GDP per cap quartiles: boxplot of CO2 per cap
latest_q <- latest %>% mutate(gdp_q = ntile(gdp_pc, 4))
p6 <- ggplot(latest_q, aes(factor(gdp_q), co2_pc, fill=factor(gdp_q))) +
  geom_boxplot() +
  scale_fill_viridis_d(name="GDP Quartile") +
  labs(title="CO2 per Capita by GDP per Capita Quartile",
       x="GDP Quartile", y="t CO2 per Capita") +
  theme_minimal()
print(p6)

# 8. GDP quartile violin
p7 <- ggplot(latest_q, aes(factor(gdp_q), co2_pc, fill=factor(gdp_q))) +
  geom_violin() +
  scale_fill_viridis_d(option="turbo", name="GDP Quartile") +
  labs(title="Distribution of CO2 per Capita by GDP Quartile",
       x="GDP Quartile", y="t CO2 per Capita") +
  theme_minimal()
print(p7)

# 9. Heatmap: avg CO2 per cap by year & GDP quartile
heat_data <- co2 %>%
  inner_join(latest_q %>% select(iso_code, gdp_q), by="iso_code") %>%
  group_by(year, gdp_q) %>%
  summarize(avg_pc = mean(co2_pc, na.rm=TRUE), .groups="drop")
p8 <- ggplot(heat_data, aes(year, factor(gdp_q), fill=avg_pc)) +
  geom_tile(color="white") +
  scale_fill_viridis(name="Avg t CO2 per Capita") +
  labs(title="Avg CO2 per Capita by Year & GDP Quartile",
       x="Year", y="GDP Quartile") +
  theme_minimal()
print(p8)

# 10. Cumulative sum of CO2 per capita
cum_pc <- co2 %>%
  arrange(date) %>%
  group_by(date) %>%
  summarize(sum_pc = sum(co2_pc, na.rm=TRUE), .groups="drop") %>%
  mutate(cum_pc = cumsum(sum_pc))
p9 <- ggplot(cum_pc, aes(date, cum_pc)) +
  geom_line(color="purple") +
  labs(title="Cumulative Sum of CO2 per Capita Over Time",
       x="Date", y="Cumulative t CO2 per Capita") +
  theme_minimal()
print(p9)

# 11. Year-over-year % change in global avg CO2 per capita
pct_change <- global_ts %>%
  arrange(date) %>%
  mutate(pct = 100 * (avg_co2_pc - lag(avg_co2_pc)) / lag(avg_co2_pc))
p10 <- ggplot(pct_change, aes(date, pct)) +
  geom_line(color="orange") +
  labs(title="Year-over-Year % Change in Global Avg CO2 per Capita",
       x="Date", y="% Change") +
  theme_minimal()
print(p10)

# 12. Scatter: CO2 per cap vs total CO2 (latest)
p11 <- ggplot(latest, aes(total_co2, co2_pc)) +
  geom_point(alpha=0.5) +
  geom_smooth(method="lm", se=FALSE, color="darkgreen") +
  scale_x_log10(labels=comma) +
  labs(title="CO2 per Capita vs Total CO2 Emissions (Latest)",
       x="Total CO2 (Mt, log scale)", y="t CO2 per Capita") +
  theme_minimal()
print(p11)

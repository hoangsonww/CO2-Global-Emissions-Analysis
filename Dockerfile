# Base image with R
FROM r-base:4.3.2

# System deps for geospatial if needed later
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev libssl-dev libxml2-dev

# Install R packages
RUN R -e "install.packages(c('ggplot2','dplyr','lubridate','forcats','tidyr','scales','viridis','rmarkdown'), repos='https://cloud.r-project.org/')"

WORKDIR /app
COPY . .

# Default: build report
CMD ["bash", "scripts/build_report.sh"]

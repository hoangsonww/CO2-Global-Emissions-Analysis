.PHONY: all data analysis report clean

DATA_CSV := data/owid-co2-data.csv
R_SCRIPT := CO2_Analysis.R
RMD      := CO2_Analysis.Rmd
HTML     := CO2_report.html

all: report

data: $(DATA_CSV)

$(DATA_CSV):
	mkdir -p data
	bash scripts/fetch_co2.sh

analysis: data
	Rscript $(R_SCRIPT)

report: analysis $(RMD)
	Rscript -e "rmarkdown::render('$(RMD)', output_file='$(HTML)')"

clean:
	rm -rf data/*.csv *.html

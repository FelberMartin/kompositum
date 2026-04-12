## Sources for the data 

- Compounds (split_compounds_from_GermaNet18.0.txt): https://uni-tuebingen.de/fakultaeten/philosophische-fakultaet/fachbereiche/neuphilologie/seminar-fuer-sprachwissenschaft/arbeitsbereiche/allg-sprachwissenschaft-computerlinguistik/ressourcen/lexica/germanet-1/beschreibung/compounds/#Downloads
- German word frequency lists:
    - derewo-v-ww-bll-250000g-2011-12-31-0.1/derewo-v-ww-bll-250000g-2011-12-31-0.1.txt: https://www.ids-mannheim.de/digspra/kl/projekte/methoden/derewo/
    - deu-de_web_2021_1M-words.txt: https://wortschatz.uni-leipzig.de/de/download/German#deu_news_2023


### How to run the pipeline

1. cleansing_and_ad_freq.ipynb
2. include_reported_and_remove_blocked_compounds.ipynb


# How to add newly reported compounds

1. Run `lib/fetch_reported_compounds.dart` main function to fetch the reported compounds.
2. Paste the compounds from the console output into `data/reported/all_reported.csv`
3. Based on the diff, copy all the new ones over to `report_accepted`
4. Remove all the reports that you reject
5. Run `include_reported_and_remove_blocked_compounds.ipynb` (via PyCharm)
6. This will automatically update the `assets/final_compounds.csv`
7. Create a new release to apply these new reports
## Sources for the data 

- Compounds (split_compounds_from_GermaNet18.0.txt): https://uni-tuebingen.de/fakultaeten/philosophische-fakultaet/fachbereiche/neuphilologie/seminar-fuer-sprachwissenschaft/arbeitsbereiche/allg-sprachwissenschaft-computerlinguistik/ressourcen/lexica/germanet-1/beschreibung/compounds/#Downloads
- German word frequency list (derewo-v-ww-bll-250000g-2011-12-31-0.1/derewo-v-ww-bll-250000g-2011-12-31-0.1.txt): https://www.ids-mannheim.de/digspra/kl/projekte/methoden/derewo/


# How to run the pipeline

1. compound_cleansing.ipynb     -> Removing compounds with hyphens, spaces, duplicates, etc.
2. compound_filtering.ipynb     -> Adding the frequency data
3. include_reported_and_remove_blocked_compounds.ipynb      -> 
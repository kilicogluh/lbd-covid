# Drug repurposing for COVID-19 using literature-based discovery

This repository contains source code related to the publication

> Zhang, R., Hristovski, D., Schutte, D., Kastrin, A., Fiszman, M., & Kilicoglu, H. (2021). Drug repurposing for COVID-19 via knowledge graph completion. Journal of Biomedical Informatics, 115, 103696. https://doi.org/10.1016/j.jbi.2021.103696

## Prerequisites

- Python 3.6 with packages `lxml`, `numpy`, and `pandas`
- Perl 5 with module `Text::NSP`
- AWK

## Directory Structure

- `./data` directory contains input files
- `./preprocessing` directory contains scripts for preparing data
- `./models` directory contains scripts for knowledge graph completion
- `./predictions` directory contains output files from graph completion models

## Usage

1. Download and set up [SemMedDB](https://skr3.nlm.nih.gov/SemMedDB/)
2. Create `./data` directory in project's root folder
3. Prepare `sub_rel_obj_pyear_edat_pmid_sent_id_sent.tsv.gz` file and place it into the `./data/SemMedDB` directory
4. Download SemRepped [CORD-19](https://ii.nlm.nih.gov/SemRep_SemMedDB_SKR/COVID-19/index.shtml) dataset and extract files into `./data/cord-19 directory`
5. Prepare SemMedDB and CORD-19 data using the `./preprocessing/run.sh` file
6. Run Python notebooks in the `./models` directory

## Contact

Halil Kilicoglu (`halil (at) illinois.edu`)


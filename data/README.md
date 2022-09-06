# How to preprocess SemMedDB

1. Use `semmed42_arg_rel_min_pyear.awk` to prepare `sub_rel_obj_pyear_edat_pmid_sent_id_sent.tsv.gz` file and place it into the `./data/SemMedDB` directory
2. Download SemRepped CORD-19 dataset and extract files into `./data/cord-19` directory
3. Use `create_data.py` to generate:
- entity2id.txt
- relation2id.txt
- train2id.txt
- valid2id.txt
- test2id.txt

4. Demo files with `_example` suffix for:
- entities.tsv
- relations. tsv
- train.tsv
- valid.tsv
- test.tsv

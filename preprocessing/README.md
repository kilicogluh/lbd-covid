# Readme

## Create `constraints.json` file

First update the following files:

* `semmedVER43_2020_R_GENERIC_CONCEPT`
* `included_predicate_types.txt`
* `bidirectional_predicate_types.txt`
* `excluded_semantic_types.txt`

Next, run the `create_constraints_file.py` which writes defined constraints

## Filter predications

Process input file **without** `sent_text` in the last field:
```bash
./filter_semantic_predications.py -i sub_rel_obj_pyear_pmid_sent_id_with_cord_19.tsv -c constraints.json > sub_rel_obj_pyear_pmid_sent_id_with_cord_19_filtered.tsv
```

Process input file **with** `sent_text` in the last field:
```bash
./filter_semantic_predications.py -t -i sub_rel_obj_pyear_pmid_sent_id_with_cord_19.tsv -c constraints.json > sub_rel_obj_pyear_pmid_sent_id_with_cord_19_filtered.tsv
```

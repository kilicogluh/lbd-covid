# Convert GENERIC_CONCEPT table from sql to csv format
zcat ./data/SemMedDB/semmedVER43_2020_R_GENERIC_CONCEPT.sql.gz | ./mysqldump_to_csv.py > ./conf/semmedVER43_2020_R_GENERIC_CONCEPT.csv

# Create constraints file
./create_constraints.py

# Repair metadata.csv file
awk 'NR==FNR { nums[$0]; next } !(FNR in nums)' <(csvcut -c 7 ./data/cord-19/2020-09-25/metadata.csv | grep -n "doi" | cut -d: -f1) ./data/cord-19/2020-09-25/metadata.csv > ./data/cord-19/2020-09-25/metadata2.csv 

# Extract relations from SemRep files
jupyter nbconvert --to notebook --inplace --ExecutePreprocessor.timeout=None --execute extract_semrep.ipynb

# Combine both SemMedDB and CORD-19 files
zcat ./data/SemMedDB/sub_rel_obj_pyear_edat_pmid_sent_id_sent.tsv.gz ./data/CORD-19/2020-09-28/sub_rel_obj_pyear_edat_pmid_sent_id_sent.tsv.gz | sort | uniq > ./data/sub_rel_obj_pyear_edat_pmid_sent_id_sent.tsv

# Filter semantic predications
./filter_predications.py -i ./data/sub_rel_obj_pyear_edat_pmid_sent_id_sent.tsv -c ./conf/constraints.json -t | sort | uniq > ./data/sub_rel_obj_pyear_edat_pmid_sent_id_sent_filtered.tsv


# Create dummy file with one subject-relation-object triple per line
cut -d$'\t' -f1,4,5 --output-delimiter=' ' ./data/sub_rel_obj_pyear_edat_pmid_sent_id_sent_filtered.tsv > ./data/sub_rel_obj.txt

# Run count.pl program
count.pl --ngram 3 --newLine --token ./conf/token.txt ./data/count.txt ./data/sub_rel_obj.txt

# Compute statistics
statistic.pl --ngram 3 ll ./data/stats.txt ./data/count.txt

# Degree distribution
cat <(cut -d$' ' -f1 ./data/sub_rel_obj.txt) <(cut -d$' ' -f3 ./data/sub_rel_obj.txt) | sort | uniq -c | awk '{print $2, $1}' > ./data/concept_degree.txt

# Add degrees, normalize data, and compute final score
jupyter nbconvert --to notebook --inplace --ExecutePreprocessor.timeout=None --execute compute_score.ipynb


THRESHOLD=$(cut -d$'\t' -f 5 ./data/sub_rel_obj_freq_score.tsv | sort -n | awk '{all[NR] = $0} END{print all[int(NR*0.30 - 0.5)]}')

# Trim table when sum of relations is <= 2,500,000
# Append COVID-19 terms to the file
cat <(awk -v thres=$THRESHOLD -F"\t" '$5 < thres+0' ./data/sub_rel_obj_freq_score.tsv | awk -v val="2500000" 'BEGIN{FS="\t"}($4 + prev) > val{exit} ($4 + prev) <= val{print}{prev += $4}') <(grep -E "C5203670|C5203671|C5203672|C5203673|C5203674|C5203675|C5203676" ./data/sub_rel_obj_freq_score.tsv) | sort | uniq > ./data/sub_rel_obj_freq_score_subset.tsv

# Create final files
./merge_tables.py

# Clean data
rm ./data/*.txt
rm ./data/*.tsv

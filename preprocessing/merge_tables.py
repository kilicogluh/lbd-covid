#!/usr/bin/env python
# coding: utf-8

import logging
import subprocess
from tqdm import tqdm

logging.basicConfig(format='%(levelname)s: %(message)s', level=logging.DEBUG)

logging.info('Reading dictionary...')
cui2cui = {}
with open('./data/sub_rel_obj_freq_score_subset.tsv', 'r') as fh:
    for line in fh:
        fls = line.rstrip('\n').split('\t')
        triple = (fls[0], fls[1], fls[2])
        cui2cui[triple] = 1

logging.debug('Counting lines in input file...') 
fh1 = open('./data/sub_rel_obj_pyear_edat_pmid_sent_id_sent_subset.tsv', 'w')
fh2 = open('./data/sub_rel_obj_edat_pmid_sent_subset.tsv', 'w')
num_lines = int(subprocess.check_output("/usr/bin/wc -l ./data/sub_rel_obj_pyear_edat_pmid_sent_id_sent_filtered.tsv", shell=True).split()[0])

logging.info('Writing to output files...')
with open('./data/sub_rel_obj_pyear_edat_pmid_sent_id_sent_filtered.tsv', 'r') as fh:
    for line in tqdm(fh, total=num_lines):
        fls = line.rstrip('\n').split('\t')
        triple = (fls[0], fls[3], fls[4])
        if triple in cui2cui:
            fh1.write(fls[0] + '\t' + fls[1] + '\t' + fls[2] + '\t' + fls[3] + '\t' + fls[4] + '\t' +fls[5] + '\t' + \
                      fls[6] + '\t' + fls[7] + '\t' + fls[8] + '\t' + fls[9] + '\t' + fls[10] + '\t' + fls[11] + '\n')
            fh2.write(fls[0] + '\t' + fls[3] + '\t' + fls[4] + '\t' + fls[8] + '\t' + fls[9] + '\t' + fls[11] + '\n')
            
fh1.close()
fh2.close()


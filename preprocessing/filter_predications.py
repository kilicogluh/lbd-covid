#!/usr/bin/env python
# coding: utf-8

# This program filters SEMANTIC_PREDICATIONS file according to the constraints
# specified in the constraints.json file
# run : ./filter_semantic_predications.py -i INPUT_FILE -c constraints.json
#       cat INPUT_FILE | ./filter_semantic_predications.py -c constraints.json

import sys
import argparse
import json

parser = argparse.ArgumentParser()
parser.add_argument('-i', '--input', nargs='?')
parser.add_argument('-c', '--constr')
parser.add_argument('-t', '--text', action='store_true')
args = parser.parse_args()

def read_constr():
    """ Read configuration file """
    with open(args.constr) as fh:
        data = json.load(fh)
    return data

def process_line(line, constr):
    """ Process line and write it to stdout """
    preds_lst = constr['included_predicates']
    bidir_lst = constr['directed_predicates']
    semty_lst = constr['excluded_semantic_types']

    if args.text:
        subject_cui, subject_name, subject_sty, predicate, object_cui, object_name, object_sty, year, edat, pmid, sent_id, sent_text = line.rstrip('\n').split('\t')
        if (predicate in preds_lst):
            if ((subject_sty not in semty_lst) and (object_sty not in semty_lst)):
                print(subject_cui, subject_name, subject_sty, predicate, object_cui, object_name, object_sty, year, edat, pmid, sent_id, sent_text, sep='\t')
                if (predicate in bidir_lst):
                    print(object_cui, object_name, object_sty, predicate, subject_cui, subject_name, subject_sty, year, edat, pmid, sent_id, sent_text, sep='\t')
    else:
        subject_cui, subject_name, subject_sty, predicate, object_cui, object_name, object_sty, year, edat, pmid, sent_id = line.rstrip('\n').split('\t')
        if (predicate in preds_lst):
            if ((subject_sty not in semty_lst) and (object_sty not in semty_lst)):
                print(subject_cui, subject_name, subject_sty, predicate, object_cui, object_name, object_sty, year, edat, pmid, sent_id, sep='\t')
                if (predicate in bidir_lst):
                    print(object_cui, object_name, object_sty, predicate, subject_cui, subject_name, subject_sty, year, edat, pmid, sent_id, sep='\t')
     
def main():
    constr = read_constr()
    if args.input:
        with open(args.input) as f:
            for line in f:
                process_line(line, constr)
    elif not sys.stdin.isatty():
        for line in sys.stdin:
            process_line(line, constr)

if __name__ == '__main__':
    main()

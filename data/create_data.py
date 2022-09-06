#!/usr/bin/env python
# coding: utf-8

import random
import pandas as pd

entity_set = set([])
relation_set = set([])
triple_lst = []

fin = open('./data/semmed42_rel_with_cord_19.srt', 'r')

for idx, line in enumerate(fin.readlines()):
    head, rel, tail = line.strip().split(',')
    entity_set.add(head)
    entity_set.add(tail)
    relation_set.add(rel)
    triple = (head, rel, tail)
    triple_lst.append(triple)
fin.close()

entity2id_dct = dict(zip(entity_set, range(len(entity_set))))
relation2id_dct = dict(zip(relation_set, range(len(relation_set))))

def write_dict(dct, file):
    dct_srt = {k: v for k, v in sorted(dct.items(), key=lambda item: item[1])}
    fout = open(file, 'w')
    fout.write(str(len(dct_srt)) + '\n')
    for key in dct_srt:
        line = '{}\t{}\n'.format(key, dct_srt[key])
        fout.write(line)
    fout.close()
    return

write_dict(entity2id_dct, './data/entity2id.txt')
write_dict(relation2id_dct, './data/relation2id.txt')

triple_lst = [(entity2id_dct[k[0]], relation2id_dct[k[1]], entity2id_dct[k[2]]) for k in triple_lst]
train_n = int(len(triple_lst) * 0.8)
valid_n = int(len(triple_lst) * 0.1)

def write_triple(lst, file):
    fout = open(file, 'w')
    fout.write(str(len(lst)) + '\n')
    for head, rel, tail in lst:
        line = '{}\t{}\t{}\n'.format(head, tail, rel)
        fout.write(line)
    fout.close()
    return

write_triple(triple_lst[:train_n], './data/train2id.txt')
write_triple(triple_lst[train_n : train_n + valid_n], './data/valid2id.txt')
write_triple(triple_lst[train_n + valid_n :], './data/test2id.txt')

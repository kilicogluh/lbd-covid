#!/usr/bin/env python
# coding: utf-8

import json
import pandas as pd

GENERIC_CONCEPT = './data/semmedVER43_2020_R_GENERIC_CONCEPT.csv'
PREDICATES = './data/included_predicate_types.txt'
BIDIR_PREDICATES = './data/bidirectional_predicate_types.txt'
SEMANTIC_TYPES = './data/excluded_semantic_types.txt'
OUTPUT = './constraints.json'

# Read GENERIC_CONCEPT table
df1 = pd.read_csv(GENERIC_CONCEPT, header=None, names=['concept_id', 'cui', 'preferred_name'], usecols=['cui'])
lst1 = df1['cui'].values.tolist()

## Read allowed predicate types
df2 = pd.read_csv(PREDICATES, header=None, names=['predicate'])
lst2 = df2['predicate'].values.tolist()

## Read bidirectional predicate types
df3 = pd.read_csv(BIDIR_PREDICATES, header=None, names=['predicate'])
lst3 = df3['predicate'].values.tolist()

## Read excluded semantic types
df4 = pd.read_csv(SEMANTIC_TYPES, sep='|', header=None, comment='#', usecols=[4], names=['sty'])
lst4 = df4['sty'].values.tolist()

dct = {'generic_concepts': lst1, 'included_predicates': lst2, 'directed_predicates': lst3, 'excluded_semantic_types': lst4}

with open(OUTPUT, 'w') as fh:
    fh.write(json.dumps(dct, indent=4))

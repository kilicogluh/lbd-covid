from pathlib import Path

class SemRep(object):
    """
    A class used to represent a SemRep output.
    
    Attributes
    ----------
    file_in : str
        the name of a file 
    """

    def __init__(self, file_in):
        self.file_in = file_in
        self.cord_uid = Path(file_in).with_suffix('').stem

    def extraction(self):
        with open(self.file_in, encoding='utf-8') as fh:
            return self.parse(fh)

    def parse(self, lines):
        extr = {}
        for rec in self.parse_records(lines):
            pmid, relations = self.parse_record(rec)
            extr.setdefault(self.cord_uid, []).extend(relations)
        return extr

    def parse_records(self, lines):
        rec = []
        for line in lines:
            if line.strip():
                rec.append(line)
            elif rec:
                yield rec
                rec = []
        if rec:
            yield rec

    def parse_record(self, rec):
        pmid = None
        relations = []
        for line in rec:
            if not line.startswith('SE'):
                continue
            xs = line.strip().split('|')
            row_type = xs[5]
            if row_type == 'text':
                pmid = xs[1]
                sent_id = xs[4]
                sent_text = xs[8]
            elif row_type == 'relation':
                relations.append({
                    'subject_cui': xs[8],
                    'subject_label': xs[9],
                    'subject_sem_type': xs[11],
                    'subject_geneid': xs[12],
                    'subject_gene_name': xs[13],
                    'predicate': xs[22],
                    'negation': xs[23],
                    'object_cui': xs[28],
                    'object_label': xs[29],
                    'object_sem_type': xs[31],
                    'object_geneid': xs[32],
                    'object_gene_name': xs[33],
                    'sent_id': sent_id,
                    'sent_text': sent_text
                })
        return (pmid, relations)

"""Verify source integrity and literal excerpt correspondence (standard Python).

This complements, and does not replace, reproduction/run.sh's Rocq check.
Run from any directory: python3 checks/verify_materials.py
"""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


provenance=json.loads((ROOT/'PROVENANCE.json').read_text())
data=json.loads((ROOT/'report-data.json').read_text())
for source in provenance['source_files']:
    assert sha(ROOT/source['path'])==source['sha256'],source['path']
for excerpt in provenance['code_excerpts']:
    path=ROOT/excerpt['file']
    ref=provenance['references'][excerpt['source']]
    source=ROOT/'upstream/coturn'/ref['path']
    text=''.join(source.read_text().splitlines(keepends=True)[ref['first_line']-1:ref['last_line']])
    assert hashlib.sha256(text.encode()).hexdigest()==excerpt['body_sha256']
    assert path.read_text().endswith(text),excerpt['file']
    assert sha(path)==excerpt['sha256'],excerpt['file']

vendor=json.loads((ROOT/'reproduction/vendor-manifest.json').read_text())
assert vendor['commit']==provenance['proof_repository']['commit']
for item in vendor['files']:
    relative=item['path'].split('/lib/',1)[1]
    assert sha(ROOT/'reproduction/vendor'/relative)==item['sha256'],relative

original=json.loads((ROOT/'evidence/original-rocq-result.json').read_text())
packaged=json.loads((ROOT/'reproduction/result.json').read_text())
assert original['status']==packaged['status']=='PASS'
assert original['checked_sources']==packaged['checked_sources']==88
assert original['audit_source_sha256']==packaged['audit_source_sha256']
assert original['all_assumptions_in_upstream_allowlist'] and packaged['all_assumptions_in_upstream_allowlist']
assert set(original['assumptions'])==set(packaged['assumptions'])
for name,expected in original['audit_source_sha256'].items():
    assert sha(ROOT/'reproduction/proof'/f'{name}.v')==expected,name
for name,expected in original['binary_sha256'].items():
    assert sha(ROOT/'reproduction/input'/name)==expected,name

complete=(ROOT/'reproduction/proof/Complete.v').read_text().splitlines()
statements=[b['text'].rstrip('\n') for b in data['blocks'] if b['kind']=='code'
            and b.get('caption','').startswith(('ASan: reproduction/proof/Complete.v:',
                                               'ASan+UBSan: reproduction/proof/Complete.v:'))]
assert statements==['\n'.join(complete[55:68]),'\n'.join(complete[126:139])], 'Report changed literal Rocq statements'
inventory=json.loads((ROOT/'evidence/bzip2-field-bounds-audit.json').read_text())
fields=[f for record in inventory['structs'].values() for f in record['fields']]
assert len(fields)==115
assert sum(bool(f['array_dimensions']) for f in fields)==24

print(json.dumps({'status':'PASS','literal_C_excerpts':len(provenance['code_excerpts']),
                  'vendor_sources':len(vendor['files']),'audit_sources':len(original['audit_source_sha256']),
                  'original_and_packaged_Rocq_sources_identical':True,
                  'literal_Rocq_statements':2,'bzip2_fields':len(fields),'bzip2_inline_arrays':24},indent=2))

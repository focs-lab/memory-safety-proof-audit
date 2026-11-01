"""Extract and check a field-bound omission in a published internal invariant.

This checks certificate data and arithmetic, not harness reachability or the
Rocq development. It does not execute the target binary.
"""
import hashlib
import json
from pathlib import Path
from rv_inspect import word, decode

BASE = Path('/Users/umang/Documents/ChatGPT/Verification gaps')
PROOF = 'a6839bb9e433b34c0d0710df5280194528877139'
SOURCE = '70ca74e0bd8300e22a179e9a7beead862763ca5c'
LIB = 'proofs/coturn/FuzzStunClient/lib/'
units = json.loads((BASE / 'tmp/struct-field-search/coturn-certificate.json').read_text())
unit = next(u for u in units if u['vid'] == 166)
cut = next(c for c in unit['cuts'] if c['pc'] == 0x18994)
state = cut['states'][0]
after = next(c for c in unit['cuts'] if c['pc'] == 0x189ac)['states'][0]
assert unit['entry'] == 0x18898 and unit['certificate_file'] == 'VCertS_src0_p01.v'
assert dict(state['regs'])[20] == {'const': -65628, 'terms': [[1, 1]]}
assert dict(state['regs'])[24] == {'const': -65629, 'terms': [[1, 1]]}
assert unit['wstack'] == [[-65629, -65585], [-120, -112]]
assert not any(state[k] for k in ('cons', 'valset', 'conddef', 'moddef', 'nul', 'globs'))
nu = {i: 0 for i in range(1, state['next'])}
nu.update({1: 0x7fff80000000, 2: 0x400000, 3: 1, 4: 0x192f4,
           17: 0x367b0, 21: 12, 23: 4, 27: 20, 28: 8})
ev = lambda e: e['const'] + sum(nu[i]*a for i, a in e['terms'])
assert all((lo is None or lo <= nu[i]) and (hi is None or nu[i] <= hi)
           for i, lo, hi in state['box'])
assert all((nu[i]-r) % m == 0 for i, m, r in state['cong'])
assert all(ev(c) <= 0 for c in state['cons'])
assert 63 < state['next']
for kind in ('regs', 'slots', 'globs'):
    for item in state[kind]:
        assert all(i < state['next'] for i, a in item[-1]['terms'])
memory = {}
for off, width, e in state['slots']:
    assert -132544 <= off and width > 0 and off+width <= 0
    val = ev(e) % (1 << (8*width))
    for i, b in enumerate(val.to_bytes(width, 'little')):
        assert off+i not in memory or memory[off+i] == b
        memory[off+i] = b
assert any(off == -65629 and width == 1 for off, width, e in after['slots'])
assert word(0x18998) == 0x00ac0023
assert decode(0x18998) == 'sb x10, 0(x24)'
assert -132544 <= -65629 and -65629+1 <= 0
assert any(lo <= -65629 and -65629+1 <= hi for lo, hi in unit['wstack'])
assert (-65629)-(-65628) == -1
assert (-65629)-(-65632) == 3
bin_file = BASE / 'tmp/struct-field-search/binaries/FuzzStunClient/FuzzStunClient.plain'
sha = hashlib.sha256(bin_file.read_bytes()).hexdigest()
assert sha == '087641c6fcee7a7c11340e42b08651160429ec9d1ec42724a9560455214ff81b'

def ref(file, line):
    return f'https://github.com/theorem-labs/oss-verify-proofs/blob/{PROOF}/{LIB}{file}#L{line}'

outdir = BASE / 'source-snapshots/coturn'
outdir.mkdir(exist_ok=True)
evidence = {
    'proof_commit': PROOF, 'source_commit': SOURCE, 'binary_sha256': sha,
    'finding': 'A checked internal certificate disjunct permits a one-byte store at buf[-1], which is channel[3] in the enclosing stun_buffer.',
    'unit_vid': 166, 'unit_entry': '0x18898', 'cut_pc': '0x18994', 'disjunct_index': 0,
    'instruction_pc': '0x18998', 'instruction_word': '0x00ac0023',
    'instruction': 'sb x10, 0(x24)',
    'struct_base_relative_to_sp0': -65632, 'buf_base_relative_to_sp0': -65628,
    'buf_length': 65507, 'store_relative_to_sp0': -65629,
    'store_field_index': -1, 'destination_neighbor': 'channel[3]',
    'unit_write_set': unit['wstack'], 'full_decoded_cut_disjunct': state,
    'full_decoded_precondition': unit['pre'],
    'valuation_satisfying_all_recorded_pure_constraints': nu,
    'selected_decoded_post_store_slot': next(x for x in after['slots'] if x[0] == -65629),
    'proof_call_chain': [
        {'caller_vid': 249, 'root_input_size_class': [1, 1], 'call_pc': '0x14c90', 'callee_vid': 170},
        {'caller_vid': 170, 'call_pc': '0x192f0', 'callee_vid': 166}
    ],
    'locations': {
        'encoded_certificate': ref('VCertS_src0_p01.v', 5),
        'decode_state': ref('VCertDecode.v', 139),
        'decode_unit': ref('VCertDecode.v', 167),
        'certificate_assembly': ref('VCert_src0.v', 10),
        'certificate_check': ref('VCertCheck_src0.v', 8),
        'used_in_function_contract': ref('VFC_src0.v', 9),
        'memory_access_check': ref('VStepMem.v', 52),
        'concretization': ref('VGamma.v', 89),
        'unit_write_regions': ref('VDriver.v', 40)
    },
    'checks_performed': [
        'Decoded both complete plain-certificate chunks, checking complete input consumption.',
        'Checked selected disjunct intervals, congruences, linear constraints, symbol bounds and slot-byte consistency.',
        'Matched instruction to the release binary after verifying its published SHA256.',
        'Checked store inclusion in stack and per-unit write ranges.',
        'Traced unit references from an included root certificate.'
    ],
    'limits': [
        'No input reaching this disjunct is supplied or claimed.',
        'No vulnerability or exploit conclusion is made.',
        'This is an omission in the maintained plain-proof invariant, not a proof that field safety is false for the harness.',
        'The target binary was not executed; the complete Rocq development was not independently replayed.'
    ]
}
(outdir / 'field-bound-witness.json').write_text(json.dumps(evidence, indent=2)+'\n')
text = f'''Coturn internal struct-field bound audit
Date: 2026-11-01
Proof repository commit: {PROOF}
Pinned coturn source: {SOURCE}

Finding and scope
The internal plain-binary proof has an explicit invariant disjunct in
which a store through a pointer derived from stun_buffer.buf targets
buf[-1], inside channel[3]. The recorded tighter facts do not exclude it.
This is an invariant/specification omission. It is not a claim that a
covered fuzzer input reaches this state, and is not a vulnerability finding.

Source and field geometry
src/apps/common/stun_buffer.h:45-51 defines channel[4], buf[65507], len,
offset and coffset. Constants are in src/ns_turn_defs.h:221-222 and
src/client/ns_turn_msg_defs.h:47.
On RV64, the struct starts at B = sp0 - 65632 in this certificate context.
channel = [B, B+4); buf = [B+4, B+65511); len starts at B+65512.
Therefore buf[0] = sp0-65628, and channel[3] = buf[-1] = sp0-65629.

Concrete access
stun_attr_add_str, src/client/ns_turn_msg.c:1688-1694:
  uint8_t *attr_start = buf + clen;
  turn_write_u16(attr_start, attr);
The first lowered byte store is at PC 0x18998:
  word 0x00ac0023 = sb x10, 0(x24)
The previous instruction at 0x18994 only shifts x10 into x11.
There is no branch or guard between the selected cut and the store.

Exact decoded proof location
Certificate: VCertS_src0_p01.v:5, decoded by VCertDecode.v.
Selector: u_vid = 166, u_entry = 0x18898;
          cut_pc = 0x18994, cut_ctx = [], cut_states index 0.
Selected register facts:
  x20 = sp0 - 65628     (buf)
  x24 = sp0 - 65629     (attr_start)
  x10 = 256*s21
Selected slot facts:
  byte at sp0-65626 = 0
  byte at sp0-65625 = s28 mod 256
  8 bytes at sp0-120 = 4+s23
The cut also records saved register slots; they are disjoint and
consistent. The full disjunct is retained in field-bound-witness.json.

All pure constraints at this cut
Intervals:
  s21 in [12,18]; s23 in [4,8]; s27 in [20,28]; s28 in [0,8];
  DATA in [1,2^63-1]; SIZE in [1,4096];
  sp0 in [140735340867584,140737488355328].
Congruences (m divides value-r):
  (s21,2,0); (s23,4,0); (s27,8,4); (s28,8,0); (sp0,16,0).
Linear constraints, valsets, conditional definitions, modular definitions,
NUL assertions and global slot assertions are empty in this disjunct.
A satisfying arithmetic assignment is s21=12, s23=4, s27=20, s28=8,
sp0=0x7fff80000000, DATA=0x400000, SIZE=1. Thus the negative field index
is not excluded by a tighter interval, congruence or relational fact.

Why the verifier accepts it
Unit 166's write set is:
  [sp0-65629,sp0-65585) and [sp0-120,sp0-112).
It explicitly includes the neighboring byte before buf.
VStepMem.v:52-68 checks the stack window and this write set. It contains
no additional lower bound derived from the C field start.
VGamma.v:89-93 lists the complete concretization predicate; its memory
condition, VGamma.v:49-54, covers the whole stack window. Its pure
conditions are precisely the interval/congruence/linear/value conditions
checked above, plus finite symbol/slot well-formedness.

The immediately later cut 0x189ac, disjunct 0, records a one-byte slot at
sp0-65629. Thus this is visible after the store as well as before it.

Inclusion in the completed proof
Root unit 249 (entry 0x13e80, input-size class [1,1]) references unit 170
at call PC 0x14c90. Unit 170 references unit 166 at call PC 0x192f0.
VCert_src0.v:10 assembles the decoded certificate.
VCertCheck_src0.v:8 states check_cert ... cert_src0 = ROk.
VFC_src0.v:9-10 uses it to construct the plain function contract.
These references establish proof inclusion, not concrete input reachability
of every disjunct admitted by the overapproximating invariant.

Reproduction and limitations
Run tmp/struct-field-search/decode_coturn.py and then
tmp/struct-field-search/extract_coturn_witness.py in the audit workspace.
The latter checks the published binary SHA256, relevant instruction word,
all recorded pure constraints, symbol bounds, slot consistency and range
inclusion. The decoded state is not an independently checked Rocq lemma.
The target binary was not executed. No harness input or exploit was built.

Proof links
'''
text += '\n'.join(f'{key}: {url}' for key,url in evidence['locations'].items())+'\n'
(outdir / 'field-bound-audit.txt').write_text(text)
print(json.dumps({'finding':'accepted internal disjunct includes buf[-1] = channel[3]',
                  'checks':'passed', 'report':str(outdir / 'field-bound-audit.txt'),
                  'full_evidence':str(outdir / 'field-bound-witness.json')},indent=2))

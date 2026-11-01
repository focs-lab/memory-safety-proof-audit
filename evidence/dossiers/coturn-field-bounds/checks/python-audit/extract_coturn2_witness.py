"""Audit the matching ASan and ASan+UBSan internal invariant cases.

Only certificate data, arithmetic and instruction bytes are inspected. This
does not execute coturn or establish harness-input reachability.
"""
import collections
import hashlib
import json
import struct
from pathlib import Path

BASE = Path('/Users/umang/Documents/ChatGPT/Verification gaps')
TMP = BASE / 'tmp/struct-field-search'
OUT = BASE / 'source-snapshots/coturn'
PIN = 'a6839bb9e433b34c0d0710df5280194528877139'
URL = f'https://github.com/theorem-labs/oss-verify-proofs/blob/{PIN}/proofs/coturn/FuzzStunClient/lib/'

def instruction(path, pc):
    raw = path.read_bytes()
    phoff = struct.unpack_from('<Q', raw, 32)[0]
    size, count = struct.unpack_from('<HH', raw, 54)
    for i in range(count):
        kind, flags, off, va, pa, fs, ms, al = struct.unpack_from('<IIQQQQQQ', raw, phoff+i*size)
        if kind == 1 and va <= pc < va+fs:
            return struct.unpack_from('<I', raw, off+pc-va)[0]
    raise ValueError(hex(pc))

cases = [
    dict(flavor='asan', name='ASan', vid=752, cut=0x8d348, post=0x8d3e8,
         buf=-1326956, store=0x8d38c, word=0x00aa8023, insn='sb x10, 0(x21)',
         bin='asan', sha='99443988bd9bcd3087fe619757c7dff2a6b198583ad959307bc34edcd9b44ef8',
         tp=0x5e65f0, ret=0x8e384, frame=0x146000),
    dict(flavor='both', name='ASan+UBSan', vid=845, cut=0x8c93c, post=0x8c9e8,
         buf=-1327020, store=0x8c97c, word=0x00ac8023, insn='sb x10, 0(x25)',
         bin='asan-ubsan', sha='4fd7bfa4d6ebf2583737cfa6cc09ce0f3344066b8f8c92d899ff91843d1d9f69',
         tp=0x5e4bb0, ret=0x8d6d4, frame=0x146000),
]

def read_unit(flavor, vid):
    path = TMP/f'{flavor}-unit-{vid}.json'
    if path.exists(): return json.loads(path.read_text())
    path = TMP/f'coturn-certificate-{flavor}.ndjson'
    for line in path.open():
        unit = json.loads(line)
        if unit['u1']['vid'] == vid: return unit
    raise ValueError((flavor, vid))

all_evidence = []
for cfg in cases:
    unit = read_unit(cfg['flavor'], cfg['vid'])
    cut = next(c for c in unit['cuts'] if c['pc'] == cfg['cut'])
    state = cut['states'][1]
    s = state['c1']
    nu = {i: 0 for i in range(1, s['next'])}
    for i, lo, hi in s['box']:
        nu[i] = lo if lo is not None else min(0, hi or 0)
    fs, sp, data = 0x200000000000, 0x7fff80000010, 0x400000
    nu.update({1:sp, 2:data, 3:1, 4:cfg['ret'], 17:cfg['tp'],
               64:sp//8, 65:data//8, 66:fs, 67:fs//8,
               22:fs+36864+1048576+32, 27:32, 28:13, 29:0})
    if cfg['flavor'] == 'asan':
        nu.update({24:fs+36864+1048576+64, 96:fs+36864,
                   97:(fs+36864)//8, 98:fs+4096})
    else:
        nu.update({97:fs+36864, 96:(fs+36864)//8, 98:fs+4096})
    ev = lambda e: e['const'] + sum(nu[i]*a for i,a in e['terms'])
    for q, e, m in state['divdef']:
        assert m > 0
        nu[q] = ev(e)//m
    assert all((lo is None or lo <= nu[i]) and (hi is None or nu[i] <= hi)
               for i,lo,hi in s['box'])
    assert all((nu[i]-r) % m == 0 for i,m,r in s['cong'])
    assert all(ev(c) <= 0 for c in s['cons'])
    assert all(nu[q] == ev(e)//m for q,e,m in state['divdef'])
    assert not any(s[k] for k in ('valset','conddef','moddef','globs'))
    assert ev(cut['ranks'][1]) >= 0

    # Check agreement between all explicitly recorded scalar/region cells.
    memory = {}
    def add_cell(address, width, e, shadow=False):
        assert width > 0
        if shadow and not e['terms']:
            bs = [ev(e) % 256] * width
        else:
            bs = (ev(e) % (1 << (8*width))).to_bytes(width, 'little')
        for j,b in enumerate(bs):
            assert address+j not in memory or memory[address+j] == b
            memory[address+j] = b
    for off,w,e in s['slots']:
        assert -cfg['frame'] <= off and off+w <= 0
        add_cell(sp+off,w,e)
    for region in state['regions']:
        base = nu[region['base']] + region['disp']
        assert 0 <= base+region['lo'] <= base+region['hi'] <= 2**64
        for off,w,e in region['cells']:
            assert region['lo'] <= off and off+w <= region['hi']
            add_cell(base+off,w,e,region['kind'][0] == 'shadow')
        if region['kind'][0] == 'flag': memory[base] = 1
    for lo,hi in s['nul']:
        assert any(memory.get(sp+i) == 0 for i in range(lo,hi+1))

    # The two ASan tests before the first store read these shadow bytes.
    pointer = sp + cfg['buf'] - 1
    shadow_offsets = [(cfg['buf']-1)//8, cfg['buf']//8]
    assert shadow_offsets[0] == shadow_offsets[1]
    for off in shadow_offsets:
        assert memory[0x7fff8000+sp//8+off] == 0
    assert -cfg['frame'] <= cfg['buf']-1 < 0
    assert any(lo <= cfg['buf']-1 and cfg['buf'] <= hi for lo,hi in unit['u1']['wstack'])
    assert pointer == (sp+cfg['buf']-4)+3  # channel[3]
    if cfg['flavor'] == 'asan':
        assert dict(s['regs'])[18] == {'const':-1,'terms':[]}
        assert ev(dict(s['regs'])[14]) == sp+cfg['buf']
    else:
        assert ev(dict(s['regs'])[22]) == sp+cfg['buf']
        assert ev(dict(s['regs'])[25]) == pointer

    post = next(c for c in unit['cuts'] if c['pc'] == cfg['post'])['states'][1]
    slot = next(x for x in post['c1']['slots'] if x[0] == cfg['buf']-1)
    assert slot[1:] == [1, {'const':4608,'terms':[]}]
    binary = TMP/f'binaries/FuzzStunClient/FuzzStunClient.{cfg["bin"]}'
    assert hashlib.sha256(binary.read_bytes()).hexdigest() == cfg['sha']
    assert instruction(binary,cfg['store']) == cfg['word']

    index = {int(k):v for k,v in json.loads((TMP/f'coturn-index-{cfg["flavor"]}.json').read_text()).items()}
    queue = collections.deque((u['vid'],[]) for u in index.values() if u['root'] is not None)
    seen = set()
    chain = None
    while queue:
        vid, path = queue.popleft()
        if vid in seen: continue
        seen.add(vid)
        if vid == cfg['vid']:
            chain = path
            break
        for pc,en,callee in index[vid]['calls']:
            queue.append((callee,path+[dict(caller=vid, call_pc=hex(pc), callee=callee, target=hex(en))]))
    assert chain
    evidence = dict(cfg, certificate_file=unit['certificate_file'], disjunct_index=1,
                    entry=hex(unit['u1']['entry']), full_decoded_cut_disjunct=state,
                    rank=cut['ranks'][1], valuation=nu, shadow_relative_offset=shadow_offsets[0],
                    unit_write_set=unit['u1']['wstack'], post_store_slot=slot,
                    certificate_reference_chain=chain,
                    certificate_url=URL+unit['certificate_file']+'#L5')
    all_evidence.append(evidence)

OUT.mkdir(exist_ok=True)
(OUT/'instrumented-field-bound-witnesses.json').write_text(json.dumps({
    'proof_commit':PIN, 'finding':'Neither instrumented internal invariant restores the buf field lower bound.',
    'cases':all_evidence,
    'scope':'Internal invariant strength only; no target execution, harness-input reachability or vulnerability conclusion; no independent Rocq replay.'
},indent=2)+'\n')

report = f'''Coturn ASan and ASan+UBSan internal field-bound audit
Proof commit: {PIN}

Finding
Neither internal proof restores the lower bound for the same source access
in stun_attr_add_str: attr_start=buf+clen; turn_write_u16(attr_start,attr).
Each selected accepted certificate case admits a store at buf[-1], inside
the preceding channel[3] field of stun_buffer. Both cases use attribute 18
(XOR-PEER-ADDRESS), which is within the plain-proof case reviewed earlier.

This is an invariant-strength finding. No assertion is made that any
harness input reaches either admitted disjunct. No target was executed.

'''
for e in all_evidence:
    report += f'''{e['name']}
Certificate: {e['certificate_file']}:5 (dictionary in VCertS_{e['flavor']}_p00.v:5).
Decoded selector: unit vid {e['vid']}, entry {e['entry']};
cut {hex(e['cut'])}, state index 1 (zero-based), ctx [].
buf = sp0 {e['buf']:+d}; struct base = buf-4.
The admitted store destination is sp0 {e['buf']-1:+d} = buf[-1] = channel[3].
Instruction at {hex(e['store'])}: {e['insn']}, word 0x{e['word']:08x}.
Post-store cut {hex(e['post'])}, state index 1, records:
  slot offset {e['buf']-1}, width 1, value 4608 mod 256.
The unit write set includes [{e['unit_write_set'][0][0]},{e['unit_write_set'][0][1]}).
The stack-shadow fact includes zero at offset {e['shadow_relative_offset']}
relative to sp0/8 + 0x7fff8000. Both byte addresses tested before the
first store map to that same zero shadow byte.
Certificate reference chain: {json.dumps(e['certificate_reference_chain'])}.
Binary SHA256: {e['sha']} (matches current build provenance).

'''
report += '''Tighter facts and instrumentation
ASan unit 752 at cut 0x8d348, case 1 fixes x18 (clen) to -1 and x14
to buf. Instructions 0x8d350-0x8d354 form buf-1. The ASan shadow tests
at 0x8d36c/0x8d370 and 0x8d380/0x8d384 accept the zero shadow byte;
the first source-data store is at 0x8d38c.

ASan+UBSan unit 845 at cut 0x8c93c, case 1 already fixes x25 to buf-1.
Thus this case is downstream of the pointer checks at 0x8c8b4-0x8c8d4.
For a positive buf, subtracting one produces a nonzero pointer without
address wraparound; those checks do not impose the C field lower bound.
The shadow tests at 0x8c958/0x8c95c and 0x8c96c/0x8c970 accept zero;
the first source-data store is at 0x8c97c.

All recorded intervals, congruences, linear constraints, division
definitions, nonnegative ranks, explicit scalar/region byte constraints
and NUL assertions were checked for consistency with the supplied
valuation. The complete cases and valuations are in the companion JSON.
The fake-stack frames/flags and borrowed argument regions concern helper
scratch storage and argument data; they introduce no C-field boundary at
the real-stack buf pointer. The corresponding real-stack shadow bytes
are explicitly zero in the certificate.

Proof machinery and exact source locations
VCertDecode2.v decodes the dictionaries, states and units. VCertT_asan.v:10
and VCertT_both.v:10 assemble the chunks. VGamma2.v:414-423 specifies the
complete extended invariant, including region and shadow facts.
VStepMem2.v:494-504 falls back to the ordinary stack-store checker for
these SP0-relative stores. VStepMem.v:52-68 checks the stack window and
per-unit write set. VDriver2.v:43-48 installs that write set.
VCertCheck_asan.v:12 and VCertCheck_both.v:12 state the certificate checks;
VFC_asan.v:13-20 and VFC_both.v:13-20 use them for the completed contracts.

Reproduction and limits
decode_coturn2.py translates the repository decoder and checks complete
consumption of the dictionary and every encoded chunk. This extraction
script checks arithmetic, byte consistency, binary hashes, store words,
shadow coverage and certificate references. It is not a Rocq replay or a
machine-checked theorem about concrete input reachability.
'''
(OUT/'instrumented-field-bound-audit.txt').write_text(report)
print(json.dumps({'result':'Neither restores the field lower bound',
                  'cases':[{k:e[k] for k in ('name','vid','entry','cut','store','post','buf')} for e in all_evidence],
                  'report':str(OUT/'instrumented-field-bound-audit.txt')},indent=2))

"""Rebuild the audit in the release-pinned, network-disabled checker image."""
import hashlib
import json
import re
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
PROOF_COMMIT = 'a6839bb9e433b34c0d0710df5280194528877139'
CHECKER = 'ghcr.io/theorem-labs/oss-fuzz-theorems-checker@sha256:cc9ae43a9f4b0dd59d7c8d30727d36e039bfe72a2a9f9c4a99c68e413037e902'
BINARIES = {
    'FuzzStunClient.asan': '99443988bd9bcd3087fe619757c7dff2a6b198583ad959307bc34edcd9b44ef8',
    'FuzzStunClient.asan-ubsan': '4fd7bfa4d6ebf2583737cfa6cc09ce0f3344066b8f8c92d899ff91843d1d9f69',
}
PROOFS = ['WitnessData', 'Certificate', 'Rank', 'Support', 'Model', 'Pure',
          'Regions', 'Ambient', 'Structural', 'Flags', 'Complete']

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def run(args):
    subprocess.run(args, cwd=HERE, check=True)

start = time.time()
version = subprocess.check_output(['rocq', '--version'], text=True).strip()
print(version, flush=True)
assert 'version 9.2' in version, version
manifest = json.loads((HERE/'vendor-manifest.json').read_text())
assert manifest['commit'] == PROOF_COMMIT
for entry in manifest['files']:
    relative = entry['path'].split('/lib/', 1)[1]
    assert digest(HERE/'vendor'/relative) == entry['sha256'], relative
for name, expected in BINARIES.items():
    assert digest(HERE/'input'/name) == expected, name
for name in PROOFS:
    source = (HERE/'proof'/f'{name}.v').read_text()
    assert not re.search(r'(?m)^\s*(?:Axiom|Axioms|Parameter|Parameters|Admitted)\b', source), name
    assert not re.search(r'\b(?:admit|vm_cast_no_check|native_cast_no_check)\b', source), name

# Static image generation only: neither target binary is executed.
for binary, prefix in [('FuzzStunClient.asan', 'Asan'),
                       ('FuzzStunClient.asan-ubsan', 'AsanUbsan')]:
    run(['elf-snapshot', f'input/{binary}', f'images/{prefix}.v',
         '--prefix', prefix, '--namespace',
         'OssFuzzTheorems.coturn.FuzzStunClient.images', '--module-name', 'M'])

sources = ['images/Asan.v', 'images/AsanUbsan.v']
sources += json.loads((HERE/'vendor-order.json').read_text())
sources += [f'proof/{name}.v' for name in PROOFS]
# Explicit paths force every source to compile, including every dependency.
process = subprocess.Popen([sys.executable, 'compile.py', *sources], cwd=HERE,
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
lines = []
for line in process.stdout:
    print(line, end='', flush=True)
    lines.append(line)
assert process.wait() == 0, 'Rocq compilation failed'
output = ''.join(lines)
final_output = output[output.rindex('CHECK proof/Complete.v'):]
assert final_output.count('Axioms:') == 2, 'Missing final assumptions reports'
assumptions = sorted(set(re.findall(r'(?m)^([A-Za-z_][\w]*(?:\.[\w]+)+)\s*:', final_output)))
prefixes = {'PrimString.': 'Corelib.Strings.PrimString.',
            'PrimInt63.': 'Corelib.Numbers.Cyclic.Int63.PrimInt63.',
            'PrimArray.': 'Corelib.Array.PrimArray.'}
canonical = []
for name in assumptions:
    for short, full in prefixes.items():
        if name.startswith(short):
            name = full + name[len(short):]
            break
    canonical.append(name)
allowed = set((HERE/'input/upstream-allowed-axioms.txt').read_text().splitlines())
assert set(canonical) <= allowed, sorted(set(canonical)-allowed)
(HERE/'assumptions.txt').write_text(final_output)
result = {
    'status': 'PASS', 'proof_commit': PROOF_COMMIT, 'checker_image': CHECKER,
    'rocq_version': version, 'binary_sha256': BINARIES,
    'checked_sources': len(sources), 'elapsed_seconds': round(time.time()-start, 2),
    'finished_utc': datetime.now(timezone.utc).isoformat(),
    'theorems': ['CoturnFieldAudit.Complete.asan_decoded_case_admits_buf_minus_one',
                 'CoturnFieldAudit.Complete.both_decoded_case_admits_buf_minus_one'],
    'audit_source_sha256': {name: digest(HERE/'proof'/f'{name}.v') for name in PROOFS},
    'assumptions': canonical, 'all_assumptions_in_upstream_allowlist': True,
    'scope': 'Complete original gamma2 invariant witnesses; no input reachability or vulnerability claim.',
}
(HERE/'result.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result, indent=2), flush=True)

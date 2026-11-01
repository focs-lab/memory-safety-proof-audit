"""Run inside the release-pinned checker, with networking disabled."""
import json
import subprocess
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
PREFIX = 'OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib'
flags = ['-native-compiler', 'no', '-Q', 'proof', 'CoturnFieldAudit',
         '-Q', 'vendor', PREFIX, '-Q', 'images',
         'OssFuzzTheorems.coturn.FuzzStunClient.images']
paths = sys.argv[1:] or ([str(p.relative_to(HERE)) for p in sorted((HERE/'images').glob('*_*.v'))]
    + ['images/Asan.v', 'images/AsanUbsan.v']
    + json.loads((HERE / 'vendor-order.json').read_text()))
for path in paths:
    p = HERE / path
    if not sys.argv[1:] and p.with_suffix('.vo').exists() and p.with_suffix('.vo').stat().st_mtime >= p.stat().st_mtime:
        continue
    start = time.time()
    print('CHECK', path, flush=True)
    subprocess.run(['rocq', 'compile', *flags, path], cwd=HERE, check=True)
    print('PASS', path, f'{time.time()-start:.1f}s', flush=True)

OpenSSL lifetime-contract audit: independent Rocq replay

Read VERDICT.txt for the outcome and REPORT.txt for scope, provenance,
assumptions, and reproduction commands. IndependentWitness.v is a convenient
copy of the concrete checked construction.

The complete source-and-log artifact is openssl-independent-replay-2026-11-01.tar.gz.
Verify it with: shasum -a 256 -c bundle.sha256
Extract it in a working directory, then follow its README.txt.
The artifact includes unchanged pinned upstream sources, source verification,
a fresh-build script, checked constructions, and the original build logs.
Compiled products are excluded.

The completed replay checks the local lifetime gap and abstract model.
It does not replay the full binary agreement certificates or establish an
invalid access in the published bndiv client.

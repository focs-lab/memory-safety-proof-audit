# Preserved proof repository for the allocator review

The [proof archive release](https://github.com/focs-lab/memory-safety-proof-audit/releases/tag/proof-archive-98e995d4)
preserves `theorem-labs/oss-verify-proofs` at commit
`98e995d4daced70a0a4aa2c810854b88720735f1`, dated 23 October 2026.
It contains all **145,602 tracked files**, including the four proof files
linked from the archived survey table (formerly Table 2). Their paths and
hashes are retained in [the evidence mapping](table-2-evidence.tsv).
The survey is not part of the current paper. Later upstream edits do not
change this snapshot.

The release contains two archives, split into 1 GiB parts for hosting:

| Archive | Compressed bytes | Contents |
| --- | ---: | --- |
| Source snapshot | 2,868,399,164 | Complete tracked tree, with paths, file modes, symlinks, licences, and notices preserved |
| Git snapshot | 2,188,248,432 | Self-contained bare Git repository for the exact commit; earlier history is omitted |

The source and Git copies preserve the same tree. A metadata package contains
the per-file manifest, original checksums, commit metadata, restoration
instructions, and a Python verifier. The archive files are attached to this
repository's release; they are not stored as large blobs in the audit's Git history.

## Download and verify

Use the [release page](https://github.com/focs-lab/memory-safety-proof-audit/releases/tag/proof-archive-98e995d4),
or the GitHub CLI while authenticated with access to this repository:

```sh
gh release download proof-archive-98e995d4 \
  --repo focs-lab/memory-safety-proof-audit \
  --dir preserved-proof-archive
cd preserved-proof-archive
shasum -a 256 -c ASSET-CHECKSUMS.sha256

cat source-98e995d4.tar.gz.part* > oss-verify-proofs-98e995d4daced70a0a4aa2c810854b88720735f1.tar.gz
cat git-98e995d4.tar.gz.part* > oss-verify-proofs-98e995d4.git.tar.gz
tar -xzf proof-archive-98e995d4-metadata.tar.gz

shasum -a 256 -c CHECKSUMS.sha256
python3 verify_archive.py
```

Run these commands in a fresh download directory. The parts have numbered
suffixes, so the shell concatenates them in the required order. After the
reconstructed archives pass verification, the `.part*` files may be removed
to recover disk space. The complete download is about 5.1 GB; allow additional
space for reassembly and extraction.

The verifier uses only Python's standard library. It checks every archived
file against both its SHA-256 digest and Git blob hash, reconstructs the root
tree, and verifies the original commit object. The expected Git tree is
`b5159cfa8466a731305873c56fda351a275db401`.

The extracted `README.txt` gives source extraction and offline Git restoration
commands. It records the original local preservation operation; this release
distributes those same verified archive and metadata bytes.

## Evidence and checks

- [Archived survey table's file paths, hashes, and upstream permalinks](table-2-evidence.tsv).
- [Preservation provenance and scope](provenance.json).
- [GitHub commit metadata](github-commit.json) and the [original commit object](commit-object.txt).
- [Completed source-integrity and offline-restoration checks](verification.txt).
- [Release asset names, sizes, and hashes](release-assets.json) and
  [part checksums](ASSET-CHECKSUMS.sha256).

The preservation checks passed for all 145,602 files. Both the downloaded
Git repository and a separately restored copy passed `git fsck --full --strict`.
An offline local clone resolved to the expected commit and tree.

This is a complete tracked snapshot, not a complete offline build environment.
It excludes earlier Git history, GitHub issues and Actions logs, separately
hosted release assets, and external dependencies. There are no Git submodule
entries or Git LFS pointer files in this snapshot. These checks establish
the identity and completeness of the preserved evidence; they do not replay
the Rocq proof corpus.

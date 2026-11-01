COTURN FIELD-BOUND AUDIT

Read output/pdf/coturn-field-bound-findings.pdf for the complete dossier.
The second PDF, output/pdf/coturn-field-layout.pdf, is a vector diagram.

Audit inputs:
  report-data.json              Report text, literal code, and formal statements.
  code/                        C excerpts with original licence headers.
  reproduction/proof/Complete.v Exact final Rocq statements and proofs.

The retained PDF describes the original investigation. Manuscript snippets,
TeX sources, and PDF-generation tools are omitted from this audit package.
The proof sources, binary inputs, and recorded results are unchanged.

All source pins, excerpt ranges and original build metadata: PROVENANCE.json.
Original coturn sources, with copyright/licence headers: upstream/coturn/.
Full original build licences/records: reproduction/upstream-provenance/.

Rocq reproduction:
  cd reproduction
  ./run.sh > check.log 2>&1
Requires Docker and the release-pinned checker image already available locally.
The script disables container networking and executes no coturn binary.
The 75 vendored coturn dependencies, 11 audit sources and two generated image
modules are recompiled; Rocq/LPS are supplied by the pinned checker image; expected PASS is
88 sources with only upstream-allowed Rocq primitive assumptions.
The earlier full build record is in evidence/original-rocq-result.json and
evidence/original-rocq-check.log. Reproduction writes its own result and log.

Evidence strength:
  ASan and ASan+UBSan: complete original gamma2 witnesses checked in Rocq.
  Plain: matching case with Python/source/binary checks; no new full-gamma Rocq replay.
  bzip2: no omitted core-array bound identified in manual review; not a universal
         source-subobject safety theorem.
  No input reachability, attacker control, behavioral corruption or vulnerability
  is established. The dossier records the signed-residue decoder correction.

Integrity: run `shasum -a 256 -c MANIFEST.sha256` from this directory after
extracting the source package. Generated reproduction intermediates are ignored.

Packaging validation: both countermodels passed again from this standalone copy
on 1 November 2026 at 05:22:57 UTC, recompiling all 88 sources in 165.97 seconds.
See reproduction/result.json, check.log and assumptions.txt.

Source integrity check (standard Python):
  python3 checks/verify_materials.py
The checker compares the two formal statements in report-data.json with
Complete.v, and verifies the source excerpts and recorded result identities.

Final document and package validation: VALIDATION.json.
Current upstream HEAD checks: UPSTREAM-STATUS.json.

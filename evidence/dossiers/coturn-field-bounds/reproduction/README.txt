Coturn field-bound invariant audit in Rocq

Proof repository: https://github.com/theorem-labs/oss-verify-proofs
Commit: a6839bb9e433b34c0d0710df5280194528877139
Current remote HEAD rechecked during this audit, 2026-11-01.

Main file: proof/Complete.v
  asan_decoded_case_admits_buf_minus_one
  both_decoded_case_admits_buf_minus_one

"both" is the repository's name for the ASan+UBSan build.

Cases (zero-based disjunct index 1, inline context []):
  ASan:       unit 752, cut 0x8d348, buf = sp0 - 1326956.
  ASan+UBSan: unit 845, cut 0x8c93c, buf = sp0 - 1327020.

The existence theorems select the unit from the original compressed
certificate using the repository's original decoder. They check the entire
selected cstate2 and its associated rank, then provide a valuation, registers
and concrete memory satisfying the COMPLETE original gamma2 predicate.
The parameters are the original unit_params2/genv parameters and the image
segments come from the SHA-pinned published binaries.

Each witness has destination = buf-1, destination < buf, writable memory at
that address, and a zero ASan shadow byte. For ASan the destination is the
machine-word addition x14+x18 (buf+clen); for ASan+UBSan it is x25, already
formed at the selected cut. With the source/binary layout audited earlier,
buf-1 is channel[3] of the surrounding stun_buffer.

This is an invariant-strength countermodel. It does not establish a path
from a harness input, execute either coturn binary, or claim a vulnerability.

Reproduction:
  ./run.sh > check.log 2>&1

This uses the release-pinned Rocq 9.2 checker, disables its network, checks
the original library and binary hashes, regenerates the two static images,
and recompiles all 75 vendored coturn dependencies, 11 audit sources and two
generated image modules. Rocq/LPS libraries are supplied by the pinned checker image. Docker must be running and
the pinned image must already be available locally. On an ARM Mac it runs
the release's amd64 image through Docker's emulation.

result.json and check.log are the final build record (PASS: 88 sources). Print Assumptions is
included for the two final existence theorems. The new proofs introduce no
axioms, admitted lemmas or unchecked casts.

File guide:
  vendor/ and vendor-manifest.json: unmodified pinned upstream dependencies,
    with their original licence headers and SHA-256 records.
  proof/Certificate.v and proof/Rank.v: equality with original decoded data.
  proof/WitnessData.v: generated case and valuation literals.
  proof/Model.v: explicit memory/register/environment construction. The
    gamma_params_exact lemma proves that omitting unused static-table fields
    during computation preserves the entire gamma2 predicate; Complete.v
    restores the original parameters in its theorem statements.
  proof/Pure.v: intervals, congruences, fixed symbols, division definitions.
  proof/Regions.v: all region kinds, cells, permissions and ownership.
  proof/Ambient.v: environment, runtime context, pristine and shadow memory.
  proof/Structural.v: registers, stack slots, NUL facts, structural conditions.
  proof/Flags.v: the complete fake-stack flag invariant.
  proof/Complete.v: full gamma2 witnesses and final existence statements.

Decoder correction:
  The earlier Python decoder used an unsigned parser for congruence residues.
  Rocq exposed the error: the instrumented cases require sp0 = 16 mod 32.
  The checked witnesses use sp0 = 0x7fff80000010. The decoder and earlier
  extracted evidence were corrected. This changes the witness, not the
  field-bound conclusion. The plain-case residue and witness were corrected
  as well; the new Rocq theorems here concern the two instrumented cases.

Original proof locations (relative to the pinned proof repository):
  proofs/coturn/FuzzStunClient/lib/VCertS_asan_p01.v:5 (dictionary p00).
  proofs/coturn/FuzzStunClient/lib/VCertS_both_p01.v:5 (dictionary p00).
  proofs/coturn/FuzzStunClient/lib/VGamma2.v:414-423 (full predicate).
  proofs/coturn/FuzzStunClient/lib/VDriver2.v:43-48 (unit parameters).

The copied upstream assumptions allowlist has SHA-256:
  8820b8fc82c03184f5822c52932531be058ca95d352195a68c530004616d5380

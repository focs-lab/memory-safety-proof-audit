# Validation record

Checked on 1 November 2026. Commands and expected outputs are in
[REPRODUCE.md](REPRODUCE.md). The [claim index](evidence/README.md) states
what each result supports.

## Fresh clone

Before this audit repository was populated, this check started with a new
clone of the preliminary release from GitHub at
`f9368ed86dda3a9bd8f6fe4574d8614c802174ba`. Replays used fresh directories
under `build/`. They did not reuse compiled proof objects from the release.
The supplied proof sources, binaries, and retained logs stayed unchanged.

The host ran arm64 macOS 27.0.1, Python 3.14.6, and Git 2.41.0.
OpenSSL used the installed Rocq 9.0.0 and OCaml 5.3.0 tools.
Docker Engine 28.4.0 ran in Docker Desktop with eight CPUs and about
7.65 GiB of memory.
The Docker checks used Linux amd64 emulation and the pinned image digests.
Image pulls checked the registry; the images were already cached locally.
This tests a fresh source clone with installed tools. It does not test
installing those tools on a new operating system.

| Check | Outcome | Scope |
| --- | --- | --- |
| Package validator | Passed | Local documentation links, citation order, PDF header, and release-file digests. Rechecked after the guide corrections. |
| Coturn material checker | Passed | Five C excerpts, 75 vendor sources, 11 audit sources, two Rocq statements, binary hashes, and retained result records. Also checked the 115-field bzip2 inventory. |
| OpenSSL replay | Passed | Bundle checksums and source provenance passed. All 28 upstream and four audit modules compiled. All 23 assumption queries were closed. `coqchk` returned zero. |
| Coturn proof replay | Passed | All 88 sources compiled. Both final countermodel theorems passed, with 21 allowed assumptions. All result fields except timestamp and duration match the retained result. |
| Interpreter proof replay | Incomplete | Dependency setup, metadata validation, binary hashes, and statement compilation passed. The eight-job run exhausted Docker memory. The two-job retry was stopped at the author's request. The fresh-clone proof replay did not complete. |
| Retained interpreter traces | Passed | Checksums passed. The offline checker reproduced all four retained cases. |
| Fresh interpreter execution | Passed | All eight logging invocations returned zero. Both triggering cases selected `h_admin`; both benign controls selected `h_nop`. The independent trace-checker call passed. |
| Source-inspection checkout | Passed | The documented Git recipe fetched the exact revision. All 14 retained pupnp, msgpack-c, and simdjson excerpts match upstream. The named definitions, simdjson harness histories, and bzip2 proof coverage match the claim index. All 33 bzip2 checklist entries and the offset program passed. The full archive confirms the 2,142-file count; the sparse checkout gives 53. |
| Preserved source archive | Passed | Downloaded all release assets. Split-part and reconstructed-archive checksums passed. All 145,602 files match their SHA-256 and Git blob hashes. The verifier recovered commit `98e995d4` and tree `b5159cfa8466a731305873c56fda351a275db401`. |
| Guide commands | Syntax passed | All 11 shell blocks parse. The dependency helper was tested from an empty directory. The two-job proof command has not completed a full replay. |
| Paper preservation | Passed | The fresh-clone checks left the paper unchanged. This audit repository copies the PDF unchanged and omits manuscript sources. No paper build was run for these audit checks. |

The OpenSSL run's 34 commands all returned zero. Their durations sum to
about 95 seconds. The coturn replay took about 189 seconds.
These times exclude downloads. They are observations from this host,
not resource bounds.

The first interpreter attempt exposed missing Python dependencies in the
checker image. The next attempt exposed the checker's need for all project
metadata. The eight-job run then exhausted Docker memory and one compilation
was killed. The guide now limits the checker to two jobs. That retry was
stopped after about 34 seconds at the author's request. It did not produce
a final proof verdict. The earlier retained checker result remains the
evidence for acceptance of the interpreter proof.
The bzip2 checklist also distinguishes its whole-tree count from the count
in the guide's sparse checkout. The guide now states repository access
and host-tool prerequisites.

These checks preserve the original evidence's scope. The OpenSSL replay
checks the local model and contracts. It does not replay the full binary
agreement certificates. The source-inspection route does not replay the
upstream proof corpus. Interpreter execution uses the supplied binaries;
it does not rebuild them from C.

## Current paper synchronization

The following record describes the earlier paper preparation. This audit
repository distributes the resulting PDF; it omits the TeX sources and
build inputs. The PDF bytes are unchanged.

The paper follows verification-gaps source commit `f2b5786b15cea95babf51729a196fccc7ae180f5`.
All 19 active build inputs match the source. Both PDFs were rebuilt with
one source timestamp and are byte-for-byte identical, with nine pages.
The updated pages 3, 6, 7, and 9 were rendered and visually checked.
The builds have no overfull boxes, undefined references, or font warnings.
This editorial update did not repeat the proof or execution checks.

## Retained evidence

| Result | Record | What it establishes |
| --- | --- | --- |
| Interpreter agreement | [Cold checker log](evidence/dossiers/checked-example/replay/logs/example-check-cold.log), [assumptions](evidence/dossiers/checked-example/replay/logs/assum-55.full), [provenance](evidence/dossiers/checked-example/provenance.json) | Two successful checker steps; 15 allowed assumptions; the exact source and binary identities. |
| Interpreter execution | [Result](evidence/dossiers/checked-example/execution/retained/result.json), [environment](evidence/dossiers/checked-example/execution/retained/environment.json), [commands and return codes](evidence/dossiers/checked-example/execution/retained/runs.json), [raw traces](evidence/dossiers/checked-example/execution/README.md) | The triggering input overwrites `op` with `0xff` and selects `h_admin` in both binaries. Benign controls select `h_nop`. All runs return zero; the ASan runs emit no sanitizer report. |
| OpenSSL local contracts | [Bundle and instructions](evidence/dossiers/openssl-lifetime/README.txt), [scope report](evidence/dossiers/openssl-lifetime/REPORT.txt) | The constructed model client satisfies the operation preconditions after temporary expiry. The archive includes source verification, proof logs, and assumption reports. |
| Coturn countermodels | [Result](evidence/dossiers/coturn-field-bounds/reproduction/result.json), [assumptions](evidence/dossiers/coturn-field-bounds/reproduction/assumptions.txt), [checker log](evidence/dossiers/coturn-field-bounds/reproduction/check.log) | 88 compiled sources under the pinned Rocq 9.2 image. Both final witnesses satisfy the complete selected invariants. Assumptions are within the upstream allowlist. |
| Proof archive | [Verification record](evidence/source-snapshots/oss-verify-proofs/98e995d4/verification.txt), [provenance](evidence/source-snapshots/oss-verify-proofs/98e995d4/provenance.json) | All 145,602 tracked files match their Git blob and SHA-256 hashes. The restored tree is `b5159cfa8466a731305873c56fda351a275db401`. This is source preservation, not a corpus replay. |
| Paper provenance | [Release provenance](release-provenance.json) | The current manuscript source revision, build-input hashes, and PDF digest. |

`MANIFEST.sha256` covers release files. It excludes Git metadata, generated
`build/` output, and itself. Large proof archives have separate release-asset
checksums. The [claim index](evidence/README.md) explains which conclusion
each retained result supports.

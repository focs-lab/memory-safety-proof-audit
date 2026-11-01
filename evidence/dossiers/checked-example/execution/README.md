# Retained interpreter execution traces

On 1 November 2026, the supplied `core.plain` and `core.asan` binaries were
executed with the supplied exploit and benign inputs. The exploit writes
`0xff` at offset 20 from the allocation base, then loads that byte as `op`
and calls `h_admin`. The benign input copies five bytes and calls `h_nop`.
All four executions print `0`, exit successfully, and emit no diagnostics.
Both handlers are empty.

The [result](retained/result.json) records every copied byte and the raw
trace lines supporting the final load and indirect call. The instruction
and register logs are retained without editing:

| Binary | Input | Copy instruction | Final `op` | Handler reached | Raw trace |
| --- | --- | --- | --- | --- | --- |
| plain | exploit | `0x12ad4: sb a2,0(a1)` | `0xff` | `0x12b34` (`h_admin`) | [trace](retained/plain-exploit-instructions.trace) |
| ASan | exploit | `0x7e6c4: sb a6,0(a5)` | `0xff` | `0x7e784` (`h_admin`) | [trace](retained/asan-exploit-instructions.trace) |
| plain | benign | `0x12ad4: sb a2,0(a1)` | `0` | `0x12b30` (`h_nop`) | [trace](retained/plain-benign-instructions.trace) |
| ASan | benign | `0x7e6c4: sb a6,0(a5)` | `0` | `0x7e780` (`h_nop`) | [trace](retained/asan-benign-instructions.trace) |

In the retained exploit runs, the plain allocation starts at `0x7ffffd933060`
and the final store targets `0x7ffffd933074`; the ASan allocation starts at
`0x7fe1efff0050` and the final store targets `0x7fe1efff0064`. Both destinations
are base + 20. At the ASan branch immediately before that store, the shadow
byte is 5 and the address's offset within its eight-byte granule is 4.
The branch therefore permits the write inside the 21-byte allocation.

## Reproduce

Requires Docker and the pinned Linux amd64 runner image. An ARM host also
needs Docker's amd64 emulation. From the repository root:

```sh
audit_runner=ghcr.io/theorem-labs/oss-fuzz-theorems-runner@sha256:d197498c0e20de006e61fbe7c3d70ebdd81ad3928468ac45d643b72c716e7af2
docker pull --platform linux/amd64 "$audit_runner"
sh evidence/dossiers/checked-example/execution/run.sh build/interpreter-execution
```

Use an empty output directory. The runner disables networking, mounts the
artifact read-only, and limits the container to 2 GiB and two CPUs. It
executes the binaries named by the theorem, with an empty guest environment.
Each case is run once with instruction/register logging and once with syscall
logging. These are separate executions. The container limit is a resource
setting, not a check of the theorem's memory-budget premise.

The command must finish with `PASS`. It saves all raw output, command lines,
exit codes, input and binary hashes, the QEMU version and executable hash,
and script hashes. See the retained [environment](retained/environment.json),
[commands and return codes](retained/runs.json), and
[checksums](retained/SHA256SUMS). Addresses, process IDs, timings, and trace
translation-block identifiers may differ on another run.

To check the retained instruction logs without Docker:

```sh
python3 -B evidence/dossiers/checked-example/execution/check_trace.py
```

The checker compares the logged instructions with the proved ELF files,
decodes each copy store, checks its effective address and byte value, and
follows the `op` load, table lookup, indirect call, and handler return.
It also checks that the relevant functions and handler-table bytes match
the debug files supplying the symbol names. The debug binaries are not run.

This execution replay checks four concrete cases. The existing agreement
proof and checker logs are preserved unchanged in the [parent dossier](../README.md).

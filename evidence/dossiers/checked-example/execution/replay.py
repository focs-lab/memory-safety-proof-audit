#!/usr/bin/env python3
"""Rerun the four concrete interpreter executions in the pinned runner image."""

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import platform
import subprocess
import time

from check_trace import CONFIG, check_all, sha256

RUNNER_IMAGE = "ghcr.io/theorem-labs/oss-fuzz-theorems-runner@sha256:d197498c0e20de006e61fbe7c3d70ebdd81ad3928468ac45d643b72c716e7af2"
QEMU_SHA256 = "44076c56382fea0cca26fb4ec1ab688fcc59573d87de1094d664f37915ac8d72"
PINS = {
    "out/core.plain": "57c21dc430543c1883e143679e10ca9f36b90b8acbf49d94cc7d35996acf34bd",
    "out/core.asan": "fb95471b3be5bc2b2934941cb35cb288de7ed9e241aa5e61aa2a770fc0aa84fd",
    "out/core.plain.dbg": "d2ef908842d374220b433c9cbd16ebd651838ea9c99dbdda99362c6320349588",
    "out/core.asan.dbg": "de9e71b6672abc73949e8afd8a80e5144b02cc38e9ae3b23f39b6d55617689b9",
    "inputs/core-exploit.bin": "2ecba9458c978262efdfc8addb2162f474f42bd93a1f782ec5aaf67f8372e5b4",
    "inputs/core-benign.bin": "0ef511c64f6e5a9ad75bdf43fbb73d5c4c1579b95795c2233869c59bfcaa1dfe",
}


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--artifact", type=Path, default=Path("/artifact"))
    parser.add_argument("--output", type=Path, default=Path("/output"))
    args = parser.parse_args()
    artifact, out = args.artifact, args.output
    out.mkdir(parents=True, exist_ok=True)
    assert not list(out.iterdir()), "use an empty output directory"
    qemu = Path("/usr/bin/qemu-riscv64")
    assert sha256(qemu) == QEMU_SHA256, "wrong QEMU executable"
    pins = {name: sha256(artifact / "replay/example" / name) for name in PINS}
    assert pins == PINS, "binary or input pin mismatch"
    harness = (artifact / "proof/projects/example/core/harness.yaml").read_text()
    assert all(PINS[f"out/core.{build}"] in harness for build in CONFIG)
    write_json(out / "environment.json", dict(
        started_at=datetime.now(timezone.utc).isoformat(), runner_image=RUNNER_IMAGE,
        qemu_sha256=sha256(qemu),
        qemu_version=subprocess.check_output([str(qemu), "--version"], text=True).strip(),
        container_platform=platform.platform(), python_version=platform.python_version(),
        guest_environment={}, pins=pins,
        script_sha256={p.name: sha256(p) for p in Path(__file__).parent.iterdir()
                       if p.suffix in (".py", ".sh")}))
    runs = []
    for build, cfg in CONFIG.items():
        binary = artifact / "replay/example/out" / f"core.{build}"
        for case in ("benign", "exploit"):
            input_path = artifact / "replay/example/inputs" / f"core-{case}.bin"
            for mode in ("syscalls", "instructions"):
                stem = f"{build}-{case}-{mode}"
                options = ["-strace"] if mode == "syscalls" else [
                    "-one-insn-per-tb", "-d", "in_asm,exec,cpu,nochain", "-dfilter",
                    f'{cfg["entry"]:#x}..{cfg["admin"] + 3:#x}',
                    "-D", str(out / (stem + ".trace"))]
                argv = [str(qemu), *options, str(binary), str(input_path)]
                started = time.monotonic()
                run = subprocess.run(argv, env={}, capture_output=True, timeout=60)
                (out / (stem + ".stdout")).write_bytes(run.stdout)
                (out / (stem + ".stderr")).write_bytes(run.stderr)
                record = dict(build=build, case=case, mode=mode, argv=argv,
                    returncode=run.returncode, elapsed_seconds=round(time.monotonic() - started, 6),
                    binary_sha256=sha256(binary), input_sha256=sha256(input_path),
                    output_sha256={p.name: sha256(p) for p in sorted(out.glob(stem + ".*"))})
                runs.append(record)
                write_json(out / "runs.json", runs)
                print(f"{stem}: exit {run.returncode}", flush=True)
    result = check_all(artifact, out)
    write_json(out / "result.json", result)
    (out / "SHA256SUMS").write_text("".join(
        f"{sha256(p)}  {p.name}\n" for p in sorted(out.iterdir()) if p.is_file()))
    print("PASS: exact binary pins, 21-byte overwrite, both handler targets, and benign controls")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Prepare the pinned checker's Python packages without changing host Python."""

import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import zipfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("requirements", type=Path)
    parser.add_argument("destination", type=Path)
    args = parser.parse_args()
    if not args.requirements.is_file():
        parser.error("requirements file does not exist")
    if args.destination.exists():
        parser.error("destination must not exist; use a fresh directory")

    # The pinned checker uses CPython 3.12 on Linux x86-64. Select its
    # wheels explicitly, including when the host is macOS or ARM.
    wheels = args.destination / "wheels"
    wheels.mkdir(parents=True)
    subprocess.run([
        sys.executable, "-m", "pip", "download", "--require-hashes",
        "--only-binary=:all:", "--platform", "manylinux2014_x86_64",
        "--python-version", "3.12", "--implementation", "cp", "--abi", "cp312",
        "-r", str(args.requirements), "--dest", str(wheels),
    ], check=True)

    records = []
    for wheel in sorted(wheels.glob("*.whl")):
        with zipfile.ZipFile(wheel) as archive:
            archive.extractall(args.destination)
        records.append({"file": wheel.name,
                        "sha256": hashlib.sha256(wheel.read_bytes()).hexdigest()})
    (args.destination / "wheel-hashes.json").write_text(
        json.dumps(records, indent=2) + "\n", encoding="utf-8")
    print("Prepared checker packages in " + str(args.destination))


if __name__ == "__main__":
    main()

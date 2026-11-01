#!/usr/bin/env python3
"""Check retained QEMU instruction/register logs against the pinned ELF files."""

import hashlib
import json
from pathlib import Path
import re
import struct


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


class ELF:
    def __init__(self, path):
        self.data = path.read_bytes()
        assert self.data[:6] == b"\x7fELF\x02\x01", "expected ELF64 little endian"
        h = struct.unpack_from("<HHIQQQIHHHHHH", self.data, 16)
        assert h[1] == 243, "expected RISC-V"
        self.segments = [struct.unpack_from("<IIQQQQQQ", self.data, h[4] + i * h[8])
                         for i in range(h[9])]
        self.sections = [struct.unpack_from("<IIQQQQIIQQ", self.data, h[5] + i * h[10])
                         for i in range(h[11])]

    def at(self, address, size):
        for kind, _, offset, va, _, file_size, _, _ in self.segments:
            if kind == 1 and va <= address and address + size <= va + file_size:
                return self.data[offset + address - va:offset + address - va + size]
        raise AssertionError(f"address not backed by ELF file: {address:#x}+{size}")

    def symbol(self, name):
        matches = []
        for section in self.sections:
            if section[1] != 2:  # SHT_SYMTAB
                continue
            strings = self.sections[section[6]]
            names = self.data[strings[4]:strings[4] + strings[5]]
            for offset in range(section[4], section[4] + section[5], section[9]):
                n, _, _, _, address, size = struct.unpack_from("<IBBHQQ", self.data, offset)
                if names[n:].split(b"\0", 1)[0].decode() == name:
                    matches.append((address, size))
        assert len(matches) == 1, (name, matches)
        return matches[0]


CONFIG = {
    "plain": dict(entry=0x12a80, allocation=0x12aa8, allocated=0x12aac,
                  initialize=0x12ab4, copy=0x12ad4, op_load=0x12ae4,
                  table_load=0x12b00, call=0x12b04, nop=0x12b30,
                  admin=0x12b34, table=0x1bda8),
    "asan": dict(entry=0x7e62c, allocation=0x7e65c, allocated=0x7e660,
                 initialize=0x7e680, copy=0x7e6c4, op_load=0x7e708,
                 table_load=0x7e72c, call=0x7e730, nop=0x7e780,
                 admin=0x7e784, table=0x955a0),
}


def parse_trace(path, elf):
    records = []
    disassembly = {}
    for line_number, line in enumerate(path.read_text().splitlines(), 1):
        instruction = re.match(r"0x([0-9a-f]+):\s+([0-9a-f]{8})\s+(.+)", line)
        if instruction:
            pc, word = (int(instruction[i], 16) for i in (1, 2))
            assert elf.at(pc, 4) == struct.pack("<I", word), "trace/ELF instruction mismatch"
            disassembly[pc] = instruction[3].strip()
        pc = re.match(r" pc\s+([0-9a-f]+)$", line)
        if pc:
            records.append(dict(pc=int(pc[1], 16), line=line_number, registers={}))
        elif line.startswith(" x"):
            records[-1]["registers"].update({int(n): int(value, 16) for n, value in
                re.findall(r"x(\d+)/\w+\s+([0-9a-f]{16})", line)})
    assert records
    assert all(len(r["registers"]) == 32 and r["pc"] in disassembly for r in records)
    return records, disassembly


def sign12(value):
    return value - 4096 if value & 2048 else value


def memory_instruction(elf, record, opcode, width):
    word = struct.unpack("<I", elf.at(record["pc"], 4))[0]
    assert word & 127 == opcode and (word >> 12) & 7 == width
    base = record["registers"][(word >> 15) & 31]
    if opcode == 0x23:
        immediate = sign12(((word >> 25) << 5) | ((word >> 7) & 31))
        value_register = (word >> 20) & 31
    else:
        immediate = sign12(word >> 20)
        value_register = (word >> 7) & 31
    return (base + immediate) & ((1 << 64) - 1), value_register


def check_run(artifact, output, build, case):
    cfg = CONFIG[build]
    binary = artifact / "replay/example/out" / f"core.{build}"
    elf = ELF(binary)
    debug = ELF(binary.with_name(binary.name + ".dbg"))
    symbols = {}
    for name, expected in [("LLVMFuzzerTestOneInput", cfg["entry"]),
                           ("h_nop", cfg["nop"]), ("h_admin", cfg["admin"]),
                           ("handlers", cfg["table"])]:
        address, size = debug.symbol(name)
        assert address == expected
        checked_size = 256 * 8 if name == "handlers" else size
        assert elf.at(address, checked_size) == debug.at(address, checked_size)
        symbols[name] = dict(address=hex(address), compared_bytes=checked_size,
                            sha256=hashlib.sha256(elf.at(address, checked_size)).hexdigest())
    assert elf.at(cfg["nop"], 4) == elf.at(cfg["admin"], 4) == bytes.fromhex("67800000")
    assert struct.unpack("<256Q", elf.at(cfg["table"], 2048)) == (
        (cfg["nop"],) * 255 + (cfg["admin"],))
    records, disassembly = parse_trace(output / f"{build}-{case}-instructions.trace", elf)
    by_pc = {}
    for i, record in enumerate(records):
        by_pc.setdefault(record["pc"], []).append((i, record))

    def once(name):
        found = by_pc[cfg[name]]
        assert len(found) == 1, (name, len(found))
        return found[0]

    input_bytes = (artifact / "replay/example/inputs" / f"core-{case}.bin").read_bytes()
    assert input_bytes[:6] == b"\0" * 6
    payload = input_bytes[6:]
    assert payload == (b"A" * 20 + b"\xff" if case == "exploit" else b"alice")
    _, entry = once("entry")
    assert entry["registers"][11] == len(payload)
    _, allocation = once("allocation")
    assert allocation["registers"][10] == 21
    _, allocated = once("allocated")
    base = allocated["registers"][10]
    assert base != 0
    init_index, initialize = once("initialize")
    address, value_register = memory_instruction(elf, initialize, 0x23, 0)
    assert address == base + 20 and initialize["registers"][value_register] == 0
    stores = []
    copies = by_pc[cfg["copy"]]
    assert len(copies) == len(payload)
    for offset, (index, record) in enumerate(copies):
        address, value_register = memory_instruction(elf, record, 0x23, 0)
        value = record["registers"][value_register] & 255
        assert address == base + offset and value == payload[offset]
        assert init_index < index
        stores.append(dict(index=offset, address=hex(address), value=hex(value),
                           trace_line=record["line"]))
    load_index, op_load = once("op_load")
    address, destination_register = memory_instruction(elf, op_load, 0x03, 4)
    assert address == base + 20 and copies[-1][0] < load_index
    op = records[load_index + 1]["registers"][destination_register]
    assert op == (255 if case == "exploit" else 0)
    table_index, table_load = once("table_load")
    address, destination_register = memory_instruction(elf, table_load, 0x03, 3)
    assert address == cfg["table"] + 8 * op and load_index < table_index
    target = records[table_index + 1]["registers"][destination_register]
    expected = cfg["admin"] if case == "exploit" else cfg["nop"]
    assert target == expected
    call_index, call = once("call")
    assert struct.unpack("<I", elf.at(call["pc"], 4))[0] == 0x000500e7  # jalr ra,a0,0
    assert call["registers"][10] == target and table_index < call_index
    assert records[call_index + 1]["pc"] == target
    assert records[call_index + 2]["pc"] == cfg["call"] + 4
    assert len(by_pc[target]) == 1
    other = cfg["nop"] if case == "exploit" else cfg["admin"]
    assert other not in by_pc
    result = dict(build=build, case=case, status="PASS", allocation_bytes=21,
                  allocation_base=hex(base), payload_bytes=len(payload),
                  copy_instruction=disassembly[cfg["copy"]], copy_pc=hex(cfg["copy"]),
                  stores=stores, op_address=hex(base + 20), op_after_copy=hex(op),
                  op_load_pc=hex(cfg["op_load"]), op_load_trace_line=op_load["line"],
                  handler="h_admin" if op == 255 else "h_nop", handler_pc=hex(target),
                  call_pc=hex(cfg["call"]), call_trace_line=call["line"],
                  handler_trace_line=records[call_index + 1]["line"],
                  debug_symbol_bytes_match_proved_binary=symbols)
    if build == "asan" and case == "exploit":
        final_index = copies[-1][0]
        branch = records[final_index - 1]
        assert branch["pc"] == 0x7e6f4
        assert struct.unpack("<I", elf.at(branch["pc"], 4))[0] == 0xfd12c8e3
        shadow, offset = branch["registers"][17], branch["registers"][5]
        assert shadow == 5 and offset == 4 and shadow > offset
        result["asan_final_store_check"] = dict(pc=hex(branch["pc"]),
            trace_line=branch["line"], shadow_byte=shadow, address_low_3_bits=offset,
            branch_to_store_taken=True)
    return result


def check_all(artifact, output):
    runs = json.loads((output / "runs.json").read_text())
    assert len(runs) == 8
    for run in runs:
        stem = f'{run["build"]}-{run["case"]}-{run["mode"]}'
        assert run["returncode"] == 0
        assert (output / (stem + ".stdout")).read_bytes() == b"0\n"
        stderr = (output / (stem + ".stderr")).read_bytes()
        if run["mode"] == "instructions":
            assert stderr == b""
        else:
            assert b"exit_group(0)" in stderr
        for name, digest in run["output_sha256"].items():
            assert sha256(output / name) == digest
    return dict(status="PASS", cases=[check_run(artifact, output, build, case)
        for build in CONFIG for case in ("benign", "exploit")])


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--artifact", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--output", type=Path, default=Path(__file__).resolve().parent / "retained")
    args = parser.parse_args()
    print(json.dumps(check_all(args.artifact, args.output), indent=2))

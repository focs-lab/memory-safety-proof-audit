"""Small RV64 integer disassembler for inspecting the pinned certificate PCs."""
import struct
import sys
from pathlib import Path

BIN = (Path(sys.argv[3]) if __name__ == '__main__' and len(sys.argv) > 3 else
       Path(__file__).parent / 'binaries/FuzzStunClient/FuzzStunClient.plain')
raw = BIN.read_bytes()
phoff = struct.unpack_from('<Q', raw, 32)[0]
phsize, phnum = struct.unpack_from('<HH', raw, 54)
segments = []
for j in range(phnum):
    kind, flags, off, va, pa, filesz, memsz, al = struct.unpack_from('<IIQQQQQQ', raw, phoff+j*phsize)
    if kind == 1:
        segments.append((va, off, filesz))

def word(pc):
    for va, off, n in segments:
        if va <= pc < va+n:
            return struct.unpack_from('<I', raw, off+pc-va)[0]
    raise ValueError(hex(pc))

def sx(v, n):
    return v-(1<<n) if v & (1<<(n-1)) else v

def decode(pc):
    w = word(pc)
    op, d, f, a, b, f7 = w & 127, (w>>7)&31, (w>>12)&7, (w>>15)&31, (w>>20)&31, w>>25
    im = sx(w>>20,12)
    if op == 3:
        return f'{["lb","lh","lw","ld","lbu","lhu","lwu","?"][f]} x{d}, {im}(x{a})'
    if op == 35:
        im = sx(((w>>25)<<5)|((w>>7)&31),12)
        return f'{["sb","sh","sw","sd","?","?","?","?"][f]} x{b}, {im}(x{a})'
    if op in (19,27):
        name = {0:'addi',1:'slli',2:'slti',3:'sltiu',4:'xori',5:'srai' if w>>30&1 else 'srli',6:'ori',7:'andi'}[f]
        if f in (1,5): im = (w>>20)&(31 if op==27 else 63)
        if op==27: name+='w'
        return f'{name} x{d}, x{a}, {im}'
    if op in (51,59):
        name = ['mul','mulh','mulhsu','mulhu','div','divu','rem','remu'][f] if f7==1 else ['sub' if f7==32 else 'add','sll','slt','sltu','xor','sra' if f7==32 else 'srl','or','and'][f]
        if op==59: name+='w'
        return f'{name} x{d}, x{a}, x{b}'
    if op==99:
        im=sx(((w>>31)<<12)|(((w>>7)&1)<<11)|(((w>>25)&63)<<5)|(((w>>8)&15)<<1),13)
        return f'{["beq","bne","?","?","blt","bge","bltu","bgeu"][f]} x{a}, x{b}, {hex(pc+im)}'
    if op==111:
        im=sx(((w>>31)<<20)|(((w>>12)&255)<<12)|(((w>>20)&1)<<11)|(((w>>21)&1023)<<1),21)
        return f'jal x{d}, {hex(pc+im)}'
    if op==103: return f'jalr x{d}, {im}(x{a})'
    if op in (55,23): return f'{"lui" if op==55 else "auipc"} x{d}, {hex(w & ~4095)}'
    return f'.word {hex(w)}'

if __name__=='__main__':
    lo,hi=map(lambda x:int(x,0),sys.argv[1:3])
    for pc in range(lo,hi,4):
        print(f'{pc:#x}: {word(pc):08x}  {decode(pc)}')

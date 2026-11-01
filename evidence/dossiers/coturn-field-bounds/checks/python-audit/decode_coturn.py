"""Translate the published certificate serialization for read-only inspection."""
import json
import re
from pathlib import Path

BASE = Path('/Users/umang/Documents/ChatGPT/Verification gaps')
LIB = BASE / 'tmp/bzip2-proof-review/oss-verify-proofs/proofs/coturn/FuzzStunClient/lib'

def decompress(s):
    out = bytearray()
    i = 0
    dg = lambda j: ord(s[j]) - 35
    while i < len(s):
        t = dg(i)
        i += 1
        if t <= 10:
            if t == 10:
                k = 11 + 30 * dg(i) + dg(i + 1)
                i += 2
            else:
                k = t + 1
            out.extend(s[i:i + k].encode('ascii'))
            i += k
        elif t >= 30:
            out.append(34)
        else:
            if t == 29:
                k = 22 + 30 * dg(i) + dg(i + 1)
                i += 2
            else:
                k = t - 7
            e, f = dg(i), dg(i + 1)
            if e < 14:
                d = 1 + 30 * e + f
                i += 2
            elif e < 26:
                d = 421 + 900 * (e - 14) + 30 * f + dg(i + 2)
                i += 3
            elif e < 29:
                d = 11221 + 27000 * (e - 26) + 900 * f + 30 * dg(i + 2) + dg(i + 3)
                i += 4
            else:
                d = 92221 + 27000 * f + 900 * dg(i + 2) + 30 * dg(i + 3) + dg(i + 4)
                i += 5
            assert 0 < d <= len(out) and k <= d
            out.extend(out[len(out) - d:len(out) - d + k])
    return out.decode('ascii')

class Decoder:
    def __init__(self, text):
        self.s = text
        self.i = 0

    def var(self):
        a = 0
        for _ in range(16):
            d = ord(self.s[self.i]) - 35
            self.i += 1
            assert 0 <= d < 90
            a = a * 45 + (d if d < 45 else d - 45)
            if d < 45:
                return a
        return a

    def u(self):
        if self.s[self.i] == '!':
            self.i += 1
            sign, count = self.var(), self.var()
            a = 0
            for _ in range(count):
                a = a * 4294967296 + self.u()
            return -a if sign == 1 else a
        return self.var()

    def z(self):
        if self.s[self.i] == '!':
            return self.u()
        v = self.var()
        return v // 2 if v % 2 == 0 else -(v + 1) // 2

    def seq(self, fn):
        return [fn() for _ in range(self.u())]

    def lin(self):
        count = self.u()
        const = self.z()
        return {'const': const, 'terms': [[self.u(), self.z()] for _ in range(count)]}

    def box(self):
        sy, k = self.u(), self.u()
        lo = self.z() if k % 2 else None
        hi = self.z() if k >= 2 else None
        return [sy, lo, hi]

    def state(self):
        return {
            'regs': self.seq(lambda: [self.u(), self.lin()]),
            'slots': self.seq(lambda: [self.z(), self.u(), self.lin()]),
            'globs': self.seq(lambda: [self.u(), self.u(), self.lin()]),
            'box': self.seq(self.box),
            'cong': self.seq(lambda: [self.u(), self.u(), self.z()]),
            'cons': self.seq(self.lin),
            'nul': self.seq(lambda: [self.z(), self.z()]),
            'valset': self.seq(lambda: [self.u(), self.seq(self.z)]),
            'conddef': self.seq(lambda: [self.u(), self.u(), self.lin(), self.lin()]),
            'moddef': self.seq(lambda: [self.u(), self.lin(), self.u()]),
            'next': self.u(),
        }

    def cut(self):
        return {'pc': self.u(), 'ctx': self.seq(self.u), 'states': self.seq(self.state), 'ranks': self.seq(self.lin)}

    def unit(self):
        out = {'entry': self.u(), 'vid': self.u(), 'sp': self.z(), 'sclass': [self.u(), self.u()]}
        out.update(pre=self.state(), cuts=self.seq(self.cut), exits=self.seq(self.state),
                   wstack=self.seq(lambda: [self.z(), self.z()]),
                   wglobs=self.seq(lambda: [self.u(), self.u()]), errno=self.u(), own=self.z(),
                   calls=self.seq(lambda: [self.u(), self.u(), self.u()]), fuel=self.u())
        out['root'] = self.u() if self.u() == 1 else None
        out['prio'] = self.u()
        return out

def main():
    units = []
    for p in sorted(LIB.glob('VCertS_src0_p*.v')):
        s = decompress(re.search(r'StrLz.lz_dec\s*"([^"]*)"', p.read_text()).group(1))
        d = Decoder(s)
        part = d.seq(d.unit)
        assert d.i == len(s), (p, d.i, len(s))
        for u in part:
            u['certificate_file'] = p.name
        units.extend(part)
    out = BASE / 'tmp/struct-field-search/coturn-certificate.json'
    out.write_text(json.dumps(units, indent=2) + '\n')
    print(json.dumps({'units': len(units), 'artifact': str(out)}, indent=2))

if __name__ == '__main__':
    main()

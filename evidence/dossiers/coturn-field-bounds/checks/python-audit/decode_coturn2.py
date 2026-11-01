"""Read-only Python translation of the published VCertDecode2 decoder."""
import json
import re
from pathlib import Path
from decode_coturn import Decoder, decompress, BASE, LIB

def encoded(path):
    return decompress(re.search(r'StrLz.lz_dec\s*"([^"]*)"', path.read_text()).group(1))

class Decoder2(Decoder):
    def __init__(self, s, tables=None):
        super().__init__(s)
        self.tables = tables

    def reg(self): return [self.u(), self.lin()]
    def slot(self): return [self.z(), self.u(), self.lin()]
    def glob(self): return [self.u(), self.u(), self.lin()]
    def pair(self): return [self.z(), self.z()]

    def kind(self):
        k = self.u()
        if k == 0: return ['fake', self.u(), self.u()]
        if k == 1: return ['arg']
        if k == 2: return ['flag', self.u()]
        return ['shadow', self.u()]

    def region(self):
        r = {'base': self.u(), 'disp': self.u(), 'kind': self.kind(),
             'lo': self.z(), 'hi': self.z(), 'write': self.seq(self.pair),
             'cells': self.seq(self.slot), 'nul': self.seq(self.pair)}
        r['b8'] = self.u() if self.u() == 1 else None
        return r

    def dictionary(self):
        return [self.seq(lambda: self.seq(fn)) for fn in [self.reg, self.slot, self.box, self.lin, self.region]]

    def seqd(self, idx, fn):
        h = self.u()
        if h % 2:
            assert h//2 <= len(self.tables[idx])
            return self.tables[idx][h//2] if h//2 < len(self.tables[idx]) else []
        return [fn() for _ in range(h//2)]

    def body(self):
        return {
            'regs': self.seqd(0, self.reg), 'slots': self.seqd(1, self.slot),
            'globs': self.seq(self.glob), 'box': self.seqd(2, self.box),
            'cong': self.seq(lambda: [self.u(), self.u(), self.z()]),
            'cons': self.seqd(3, self.lin),
            'nul': self.seq(self.pair),
            'valset': self.seq(lambda: [self.u(), self.seq(self.z)]),
            'conddef': self.seq(lambda: [self.u(), self.u(), self.lin(), self.lin()]),
            'moddef': self.seq(lambda: [self.u(), self.lin(), self.u()]),
        }

    def state2(self):
        b = self.body()
        r = {'c1': b, 'regions': self.seqd(4, self.region),
             'divdef': self.seq(lambda: [self.u(), self.lin(), self.u()]),
             'live': self.seq(self.u)}
        b['next'] = self.u()
        return r

    def cut2(self):
        return {'pc': self.u(), 'ctx': self.seq(self.u), 'states': self.seq(self.state2),
                'ranks': self.seq(self.lin), 'traps': self.seq(lambda: self.seq(self.u))}

    def unit2(self):
        return {'u1': self.unit(), 'pre': self.state2(), 'cuts': self.seq(self.cut2),
                'exits': self.seq(self.state2),
                'write_regions': self.seq(lambda: [self.u(), self.z(), self.z()]),
                'fs_depth': self.u(), 'traps': self.seq(self.u)}

def main():
    for flavor in ['asan', 'both']:
        p = LIB/f'VCertS_{flavor}_p00.v'
        d = Decoder2(encoded(p))
        tables = d.dictionary()
        assert d.i == len(d.s), (p, d.i, len(d.s))
        units = []
        for p in sorted(LIB.glob(f'VCertS_{flavor}_p*.v')):
            if p.name.endswith('p00.v'): continue
            d = Decoder2(encoded(p), tables)
            part = d.seq(d.unit2)
            assert d.i == len(d.s), (p, d.i, len(d.s))
            for u in part:
                u['certificate_file'] = p.name
            units.extend(part)
        out = BASE/f'tmp/struct-field-search/coturn-certificate-{flavor}.ndjson'
        with out.open('w') as fh:
            for u in units:
                fh.write(json.dumps(u, separators=(',', ':'))+'\n')
        print(json.dumps({'flavor':flavor, 'units':len(units), 'dictionary_sizes':list(map(len,tables)),
                          'artifact':str(out)}), flush=True)

if __name__=='__main__':
    main()

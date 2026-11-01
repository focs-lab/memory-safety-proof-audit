#!/usr/bin/env python3
"""Check paper/evidence links, citation metadata, and recorded file digests."""
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]
AUTHOR_NAMES = {"Umang Mathur", "Prateek Saxena", "Tianyu Li", "Bo Wang",
                "Diego Meyer", "Ruishi Li"}
EXCLUDED_PREFIXES = ("blog/", "site/")
EXCLUDED_FILES = {"scripts/build_site.py", "scripts/preview_site.py"}


class Page(HTMLParser):
    def __init__(self):
        super().__init__()
        self.ids = []

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if "id" in a:
            self.ids.append(a["id"])


def check_link(page, ref):
    u = urlsplit(ref)
    if u.scheme or u.netloc:
        return
    target = (page.parent / unquote(u.path)).resolve() if u.path else page
    assert target.is_relative_to(ROOT), f"Link leaves release: {page}: {ref}"
    assert target.exists(), f"Missing target: {page.relative_to(ROOT)}: {ref}"
    if target.suffix == ".pdf":
        assert target.read_bytes().startswith(b"%PDF-"), target
    if target.suffix in {".html", ".md"} and u.fragment:
        p = Page()
        content = target.read_text()
        p.feed(content)
        if target.suffix == ".md":
            seen = {}
            for title in re.findall(r"(?m)^#{1,6} +(.+?)\s*#*\s*$", content):
                slug = re.sub(r"[^\w\s-]", "", title.lower()).replace(" ", "-")
                occurrence = seen.get(slug, 0)
                p.ids.append(f"{slug}-{occurrence}" if occurrence else slug)
                seen[slug] = occurrence + 1
        assert unquote(u.fragment) in p.ids, f"Missing anchor: {ref}"


if __name__ == "__main__":
    citation = (ROOT / "CITATION.cff").read_text()
    pairs = re.findall(r"family-names: ([^\n]+)\n\s+given-names: ([^\n]+)", citation)
    authors = [given.strip() + " " + family.strip() for family, given in pairs]
    assert len(authors) == 6 and set(authors) == AUTHOR_NAMES, "Citation authors"
    provenance = json.loads((ROOT / "release-provenance.json").read_text())
    assert provenance["authors"] == authors, "Citation and recorded paper author order differ"
    assert (ROOT / "paper/main.pdf").read_bytes().startswith(b"%PDF-"), "Paper PDF"
    authored = [ROOT / "README.md", ROOT / "REPRODUCE.md", ROOT / "VALIDATION.md",
                ROOT / "paper/README.md", ROOT / "THIRD_PARTY.md"]
    authored += list((ROOT / "evidence").glob("*.md"))
    authored += list((ROOT / "evidence/reports").glob("*.md"))
    authored += list((ROOT / "evidence/dossiers").glob("*.md"))
    authored += list((ROOT / "evidence/source-snapshots/oss-verify-proofs").glob("*/README.md"))
    count = 0
    for page in authored:
        for ref in re.findall(r"\[[^\]]*\]\(([^)\s]+)\)", page.read_text()):
            check_link(page, ref)
            count += 1
    entries = (ROOT / "MANIFEST.sha256").read_text().splitlines()
    for line in entries:
        expected, relative = line.split("  ", 1)
        assert not relative.startswith(EXCLUDED_PREFIXES) and relative not in EXCLUDED_FILES, relative
        target = ROOT / relative
        assert target.is_file(), relative
        assert target.suffix.lower() not in {".tex", ".bib", ".html", ".htm"}, relative
        assert hashlib.sha256(target.read_bytes()).hexdigest() == expected, relative
    print(f"PASS: {count} references; citation author order; paper PDF; {len(entries)} file digests; no blog files in release manifest")

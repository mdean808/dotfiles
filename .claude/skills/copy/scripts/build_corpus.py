"""Build examples/ from sources pinned to commits made before 30 Nov 2022.

Usage: python3 -I build_corpus.py <download dir> <skill dir>

The download dir holds:
  govuk/      alphagov/govuk-design-system at d3b6145 (2022-10-26)
  polaris/    Shopify/polaris at d7dc443 (2022-10-31)
  firefox/    mozilla/gecko-dev at 722dd73 (2022-10), */locales/en-US/*.ftl
  readmes/    READMEs listed in READMES below
"""

import re
import sys
from pathlib import Path

GOVUK = ("govuk", "alphagov/govuk-design-system@d3b6145")
POLARIS = ("polaris", "Shopify/polaris@d7dc443")
FIREFOX = ("firefox", "mozilla/gecko-dev@722dd73")
READMES = {
    "BurntSushi_ripgrep.md": "BurntSushi/ripgrep@55e62a4",
    "sharkdp_fd.md": "sharkdp/fd@e9121ee",
    "sharkdp_bat.md": "sharkdp/bat@9679ae3",
    "junegunn_fzf.md": "junegunn/fzf@9d041aa",
    "psf_requests.md": "psf/requests@8bce583",
    "httpie_httpie.md": "httpie/httpie@621042a",
    "stedolan_jq.md": "stedolan/jq@174db0f",
    "restic_restic.md": "restic/restic@34a6a24",
    "caddyserver_caddy.md": "caddyserver/caddy@6c0d051",
}

GOVUK_FIELDS = {
    "label": "label",
    "legend": "label",
    "titleText": "heading",
    "hint": "hint",
    "errorMessage": "error",
    "errorList": "error",
    "titleTextSummary": "heading",
    "summaryText": "label",
    "html": "body",
}


GOVUK_GUIDES = [
    "error-message", "error-summary", "validation", "button", "text-input", "radios",
    "checkboxes", "question-pages", "confirmation-pages", "notification-banner",
    "warning-text", "inset-text", "details", "summary-list", "page-not-found-pages",
    "problem-with-the-service-pages", "service-unavailable-pages", "dates", "tag",
]


def out_dir(root: Path) -> Path:
    return Path(sys.argv[2]) / "examples"


def clean(text: str) -> str:
    text = re.sub(r"<[^>]+>", " ", text)
    return re.sub(r"\s+", " ", text).strip()


def govuk(root: Path, rows: dict) -> None:
    name, source = GOVUK
    for path in sorted((root / name / "src").glob("*/*/*/index.njk")):
        where = f"{source}:{path.relative_to(root / name)}"
        page = path.parts[-3]
        body = path.read_text()
        for field, element in GOVUK_FIELDS.items():
            for match in re.finditer(rf"{field}:\s*\{{[^{{}}]*?(?:text|html):\s*\"([^\"]+)\"", body):
                add(rows, element, match.group(1), f"{page} example", where)
        for match in re.finditer(r"\btext:\s*\"([^\"]+)\"", body):
            before = body[max(0, match.start() - 200) : match.start()]
            if "govukButton" in before.split("})")[-1]:
                add(rows, "button", match.group(1), f"{page} example", where)
        for match in re.finditer(r"<p class=\"govuk-body\">\s*(.*?)\s*</p>", body, re.S):
            add(rows, "body", match.group(1), f"{page} page text", where)
        for match in re.finditer(r"<h[12] class=\"govuk-heading-[lm]\">(.*?)</h[12]>", body):
            add(rows, "heading", match.group(1), f"{page} page text", where)
    guides = out_dir(root) / "guides"
    guides.mkdir(exist_ok=True)
    for page in GOVUK_GUIDES:
        path = next((root / name / "src").glob(f"*/{page}/index.md.njk"))
        text = re.sub(r"(?m)^\{\{.*?\}\}$|^\{%.*?%\}$", "", path.read_text())
        (guides / f"govuk-{page}.md").write_text(
            f"<!-- Source: {source}:{path.relative_to(root / name)} -->\n\n{text}"
        )


def polaris(root: Path, rows: dict, pairs: list) -> None:
    name, source = POLARIS
    for path in sorted((root / name / "polaris.shopify.com/content").rglob("*.md")):
        where = f"{source}:{path.relative_to(root / name)}"
        heading = ""
        text = path.read_text()
        for block in re.finditer(r"(?ms)^(#{2,4} [^\n]+)?.*?<!-- dodont -->(.*?)<!-- end -->", text):
            before = text[: block.start(2)]
            headings = re.findall(r"(?m)^#{2,4} (.+)$", before)
            heading = headings[-1] if headings else path.stem
            dos, donts = [], []
            for part in re.split(r"(?m)^#### ", block.group(2)):
                title, _, body = part.partition("\n")
                items = [clean(re.sub(r"^\s*[-*]\s*", "", item)) for item in re.split(r"\n\s*\n|\n- ", body)]
                items = [item for item in items if item and not item.startswith("![")]
                if title.strip().lower().startswith("do") and "n" not in title.strip().lower()[2:3]:
                    dos += items
                elif title.strip().lower().startswith("don"):
                    donts += items
            if dos or donts:
                pairs.append((f"{path.stem}: {heading}", dos, donts, where))


FTL_ELEMENT = [
    (r"error|fail|invalid|unable|cannot", "error"),
    (r"confirm|are-you-sure|-warning", "confirmation"),
    (r"empty|no-results|none-|nothing", "empty"),
    (r"tooltip|tooltiptext", "tooltip"),
    (r"button|-btn|accept|cancel|\.label.*accesskey", "button"),
    (r"desc|explanation|intro|info|subtitle|summary|message|body|text$|-content", "description"),
    (r"title|header|heading", "heading"),
    (r"label|caption|option|checkbox|radio", "label"),
]


def ftl(root: Path, rows: dict) -> None:
    name, source = FIREFOX
    for path in sorted((root / name).rglob("*.ftl")):
        where = f"{source}:{path.relative_to(root / name)}"
        current = None
        values: list[tuple[str, str]] = []
        lines = path.read_text().splitlines()

        def flush():
            for key, value in values:
                value = clean(value)
                if len(value) < 3 or value.startswith("{ $") and len(value) < 12:
                    continue
                if re.fullmatch(r"[\w.-]+", value) and "-" in value:
                    continue
                element = next((el for pat, el in FTL_ELEMENT if re.search(pat, key)), "label")
                add(rows, element, value, key, where)

        for raw in lines:
            if raw.startswith("#") or not raw.strip():
                continue
            top = re.match(r"^(-?[a-zA-Z][\w-]*)\s*=\s*(.*)$", raw)
            attr = re.match(r"^\s+\.([\w-]+)\s*=\s*(.*)$", raw)
            if top:
                flush()
                current, values = top.group(1), []
                if top.group(2).strip():
                    values.append((current, top.group(2)))
            elif attr and current:
                if attr.group(1) in ("accesskey", "style", "key", "commandkey"):
                    continue
                values.append((f"{current}.{attr.group(1)}", attr.group(2)))
            elif current and values and raw.startswith(" "):
                key, value = values[-1]
                values[-1] = (key, f"{value} {raw.strip()}")
        flush()


NOISE = re.compile(r"^(ssl-|sec-|cert-|mozilla-pkix|pkix-|psmerr|mr2022|mr1-|onboarding|newtab-pocket|spotlight|cfr-|-)")


def add(rows: dict, element: str, text: str, context: str, where: str) -> None:
    text = clean(text)
    if NOISE.search(context) or text in ("text", "html"):
        return
    if not text or "{{" in text or "{%" in text or len(text) > 400:
        return
    rows.setdefault(element, {}).setdefault(text, (context, where))


def main() -> None:
    root, out = Path(sys.argv[1]), Path(sys.argv[2]) / "examples"
    out.mkdir(parents=True, exist_ok=True)
    rows: dict = {}
    pairs: list = []
    govuk(root, rows)
    ftl(root, rows)
    polaris(root, rows, pairs)
    for element, entries in sorted(rows.items()):
        with open(out / f"{element}.tsv", "w") as handle:
            handle.write("text\tcontext\tsource\n")
            for text, (context, where) in entries.items():
                handle.write(f"{text}\t{context}\t{where}\n")
        print(f"{element}: {len(entries)}")
    with open(out / "do-dont.md", "w") as handle:
        handle.write("# Do and don't pairs from Shopify Polaris (Oct 2022)\n\n")
        for heading, dos, donts, where in pairs:
            handle.write(f"## {heading}\n\nSource: {where}\n\n")
            for item in dos:
                handle.write(f"- Do: {item}\n")
            for item in donts:
                handle.write(f"- Don't: {item}\n")
            handle.write("\n")
    print(f"do-dont pairs: {len(pairs)}")
    docs = out / "docs"
    docs.mkdir(exist_ok=True)
    for file, source in READMES.items():
        path = root / "readmes" / file
        if path.exists() and path.stat().st_size:
            (docs / file).write_text(f"<!-- Source: {source} -->\n\n{path.read_text()}")
    print(f"readmes: {len(list(docs.iterdir()))}")


main()

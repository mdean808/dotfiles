#!/usr/bin/env python3
import argparse
import json
import re
import subprocess
import sys
import time

WATCH_ROUNDS = 30
WATCH_INTERVAL = 60
COVERED = re.compile(r'"coveredCommitId":"([0-9a-f]+)"')
STATUS_LINE = re.compile(r"^[\W_]*(reviews? (in progress|paused|failed|skipped)|rate limit)", re.I)
SUMMARY_MARKER = "summarize by coderabbit.ai"
API_TIMEOUT = 60

BOT_MARKERS = ("coderabbit-ai-generated", "by CodeRabbit", "by coderabbit.ai")
DROPPED_SUMMARY = re.compile(
    r"Prompt for AI Agents|Prompt to fix review comments|Fix comments|Review info"
    r"|Supported by static analysis|Tools</summary>|Analysis chain"
)
DETAILS_TAG = re.compile(r"<details>|</details>")
HTML_COMMENT = re.compile(r"<!--.*?-->", re.S)
LEFTOVER_PROMPT = re.compile(r"Prompt for AI Agents|Prompt to fix review comments|Fix comments</summary>")


def get(path):
    return json.loads(
        subprocess.run(
            ["glab", "api", path], check=True, capture_output=True, text=True, timeout=API_TIMEOUT
        ).stdout
    )


def get_all(path):
    items, page = [], 1
    while batch := get(f"{path}{'&' if '?' in path else '?'}per_page=100&page={page}"):
        items.extend(batch)
        page += 1
    return items


def is_bot(note):
    return any(m in note["body"] for m in BOT_MARKERS)


def drop_details(body):
    out, pos, depth, drop_from = [], 0, 0, None
    for tag in DETAILS_TAG.finditer(body):
        if tag.group() == "<details>":
            if drop_from is None:
                summary = body[tag.end() : body.find("</summary>", tag.end()) + len("</summary>")]
                if DROPPED_SUMMARY.search(summary):
                    out.append(body[pos : tag.start()])
                    drop_from, depth = tag.start(), 0
            if drop_from is not None:
                depth += 1
        elif drop_from is not None:
            depth -= 1
            if depth == 0:
                pos, drop_from = tag.end(), None
    if drop_from is None:
        out.append(body[pos:])
    return "".join(out)


def clean(body):
    body = drop_details(body)
    body = HTML_COMMENT.sub("", body)
    body = re.sub(r"\n{3,}", "\n\n", body).strip()
    if LEFTOVER_PROMPT.search(body):
        return "[body withheld: an agent prompt could not be stripped]"
    return body


def title(body):
    match = re.search(r"^\*\*([^*|]+)\*\*\s*$", clean(body), re.M)
    return match.group(1).strip() if match else clean(body).split("\n")[0][:100]


def who(note, me):
    if note["system"]:
        return "GitLab"
    if is_bot(note):
        return "CodeRabbit"
    if note["author"]["username"] == me:
        return "you"
    return note["author"]["username"]


def location(note):
    pos = note.get("position") or {}
    path = pos.get("new_path") or pos.get("old_path")
    if not path:
        return "general"
    return f"{path}:{pos.get('new_line') or pos.get('old_line') or '?'}"


def skipped(first):
    body = first["body"]
    return (
        first["system"]
        or "linear-linkback" in body
        or "summarize by coderabbit.ai" in body
        or body.lstrip().startswith("@coderabbitai")
    )


def replied_after_resolve(notes, me):
    resolved_at = notes[0].get("resolved_at") or ""
    return any(
        n["created_at"] > resolved_at
        and not n["system"]
        and not is_bot(n)
        and n["author"]["username"] != me
        for n in notes[1:]
    )


def print_notes(notes, me):
    for note in notes:
        edited = f" · edited {note['updated_at']}" if note["updated_at"] != note["created_at"] else ""
        print(f"### {who(note, me)} · {note['created_at']}{edited}\n")
        print(clean(note["body"]) + "\n")


def review_state(iid, sha):
    head = get(f"projects/:id/merge_requests/{iid}")["sha"]
    if head != sha:
        return "NOT_PUSHED"
    pushed_at = min(
        (
            v["created_at"]
            for v in get(f"projects/:id/merge_requests/{iid}/versions")
            if v["head_commit_sha"] == sha
        ),
        default="",
    )
    notes = [
        n
        for n in get(f"projects/:id/merge_requests/{iid}/notes?per_page=100&sort=desc&order_by=updated_at")
        if "coderabbit" in n["body"].lower()
    ]
    summaries = [n for n in notes if SUMMARY_MARKER in n["body"]]
    recent = [n for n in summaries if n["updated_at"] > pushed_at]
    last_request = max(
        (n["updated_at"] for n in notes if n["body"].lstrip().startswith("@coderabbitai review")),
        default="",
    )

    def lines(note, word):
        return [
            line.strip()[:160]
            for line in HTML_COMMENT.sub("", note["body"]).splitlines()
            if STATUS_LINE.search(line) and re.search(word, line, re.I)
        ]

    in_progress = any(lines(n, "in progress") for n in recent)
    covered = any(m == sha for n in notes for m in COVERED.findall(n["body"]))
    if covered and not in_progress:
        return "REVIEWED"
    if in_progress:
        return "IN_PROGRESS"
    for note in recent:
        failed = lines(note, "failed|skipped|rate limit")
        if failed and note["updated_at"] > last_request:
            return f"FAILED {failed[0]}"
    if any(lines(n, "paused") and n["updated_at"] > last_request for n in summaries):
        return "PAUSED"
    return "WAITING"


def watch(iid, sha):
    state = "WAITING"
    for round_no in range(1, WATCH_ROUNDS + 1):
        try:
            state = review_state(iid, sha)
        except subprocess.CalledProcessError as error:
            state = f"ERROR {error.stderr.strip()[:160]}"
        except subprocess.TimeoutExpired:
            state = f"ERROR glab api timed out after {API_TIMEOUT}s"
        print(f"round {round_no}: {state}", flush=True)
        if state == "REVIEWED" or state == "PAUSED" or state.startswith("FAILED"):
            print(state)
            return
        if round_no < WATCH_ROUNDS:
            time.sleep(WATCH_INTERVAL)
    print("NOT_PUSHED" if state == "NOT_PUSHED" else f"TIMEOUT {state}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("iid", nargs="?")
    parser.add_argument("--since", help="ISO timestamp; only items touched after it")
    parser.add_argument("--watch", metavar="SHA", help="wait for CodeRabbit to review this commit")
    args = parser.parse_args()

    iid = args.iid or json.loads(
        subprocess.run(
            ["glab", "mr", "view", "-F", "json"], check=True, capture_output=True, text=True
        ).stdout
    )["iid"]
    if args.watch:
        return watch(iid, args.watch)
    me = get("user")["username"]
    mr = get(f"projects/:id/merge_requests/{iid}")
    discussions = get_all(f"projects/:id/merge_requests/{iid}/discussions")

    print(f"# MR !{iid} {mr['title']}\n\nhead: {mr['sha']}  you: {me}")
    if args.since:
        print(f"since: {args.since}")

    resolved_since = []
    for disc in discussions:
        notes = disc["notes"]
        first = notes[0]
        if skipped(first):
            continue
        touched = max(n["updated_at"] for n in notes)
        if args.since and touched <= args.since:
            continue

        if "for review status" in first["body"]:
            findings = re.sub(r"\*\*Actionable comments posted: \d+\*\*|^-{3,}$", "", clean(first["body"]), flags=re.M).strip()
            replies = notes[1:]
            if findings or replies:
                print(f"\n## Review body {first['created_at']} (nitpicks, outside-diff, duplicates)\n")
                if findings:
                    print(findings + "\n")
                print_notes(replies, me)
            continue

        if not first.get("resolvable") and is_bot(first):
            continue
        state = "unresolved"
        if first.get("resolvable") and first.get("resolved"):
            if not replied_after_resolve(notes, me):
                resolved_since.append(f"- {location(first)} {title(first['body'])}")
                continue
            state = "resolved, replied after"

        print(f"\n## Thread {disc['id']} · {location(first)} · {state}\n")
        print_notes(notes, me)

    if args.since:
        print("\n## Resolved since " + args.since + "\n")
        print("\n".join(resolved_since) or "- none")


if __name__ == "__main__":
    sys.exit(main())

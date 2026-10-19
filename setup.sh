#!/usr/bin/env bash
#
# setup.sh - Extract test subjects (recent Gmail correspondence addresses)
#            and store them in sample.txt (local only; gitignored).
#
# Usage: ./setup.sh [max_messages]   (default: 50)
#
set -euo pipefail
cd "$(dirname "$0")"

GMAIL_CLI="/opt/hatch/bin/hatch_gws_cli"
MAX_MESSAGES="${1:-50}"
OUTPUT="sample.txt"
TMP_JSON="$(mktemp)"
trap 'rm -f "$TMP_JSON"' EXIT

# Own address, excluded from the results.
OWN="$("$GMAIL_CLI" gmail users getProfile --params '{"userId":"me"}' \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["emailAddress"])')"

# Recent inbox messages as JSON.
"$GMAIL_CLI" gmail +triage --query "in:inbox" --max "$MAX_MESSAGES" --format json > "$TMP_JSON"

# Extract unique sender addresses, excluding our own.
python3 - "$TMP_JSON" "$OUTPUT" "$OWN" <<'PYEOF'
import json, re, sys

tmp_json, output, own = sys.argv[1], sys.argv[2], sys.argv[3].strip().lower()
data = json.load(open(tmp_json))

addrs, seen = [], set()
for m in data.get("messages", []):
    frm = m.get("from", "") or ""
    match = re.search(r"<([^<>]+)>", frm)
    email = (match.group(1) if match else frm).strip().lower()
    if email and email != own and "@" in email and email not in seen:
        seen.add(email)
        addrs.append(email)

with open(output, "w") as f:
    for a in addrs:
        f.write(a + "\n")

print(f"Wrote {len(addrs)} unique addresses to {output}")
PYEOF

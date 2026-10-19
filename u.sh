#!/usr/bin/env bash
set -euo pipefail

GITHUB_CLI="/opt/hatch/bin/github"

# Ensure a filename was provided
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <filename>" >&2
    exit 1
fi

TARGET_FILE="$1"

# Check if the file exists locally
if [[ ! -f "$TARGET_FILE" ]]; then
    echo "Error: File '$TARGET_FILE' not found." >&2
    exit 1
fi

# Derive owner/repo/branch from the local git repo
REMOTE_URL="$(git remote get-url origin)"
if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+)/([^/.]+)(\.git)?$ ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
else
    echo "Error: Could not parse GitHub owner/repo from remote URL: $REMOTE_URL" >&2
    exit 1
fi
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
COMMIT_MSG="Add $TARGET_FILE to repository"

echo "Staging $TARGET_FILE..."
git add "$TARGET_FILE"

echo "Committing changes..."
git commit -m "$COMMIT_MSG"

echo "Pushing to remote repository via GitHub connector..."
TMP_JSON="$(mktemp)"
trap 'rm -f "$TMP_JSON"' EXIT
python3 - "$TARGET_FILE" "$OWNER" "$REPO" "$BRANCH" "$COMMIT_MSG" > "$TMP_JSON" <<'PYEOF'
import json, sys

target, owner, repo, branch, message = sys.argv[1:6]
with open(target) as f:
    content = f.read()
print(json.dumps({
    "owner": owner,
    "repo": repo,
    "branch": branch,
    "message": message,
    "files": [{"path": target, "content": content}],
}))
PYEOF

"$GITHUB_CLI" call-tool --name push_files --arguments-json "$(cat "$TMP_JSON")"

echo "Syncing local branch with remote..."
git fetch origin "$BRANCH" >/dev/null 2>&1
git reset --hard "origin/$BRANCH"

echo "Successfully uploaded and pushed $TARGET_FILE to $OWNER/$REPO."

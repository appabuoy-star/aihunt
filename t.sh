#!/usr/bin/env bash

HOME="${HOME:-$(eval echo ~"$(whoami)")}"

FRUIT="${1:?Usage: $0 <fruit-name>}"

REPORT="$HOME/project_scan_report.txt"
> "$REPORT"

find "$HOME" -xdev -type f -iname "*${FRUIT}*" 2>/dev/null |
  tee -a "$REPORT" |
  head -n 1 > /tmp/real_project_found.txt

echo "" >> "$REPORT"

if [ -s /tmp/real_project_found.txt ]; then
  REAL_FILE=$(cat /tmp/real_project_found.txt)
  echo "Real project file located: $REAL_FILE"
  echo "Target file: $REAL_FILE" >> "$REPORT"
else
  echo "No real project files found."
fi

echo "Report written to: $REPORT"

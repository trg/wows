#!/usr/bin/env bash
# Fetch a wowsbuilds.com Legends ship page (base stats, consumables, or modifications) and print
# readable text plus a few specifically useful extracts (splash art URL, peerStats aggregate).
# wowsbuilds is a Next.js app: the base page embeds its data as a JSON blob in the HTML, and the
# /consumables and /modifications sub-routes need -L to follow a 308 redirect. See
# research-quickref.md's "Good sources" section for background.
#
# Every successful fetch is snapshotted to .cache/wowsbuilds_<slug>_<subpage>.html (gitignored)
# as a side effect. That snapshot is a fallback of last resort only, used solely if the live
# fetch comes back empty — never a substitute for a fresh fetch when the network is up, since a
# live page can change (balance patch, corrected stat). If used, the fallback prints a loud
# warning with the snapshot's age so stale data is never mistaken for a live confirmation.
#
# Usage: fetch-wowsbuilds.sh <slug> [base|consumables|modifications]
#   e.g. fetch-wowsbuilds.sh courbet
#        fetch-wowsbuilds.sh courbet consumables
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <slug> [base|consumables|modifications]" >&2
  exit 1
fi

SLUG="$1"
SUBPAGE="${2:-base}"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

case "$SUBPAGE" in
  base) URL="https://wowsbuilds.com/ships/${SLUG}" ;;
  consumables|modifications) URL="https://wowsbuilds.com/ships/${SLUG}/${SUBPAGE}" ;;
  *) echo "Unknown subpage '$SUBPAGE', expected base, consumables, or modifications" >&2; exit 1 ;;
esac

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="$SCRIPT_DIR/.cache"
CACHE_FILE="$CACHE_DIR/wowsbuilds_${SLUG}_${SUBPAGE}.html"
mkdir -p "$CACHE_DIR"

curl -s -L -A "$UA" "$URL" -o "$TMP" || true

if [ -s "$TMP" ]; then
  cp "$TMP" "$CACHE_FILE"
elif [ -f "$CACHE_FILE" ]; then
  echo "WARNING: live fetch came back empty for ${URL} — falling back to a cached snapshot from $(date -r "$CACHE_FILE" '+%Y-%m-%d %H:%M %Z'). This may be stale; treat it as provisional and re-fetch once the live page is reachable." >&2
  cp "$CACHE_FILE" "$TMP"
else
  echo "WARNING: fetch came back empty for ${URL} and no cached snapshot exists." >&2
fi

if [ "$SUBPAGE" = "base" ]; then
  echo "=== Splash art (grep for supabase ships/*.webp) ==="
  grep -o 'supabase[^"'"'"']*ships/[^"'"'"'.]*\.webp' "$TMP" | sort -u || echo "(not found)"
  echo
  echo "=== peerStats aggregate (tier+class peer group means/stdevs) ==="
  grep -o 'peerStats\\":{[^}]*}[^]]*peerGroupLabel\\":\\"[^\\]*' "$TMP" || echo "(not found)"
  echo
  echo "=== Ship parameters JSON ==="
  grep -o 'parameters\\":{[^}]*}' "$TMP" || echo "(not found)"
  echo
fi

echo "=== Readable text (children strings) ==="
python3 -c "
import re
html = open('$TMP', encoding='utf-8', errors='replace').read()
# wowsbuilds server-renders text as escaped \"children\":\"...\" strings inside a JS payload
texts = re.findall(r'\"children\\\\\":\\\\\"([^\\\\]+)\\\\\"', html)
seen = set()
for t in texts:
    if t not in seen and len(t) > 1 and t not in ('\$undefined',):
        seen.add(t)
        print(t)
"

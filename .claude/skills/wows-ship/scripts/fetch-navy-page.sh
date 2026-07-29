#!/usr/bin/env bash
# Fetch a wiki.wargaming.net Navy: page and print it as clean plain text.
# Confirms the page is Legends-specific via its own breadcrumb before printing anything,
# and falls back to the Jina reader proxy if the direct fetch hits the intermittent
# JS/cookie bot-check stub. See research-quickref.md's "Good sources" section.
#
# Usage: fetch-navy-page.sh <PageTitle>
#   e.g. fetch-navy-page.sh Courbet
#        fetch-navy-page.sh All_Ships
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <PageTitle>  (e.g. Courbet, All_Ships, MBRB_Data)" >&2
  exit 1
fi

PAGE="$1"
URL="https://wiki.wargaming.net/en/Navy:${PAGE}"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

fetch_direct() {
  curl -s -L -A "$UA" "$URL" -o "$TMP"
}

fetch_via_jina() {
  curl -s -L "https://r.jina.ai/${URL}" -o "$TMP"
}

is_legends_breadcrumb() {
  grep -q "WoWS Legends" "$TMP" 2>/dev/null
}

fetch_direct
if ! is_legends_breadcrumb; then
  echo "Direct fetch didn't confirm a Legends breadcrumb (bot-check stub or wrong page), retrying via Jina proxy..." >&2
  fetch_via_jina
fi

if ! is_legends_breadcrumb; then
  echo "WARNING: could not confirm 'WoWS Legends' breadcrumb for ${URL} — this may be the wrong game's wiki, a dead page, or a persistent bot-check. Inspect manually." >&2
fi

python3 -c "
import re
html = open('$TMP', encoding='utf-8', errors='replace').read()
text = re.sub(r'<script.*?</script>', '', html, flags=re.S)
text = re.sub(r'<style.*?</style>', '', text, flags=re.S)
text = re.sub(r'<[^>]+>', ' ', text)
text = text.replace('&#160;', ' ').replace('&nbsp;', ' ').replace('&amp;', '&').replace('&#149;', '*')
text = re.sub(r'\s+', ' ', text)
print(text)
"

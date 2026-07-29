#!/usr/bin/env bash
# Download a Wikimedia Commons file by name and save it as a web-sized ship reference photo.
# Fetches via Special:FilePath (redirects to the real media, not the wiki page HTML), then
# resizes to a max dimension so file size stays in line with the rest of public/images/ships/
# (existing files run roughly 300KB-2MB; full Commons originals can be 5-10x that).
#
# Only run this against a file you've already confirmed is PD-*/CC-BY/CC-BY-SA licensed by
# reading its Commons file page — this script does not check licensing.
#
# Usage: fetch-commons-image.sh "<Commons file name>" <output/path.jpg> [max-dimension]
#   e.g. fetch-commons-image.sh "Courbet (ship, 1913) - NH 42849 - cropped.jpg" \
#          public/images/ships/courbet.jpg
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 \"<Commons file name>\" <output/path.jpg> [max-dimension]" >&2
  exit 1
fi

FILENAME="$1"
OUT="$2"
MAXDIM="${3:-2000}"

ENCODED="$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$FILENAME")"
URL="https://commons.wikimedia.org/wiki/Special:FilePath/${ENCODED}"

TMP="$(mktemp -t commons-img).jpg"
trap 'rm -f "$TMP"' EXIT

curl -s -L "$URL" -o "$TMP"

FILETYPE="$(file -b "$TMP")"
case "$FILETYPE" in
  *PNG*) sips -s format jpeg "$TMP" --out "$TMP.jpg" >/dev/null && mv "$TMP.jpg" "$TMP" ;;
  *WEBP*|*"Web/P"*) sips -s format jpeg "$TMP" --out "$TMP.jpg" >/dev/null && mv "$TMP.jpg" "$TMP" ;;
esac

mkdir -p "$(dirname "$OUT")"
sips -Z "$MAXDIM" -s formatOptions 80 "$TMP" --out "$OUT" >/dev/null

echo "Saved to $OUT"
ls -la "$OUT"

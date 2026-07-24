#!/usr/bin/env bash
# Deploys the site by pushing main to GitHub, which triggers the
# "Deploy to GitHub Pages" Actions workflow (.github/workflows/deploy.yml).
# There is no separate build/upload step here — GitHub Actions does that;
# this script just runs the same build locally first so failures surface
# before they're pushed, then pushes and (by default) watches the run.
#
# Usage: scripts/deploy.sh [--no-watch]

set -euo pipefail
cd "$(dirname "$0")/.."

watch=1
[[ "${1:-}" == "--no-watch" ]] && watch=0

branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$branch" != "main" ]]; then
  echo "error: on branch '$branch', but GitHub Pages only deploys from 'main'." >&2
  echo "Merge or push to main to deploy." >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "error: working tree has uncommitted or untracked changes:" >&2
  git status --short >&2
  echo "Commit (or stash) before deploying." >&2
  exit 1
fi

if [[ -n "$(git log origin/main..HEAD 2>/dev/null)" ]]; then
  echo "==> Local main is ahead of origin/main; these commits will be pushed:"
  git log --oneline origin/main..HEAD
fi

echo "==> Running local build (check + astro build) as a pre-flight..."
npm run build

echo "==> Pushing main to origin..."
git push origin main

if [[ "$watch" -eq 0 ]]; then
  echo "==> Pushed without watching. Check the Actions tab:"
  echo "    https://github.com/trg/wows/actions"
  exit 0
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "==> Pushed. gh CLI not found — check the Actions tab manually:"
  echo "    https://github.com/trg/wows/actions"
  exit 0
fi

echo "==> Waiting for the workflow run to start..."
run_id=""
for _ in $(seq 1 15); do
  run_id=$(gh run list --workflow=deploy.yml --branch=main --limit=1 --json databaseId --jq '.[0].databaseId' 2>/dev/null || true)
  [[ -n "$run_id" ]] && break
  sleep 2
done

if [[ -z "$run_id" ]]; then
  echo "==> Couldn't find the run via gh. Check the Actions tab:"
  echo "    https://github.com/trg/wows/actions"
  exit 0
fi

echo "==> Watching run $run_id..."
gh run watch "$run_id" --exit-status
echo "==> Deployed: https://trg.github.io/wows/"

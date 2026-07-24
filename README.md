# WoWS Legends Companion

A mobile-first, static reference site for World of Warships: Legends — pull it up mid-match to
check a ship's loadout/tips/playstyle, or a map's key areas and strategy.

Built with Astro, static output only. See `SPEC.md` for the content schema and tone guide.

## Commands

| Command           | Action                                             |
| :----------------- | :------------------------------------------------- |
| `npm install`      | Install dependencies                                |
| `npm run dev`       | Start local dev server at `localhost:4321`          |
| `npm run check`     | Validate content against the schema (`astro check`) |
| `npm run build`     | Type-check, then build the static site to `./dist/` |
| `npm run preview`   | Preview the production build locally                |

## Adding or updating content

Use the `wows-ship` and `wows-map` Claude Code skills (`.claude/skills/`) to research and
author/update ship and map entries. See `SPEC.md` for the schema and voice guide either way.

## Deployment

The site is static and hosted on GitHub Pages at <https://trg.github.io/wows/>. Deployment is
CI-driven: `.github/workflows/deploy.yml` builds and publishes on every push to `main` — there's
no separate manual "deploy" step, and no server to log into.

To deploy: get your changes onto `main` (commit + push, or merge a PR), then run

```
scripts/deploy.sh
```

from the repo root. It refuses to run from any branch but `main` or with a dirty working tree,
runs `npm run build` locally so failures surface before they're pushed, pushes, and then watches
the Actions run to completion (use `scripts/deploy.sh --no-watch` to push and return immediately
instead of waiting). It requires the `gh` CLI to watch the run, but falls back to just pushing and
printing the Actions URL if `gh` isn't available.

You can also skip the script entirely — `git push origin main` alone is enough to trigger a
deploy; the script only adds the pre-flight build check and run-watching convenience. To check
status or debug a bad deploy: `gh run list --workflow=deploy.yml` /
<https://github.com/trg/wows/actions>.

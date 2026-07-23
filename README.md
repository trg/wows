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

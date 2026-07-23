---
name: wows-map
description: Research and create or update a World of Warships Legends map entry in src/content/maps/. Use when the user wants to add a new map to the companion site, or refresh an existing one after a layout/rotation change.
allowed-tools: WebSearch, WebFetch, Read, Write, Edit, Bash(npm run check)
---

Research and author (or refresh) one map's data file for the companion site.

## Before you start

Read `SPEC.md` at the repo root for the authoritative schema and tone guide, and
`src/content.config.ts` for the exact Zod shape. Look at both existing files in
`src/content/maps/` (`ocean.json`, `trap.json`) as reference — note they intentionally span a
sparse open-water map and a dense island map, so the schema needs to work for either extreme.

## Procedure

1. **Identify the target.** Confirm the map name, and whether this is a new entry or an update to
   an existing file (`src/content/maps/<slug>.json`, slug = kebab-case of the map name).
2. **Research the map** via WebSearch/WebFetch: size, game modes it appears in, capture point
   layout, notable islands/terrain, common camping spots, chokepoints, and flank routes. This site
   covers **World of Warships: Legends only** — a different game from the original PC/Steam
   *World of Warships*, with maps that can differ in layout/rotation. **Never use
   `wiki.worldofwarships.com` or `wiki.wargaming.net`** (the original game's wiki) or any source
   you can't confirm is describing Legends specifically. Check
   `.claude/skills/research-sources.md` first for sources already known good or bad, and update it
   with what you learn.
3. **Draft the JSON** matching the schema in `src/content.config.ts`:
   - `keyAreas` is a single unified list — don't split into separate capture/camping arrays. Each
     entry gets one `type` of `capture-point | camping-spot | chokepoint | flank-route |
     open-water`, whichever fits best.
   - `strategyNotes` — short, team-level tactical bullets, not a wall of text.
   - `description` — one or two sentences, same fun-but-not-silly tone as the rest of the site.
     This maps roughly to the naval/thematic register used for ship `playstyle.detail`.
   - Follow the "Writing like a person, not a model" checklist in `SPEC.md` for all prose fields:
     no em dashes, no AI-vocabulary tics, no rule-of-three lists, no manufactured grandeur.
4. **Write the file** to `src/content/maps/<slug>.json`.
5. **Validate**: run `npm run check`. Fix any schema errors before finishing.
6. Summarize what changed (new map, or which key areas/notes were updated) in your final response.

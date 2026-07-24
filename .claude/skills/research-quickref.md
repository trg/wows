# Research quick reference (read this first)

Compact source list and gotchas for WoWS Legends ship/map research — meant to be loaded on every
research pass. The full narrative behind any of this (how it was found, exact quotes, dead ends)
is in `research-log.md`; check there when this file doesn't cover your case, or add a new
straightforward source/gotcha here rather than a full case-study.

This site covers **World of Warships: Legends only** — a different game from the original
PC/Steam *World of Warships*, with its own balance and values. Wrong-game sources look completely
legitimate at a glance — check every new source against this list before trusting it.

## Good sources

- **`wiki.wargaming.net/en/Navy:<Ship_Name>`** — the real Legends wiki (`Navy:` namespace, **not**
  `Ship:` — same host as the banned PC wiki, easy to land on the wrong one). Confirm via the
  page's own breadcrumb ("Homepage / WoWS Legends / ..."). Has stats, consumables, module tables,
  and a "Player Opinion" Pros/Cons section that's good ready-made sourcing for
  `strengths`/`weaknesses`. Hub page: `Navy:WoWS_Legends`.
- **`wiki.wargaming.net/en/Navy:All_Ships`** — full tech tree; sanity-check a ship's tier against
  its neighbors in the line.
- **`wiki.wargaming.net/en/Navy:MBRB_Data`** — per-ship Main Battery Reload Booster numbers.
- **`wiki.wargaming.net/en/Navy:Torpedoes`** — general torpedo mechanics hub; vocabulary/categories
  only, no per-ship numbers.
- **`wowsbuilds.com/ships/<slug>`** — Legends stats/build site, good second tier-confirmation
  source. Consumables tab is client-rendered and won't come through WebFetch.
- **Official splash art** — `wowsbuilds.com/ships/<slug>.webp`, or the often-higher-res
  `wiki.wgcdn.co/images/<hash>/Legends_<Ship>_splash.png` linked from the ship's own `Navy:` file
  description page. Confirms turret/mount count and type **for the forward cluster only** — the
  standard bow-quartering camera angle always has the bridge/funnels blocking the amidships and
  aft turrets, no matter which host serves the image. `Read` can't open `.webp`; convert with
  `sips -s format png in.webp --out out.png`, crop with `sips -c <h> <w> --cropOffset <offY>
  <offX>`.
- **`commons.wikimedia.org`** — for the `image` field (real-ship reference photo) only, never
  gameplay data. Check the file's license template (PD-*/CC-BY okay, skip fair-use). Fetch via
  `Special:FilePath/<File name>` (`curl -L`), not the wiki page HTML. Confirm the category/file
  matches the right real vessel (class + commissioning year) when the name is shared by multiple
  ships.
- **Raw `curl` over WebFetch's summarizer** for multi-row stat/module tables — the summarizer has
  repeatedly paraphrased or dropped rows. Use a browser `User-Agent` header if a page 403s or
  comes back empty.

## Bad sources — do not use, even for "obviously identical" values

- `wiki.worldofwarships.com` and `wiki.wargaming.net/en/Ship:*` — original PC/Steam game wiki.
- `pc.wowsbuilds.com` — the PC-game version of wowsbuilds.
- `wowsb.fandom.com` ("WoWS Blitz Wiki") — a third, separate mobile game.
- General real-world naval-history sites (Wikipedia ship-class articles, historyofwar.org,
  naval-encyclopedia.com, destroyerhistory.org, warfarehistorynetwork.com,
  laststandonzombieisland.com) — for **gameplay data** (turret counts, arrangement, stats). Fine
  as a source for a real-ship reference **photo** only, via Commons — see above.
- `en.namu.wiki` — 403s to WebFetch.
- `WebSearch` result-synthesis — can silently blend in banned-wiki content. Treat any specific
  numeric claim that only shows up in a search summary, and not in a direct fetch of a confirmed
  source, as unverified.

## Standing gotchas

- **Splash art's ceiling is the forward turret cluster, full stop.** Cap effort at one crop; don't
  iterate on bow/stern orientation or which-end-has-the-mast reasoning chasing the rest.
- **Ask the user (in-game port view / train limits) once that ceiling is hit**, rather than
  continuing image forensics or guessing — faster, and their stated preference. Only leave
  `turrets`/`torpedoMounts` empty if they have no way to check either.
- `turrets`/`torpedoMounts` are **all-or-nothing per ship** — a partial array actively misplaces
  turrets, don't write one just because some are confirmed.
- Port/starboard layouts are almost always mirrored — confirm the near side + total count, then
  propose the mirrored layout to the user as a fast yes/no rather than treating the far side as
  equally uncertain.
- Bow/stern tell on a broadside-view splash art: anchor hawsepipe rust streaks + a breaking bow
  wave mark the bow — mast/rigging prominence is not a reliable tell (can point either way).
- Tier I ships have no upgrade slots (the slot system starts at tier IV, 1 slot, scaling to 4 from
  tier VII).
- A ship's own "Player Opinion" prose can contradict its own stat table on the same page — trust
  the hard number over the blurb.
- `torpedoMounts`' `spreadPattern`/`firingSector`/`singleTubeFire` fields are rarely confirmable
  from available sources — leave unset rather than guess.
- A "Variant" ship (reuses another ship's hull/turret/torpedo arrangement) — fetch the base ship's
  `Navy:` page too, both for layout corroboration and as a fallback Pros/Cons source if the
  variant's own page lacks one.
- A source that's usually reliable for one field can still have an isolated error on one ship
  (confirmed: wowsbuilds' gun count for Dresden). Cross-check its own field against other
  already-confirmed ships before trusting an outlier over a disagreeing source.
- Real ship history is out of scope for gameplay data, even when a detail "seems like it would
  obviously carry over" (turret count, arrangement, armament can all differ from history).

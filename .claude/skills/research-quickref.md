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
  source. The base `/ships/<slug>` page's Consumables and Modifications tabs are client-rendered
  and won't come through `curl`/WebFetch, **but the dedicated sub-routes
  `/ships/<slug>/consumables` and `/ships/<slug>/modifications` are server-rendered and fetch
  fine** — use those directly instead of the tab click. The ship's splash art URL isn't always the
  `wowsbuilds.com/ships/<slug>.webp` pattern seen on earlier ships (404'd for Provorny); grep the
  base page's HTML for a `supabase.co/storage/.../ships/<slug>.webp` URL instead and fetch that
  directly. Watch for occasional stray field glitches on the base stats page (Mahan's torpedo
  range rendered as "80.00 km" instead of 8.0 km, an apparent units/formatting bug) — cross-check
  any implausible number against the `Navy:` wiki page rather than assuming it's real.
- `pc.wowsbuilds.com/ships/<slug>` giving a **different tier** than `wowsbuilds.com/ships/<slug>`
  for the same ship name is expected and confirms which site is which — Mahan is Legends tier V
  (`wowsbuilds.com`) vs. PC-game tier VII (`pc.wowsbuilds.com`). Treat a tier mismatch between the
  two domains as a same-name-different-game sanity check, not a data conflict to resolve.
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
- **Any `wiki.wargaming.net/en/Navy:*` page** can return a JS/cookie-challenge stub ("Loading site
  please wait...") to both WebFetch and plain `curl` with a browser UA — that's a bot-check, not a
  sign the page is gone, and it's intermittent (the same URL can pass or fail run to run). Route it
  through the Jina reader proxy instead: `curl -L "https://r.jina.ai/https://wiki.wargaming.net/en/Navy:<Page>"`
  returns clean markdown with the real content, breadcrumb included. Confirmed working this way for
  `Navy:Maps` (own "Legends Maps" header, `Legends_Thumbnail_*`/`Legends_OW_*` image names; has
  size, tier range, battle modes, and a description for every map, good first stop for a
  `wows-map` pass) and for ship pages like `Navy:Provorny` (breadcrumb "Homepage / WoWS Legends /
  Provorny"; full stats/consumables/modules/Pros-Cons tables came through, all matching
  `wowsbuilds.com` independently).

## Bad sources — do not use, even for "obviously identical" values

- `wiki.worldofwarships.com` and `wiki.wargaming.net/en/Ship:*` — original PC/Steam game wiki.
- `pc.wowsbuilds.com` — the PC-game version of wowsbuilds.
- `wowsb.fandom.com` ("WoWS Blitz Wiki") — a third, separate mobile game.
- General real-world naval-history sites (Wikipedia ship-class articles, historyofwar.org,
  naval-encyclopedia.com, destroyerhistory.org, warfarehistorynetwork.com,
  laststandonzombieisland.com) — for **gameplay data** (turret counts, arrangement, stats). Fine
  as a source for a real-ship reference **photo** only, via Commons — see above.
- `en.namu.wiki` — 403s to WebFetch.
- `wows-gamer-blog.com` — covers the original PC game despite reading as generic "WoWs" content
  (WGC/PTS/Coal-container references are PC-specific). Confirmed on Provorny: same hull, but a
  different tier (VIII vs. Legends' VII), different release date, and several stats that disagree
  with `wowsbuilds`/`Navy:` (e.g. 6.2s rudder shift and 7.9 km sea detection vs. the Legends-correct
  4.7s/7.1 km) even though other fields (HP, armor range, torpedo layout) happened to match. A
  source partially agreeing with confirmed Legends numbers is not evidence the rest of it is safe
  to use — cross-check every field, not just a sample.
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
  tier VII). This is a general pattern, not a hard rule: Danae (tier III British cruiser) has a
  confirmed Slot 1 on its own `Navy:` page (Main Battery Mod 2 / Aiming Systems Mod 1). Trust the
  ship's own sourced modifications table over the general tier guideline when they disagree.
- **A superlative claim ("thinnest armor of any tier I cruiser," "fastest reload at tier I") must
  be checked against the full real roster for that tier/class via `Navy:All_Ships`, not just the
  ships already in this site's `src/content/ships/`.** Confirmed wrong twice this way: Novik's
  "thinnest armor of any tier I cruiser" (actually mid-pack — Gryf/Hércules/Júpiter all run 10mm
  max vs. Novik's 50mm) and Dresden's "fastest reload at tier I" (Gryf 3.4s and Hércules 3.5s both
  beat Dresden's 4.0s). There are 12 tier I cruisers total in Legends (Albany, Chikuma, Weymouth,
  Dresden, Jurien, Novik, plus Nino Bixio/Italy, Gryf/Pan-Europe, Shi An/Pan-Asia,
  Hércules/Pan-America, Gelderland/Netherlands, Júpiter/Pan-America) — this site only has 6 of them
  as of 2026-07-23. **Never phrase the fix as "...in this DB/fleet" or "...on this site" either**
  — a reader has no idea what "this site" has or hasn't covered, so that phrasing is meaningless
  to them even when the underlying comparison is honest (a prior version of this file endorsed it;
  Hyūga's and Dresden's detail paragraphs used it before being rewritten). Instead name the actual
  peer ship(s) the claim is checked against directly ("beats New Mexico's 15.8 km, New York's
  14.0 km, and König's 13.9 km" instead of "longest range of any tier IV-V battleship in this
  DB") — concrete, checkable by the reader, and reads like normal prose instead of a meta note
  about the database.
- Confirmed-good additional `Navy:` pages beyond the original launch roster: `Navy:Nino_Bixio`,
  `Navy:Gryf`, `Navy:Shi_An`, `Navy:Hércules`, `Navy:Gelderland`, `Navy:Júpiter` (tier I cruisers),
  `Navy:Wakeful`, `Navy:V-170`, `Navy:Izyaslav`, `Navy:Bourrasque`, `Navy:Turbine`,
  `Navy:Klas_Horn`, `Navy:Shenyang`, `Navy:G-101` (tier III destroyers), `Navy:Le_Terrible`,
  `Navy:Le_Hardi` (tier VI French destroyers), `Navy:Jaguar` (tier IV French destroyer, direct
  `curl` worked fine, no Jina proxy needed that run), and `Navy:Galicia` (tier IV Spanish cruiser,
  reached via the Jina proxy after the direct fetch returned only nav-chrome with no page body) —
  all confirmed via breadcrumb, useful for peer-comparison research even for nations not yet on
  the site.
- **A Commons ship-name category can silently mix two unrelated vessels sharing a name** —
  `Category:Jaguar (ship, 1928)` contains both the French Chacal-class destroyer Jaguar (completed
  1926, this site's ship) and an unrelated German Kriegsmarine Type 24 "Raubtier-class" torpedo
  boat also named Jaguar (commissioned 1928). A CC-BY-SA-licensed Bundesarchiv file in that same
  category looked like a fine pick until its own description read "Torpedoboote Typ 24,
  'Raubtier-Klasse'" — wrong navy. Always read the file's own caption/description for nation and
  hull type before trusting a category-page or filename match, especially for common ship names
  reused across navies.
- `Spain` wasn't in the site's `nation` enum before Galicia — added as a one-line change to
  `src/content.config.ts` plus a flag entry in `src/lib/nations.ts` (🇪🇸), no component assumed a
  fixed nation list.
- A premium ship's consumables are worth diffing against its closest tech-tree sibling even when
  the consumable name matches exactly (same duration/cooldown can still hide a weaker magnitude,
  e.g. a smaller speed bonus on Engine Boost) — confirmed on Le Terrible vs Le Hardi.
- A ship's own "Player Opinion" prose can contradict its own stat table on the same page — trust
  the hard number over the blurb.
- `torpedoMounts`' `spreadPattern`/`firingSector`/`singleTubeFire` fields are rarely confirmable
  from available sources — leave unset rather than guess.
- Upgrade slot **count doesn't scale cleanly with tier, even within one nation/class** — confirmed
  on Mahan (tier V USN destroyer): only 2 slots (`Navy:Mahan` and `wowsbuilds.com/ships/mahan/
  modifications` agree independently), fewer than tier IV Farragut's 3 and tier III Clemson's 3.
  Trust the ship's own sourced modifications table every time, don't infer from neighboring tiers
  in the line.
- A ship's turret/torpedo layout can mix standard and restricted mounts in ways no source
  describes in prose — Mahan's midship turret (3 of 5) is centerline but arc-restricted to
  port/starboard only (can't fire bow or stern), confirmed by asking the user rather than any
  written source or splash art. Don't assume a centerline turret gets the usual 3-of-4 arcs.
- A "Variant" ship (reuses another ship's hull/turret/torpedo arrangement) — fetch the base ship's
  `Navy:` page too, both for layout corroboration and as a fallback Pros/Cons source if the
  variant's own page lacks one.
- A source that's usually reliable for one field can still have an isolated error on one ship
  (confirmed: wowsbuilds' gun count for Dresden). Cross-check its own field against other
  already-confirmed ships before trusting an outlier over a disagreeing source.
- Real ship history is out of scope for gameplay data, even when a detail "seems like it would
  obviously carry over" (turret count, arrangement, armament can all differ from history).
- **A ship already on the site can have stale stats if the live `Navy:` page has since changed**
  (balance patch). Confirmed on New York: current page's HP/detection/torpedo-reduction/upgrade-
  slot-count all disagree with `new-york.json`. When using an existing site ship as a peer-
  comparison baseline for a new ship, re-fetch its live `Navy:` page rather than trusting the
  checked-in file's numbers as ground truth. New York's file needs a re-verification pass.
- **`wowsbuilds.com/ships/<slug>/consumables` shows real slot grouping** (`SlotGrid_slot` /
  `id="slot-N-label"` markup) that the `Navy:` wiki page's flat consumable list doesn't — use it to
  tell whether several listed consumables are simultaneous or mutually-exclusive alternatives in
  one slot (confirmed on Nevada: 3 of her 5 listed consumables share one slot, only one is
  equippable at a time). **But this sub-page can itself be wrong for a specific ship** — Colorado's
  `/ships/colorado/consumables` listed only 3 slots (missing Catapult Fighter and Observation
  Seaplane entirely) and named an "Exhaust Smoke Generator" alternative, implausible for a US
  battleship and not mentioned anywhere on the `Navy:` page. Cross-checked against Nevada's already-
  confirmed pattern (a shared 3-way utility slot: Catapult Fighter / Observation Seaplane /
  Enhanced Secondary Targeting) instead, which matched Colorado's `Navy:` page consumable list
  exactly. When this sub-page's grouping looks structurally odd for the ship's class/nation, trust
  a same-nation sibling's already-verified slot pattern over it.
- Tier VI battleship peers confirmed via their own `Navy:` pages (useful for future tier VI BB
  peer-comparison, e.g. Colorado): Gneisenau (Germany), Sinop (USSR), King George V (UK), Lyon
  (France), Nagato (Japan), F. Caracciolo (Italy). Their tier V predecessors (also confirmed):
  Bayern, Izmail, Queen Elizabeth, Normandie, Fusō, Andrea Doria.
- **Spain has no tech-tree Battleship line in Legends yet** — `Navy:All_Ships` lists only one
  Spanish battleship, Victoria, a tier VIII premium. Don't assume every nation in the enum has a
  full tech-tree line at every tier; check `All_Ships` before treating an absence as a research gap.
- Tier V destroyer peers confirmed via their own `Navy:` pages (useful for future tier V DD
  peer-comparison): `Navy:Gnevny` (USSR), `Navy:Gallant` (UK), `Navy:Aviere` (Italy), plus
  `mahan.json` (USA, already on-site). All four fetched with a direct `curl` + browser UA, no Jina
  proxy needed that run — the bot-check stub is intermittent per-request, not a property of
  specific pages.
- A ship's "Community Contributions / Changes" changelog section can list a **stale value that
  contradicts the page's own current stats table** — Aviere's changelog says sea detection was
  "reduced from 7.1 to 6.8 km" in one patch, but the live Concealment table for the same page
  currently shows 7.8 km. Likely a later, undocumented patch moved it again. Trust the top-level
  current stats table over the changelog's before/after numbers when they disagree; the changelog
  records one historical patch, not necessarily the most recent one.
- When a user's in-game description of turret/torpedo order doesn't map cleanly onto the wiki's
  `AxB` arrangement notation, work out which grouping matches by total count rather than guessing
  position: Aviere's wiki page lists "1x1" and "2x2" for main battery (3 turrets, 5 guns total) and
  "2x3" for torpedoes (2 mounts, 6 tubes total) — both totals matched the user's 3-turret/2-mount
  description exactly, so the two 2-gun turrets were assigned to the fore/aft "3-way arc" positions
  and the 1-gun turret to the described amidships "broadsides only" slot.

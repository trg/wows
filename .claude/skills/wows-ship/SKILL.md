---
name: wows-ship
description: Research and create or update a World of Warships Legends ship entry in src/content/ships/. Use when the user wants to add a new ship to the companion site, or refresh an existing one after a balance patch.
allowed-tools: WebSearch, WebFetch, Read, Write, Edit, Bash(npm run check), Bash(curl:*), Bash(sips:*), Bash(mkdir:*)
---

Research and author (or refresh) one ship's data file for the companion site.

## Before you start

Read `SPEC.md` at the repo root — it is the authoritative schema and tone guide. Also read
`src/content.config.ts` for the exact Zod shape and `src/lib/goals.ts` for the fixed `goalTags`
taxonomy. Look at 1-2 existing files in `src/content/ships/` (e.g. `omaha.json`) as a concrete
reference for shape and voice.

## Procedure

1. **Identify the target.** Confirm the ship name, and whether this is a new entry or an update
   to an existing file (`src/content/ships/<slug>.json`, slug = kebab-case of the ship name). The
   schema's `nation` field is a fixed enum (currently `USA`, `Germany` — see
   `src/content.config.ts`), not a free string. If asked for a ship from a nation not yet in that
   enum, add it to the enum first (a one-line change) rather than forcing an existing value or
   inventing a workaround; check first whether any component assumes `nation === 'USA'` (none did
   as of the Germany addition, but re-check, don't assume that stays true).
2. **Research current data** via WebSearch/WebFetch. This site covers **World of Warships:
   Legends only** — a different game from the original PC/Steam *World of Warships*, with its own
   balance and values. **Never use `wiki.worldofwarships.com`, or the `wiki.wargaming.net/en/Ship:`
   namespace** (the original game's wiki, wrong game entirely). The `wiki.wargaming.net/en/Navy:`
   namespace on that same domain is a confirmed-good Legends-specific source — the two namespaces
   sit on the same host and are easy to mix up, so confirm any given URL via the page's own
   breadcrumb ("Homepage / WoWS Legends / ...") before trusting it. Check
   `.claude/skills/research-quickref.md` first for sources already known good or bad, and add to
   it with what you learn; the full narrative for any entry (or a genuinely new lesson worth the
   detail) goes in `.claude/skills/research-log.md`. Don't trust any other source you can't
   confirm is describing Legends specifically.
   Research hull HP, gun/torpedo stats, consumables, upgrade slots, and any
   legendary module. **Tier I ships have no upgrade slots at all** (the slot system starts at tier
   IV with 1 slot, scaling to 4 from tier VII on) — `upgrades: []` is correct there, not a gap in
   research. Also research physical layout for `turrets`/`torpedoMounts`: bow-to-stern
   turret order and which zones each can fire into, and whether each torpedo mount is centerline
   or fixed to one broadside. Written sources are often silent on this; official Legends ship
   splash art (see `.claude/skills/research-quickref.md`) can confirm turret/mount count and
   position when no text source describes it. **Splash art's standard bow-quartering camera angle
   reliably confirms only the forward turret cluster** (confirmed across every ship checked so
   far, from multiple hosts/resolutions) — the bridge/funnels structurally block the amidships and
   aft turrets from that angle, so don't burn research time hunting for a differently-framed
   splash image expecting it to solve this; treat "forward cluster only" as this source type's
   ceiling and move to the next step instead.
   `.claude/skills/research-quickref.md`'s source list is a leaderboard of what's paid off before,
   not an exhaustive whitelist — reach for other Legends-specific sites (search results, community
   wikis, build sites, forum posts) if something better turns up, and add it to the file with what
   kind of data it was good for. **Cap splash-art effort at one crop of the forward cluster.** Don't
   iterate on multiple crops chasing bow/stern orientation, amidships turret direction, or
   which-end-has-the-mast reasoning — that back-and-forth burns a lot of tokens and the art can't
   resolve it past the forward cluster anyway (see the ceiling note above). The moment layout goes
   beyond "confirm the forward pair," stop and ask the user instead of continuing to reason from the
   image. **Ask the user before defaulting to an empty array** — checking in-game (rotating the
   port-view camera, or watching train limits while aiming) is fast and reliable for them, faster
   than continued image forensics, and is their stated preference over spending tokens on it. Only
   fall back to leaving `turrets`/`torpedoMounts` empty if the user has no way to check either.
   Cross-check more than one source when values
   disagree, and check `.claude/skills/research-quickref.md` first for sources already known good
   or bad — update it with what you learn. Also research how each stat compares to peer ships at
   the same tier and class, since you'll need that to set `rating`. If you can't find a
   Legends-verified number for something, don't fill it in with a PC value — write the field
   qualitatively instead, or leave a note in your final summary that it needs a better source.
3. **Source a reference photo.** Try to find a real-world photo of the actual historical vessel
   for the `image` field — this is illustration, not gameplay data, so it's unrelated to the "real
   ship history is out of scope" rule in `research-quickref.md` (that rule is about stats/mechanics,
   not a photo). Search **Wikimedia Commons** (`commons.wikimedia.org`), not Wikipedia article
   pages — Commons only hosts media actually cleared for reuse, so licensing is easier to verify.
   - Find the ship's Commons category or file page (e.g. `Category:USS Albany (1899)`).
   - Open the specific file page and check its license template. Only use it if public domain
     (`PD-*` templates, e.g. `PD-USGov-Military-Navy`, `PD-old`) or Creative Commons
     (`CC-BY`/`CC-BY-SA`). Skip anything tagged fair use/non-free — not cleared for reuse off
     Wikipedia.
   - Fetch the actual file bytes via `https://commons.wikimedia.org/wiki/Special:FilePath/<File
     name>` (redirects straight to the media; `curl -L`), not the wiki page HTML.
   - Save to `public/images/ships/<slug>.jpg` (convert first if needed, e.g. `sips -s format jpeg
     in.png --out out.jpg`), and set `image: "/images/ships/<slug>.jpg"`. No manual cropping
     needed — the site squares it off with CSS (`object-fit: cover`) for thumbnails and shows it
     wide/uncropped on the ship's own page.
   - Set `imageCredit` to a short attribution line whenever the license isn't plain public
     domain/CC0 (e.g. `"Photo: Jane Doe, CC BY-SA 4.0, via Wikimedia Commons"`). Fine to add one
     for public-domain images too (e.g. `"US Navy, public domain"`), just not required.
   - If no clearly-licensed photo of the *right* hull exists (obscure ships, or a name shared by
     multiple real vessels across eras), leave `image`/`imageCredit` unset rather than guess or use
     a fair-use image.
4. **Draft the JSON** matching the schema in `src/content.config.ts` exactly. In particular:
   - `isPremium` — set `true` if the ship is a premium/reward hull (bought or earned outside the
     tech tree), otherwise omit it (defaults `false`). This renders as a gold badge next to the
     class pill, so **never write "premium" into prose** (`shortDescription`, `role`,
     `playstyle`, `strengths`/`weaknesses`/`tips`, consumable `flavor`, etc.) — the badge is the
     only place that status shows up. If a ship's own identity depends on being non-tech-tree
     (e.g. a war-reparations hull, a fictional design), that's fine to describe factually without
     using the word "premium" itself.
   - `stats` is an array of `{ label, value, rating }` rows. Give each a `rating` of
     `strong | average | weak` relative to peers at the same tier and class, unless there's
     genuinely no useful comparison to make.
   - `consumables` is an array of `{ name, flavor, rating }`. Apply this test: could the line be
     pasted onto any other ship with the same consumable, unchanged? If yes, rewrite it. Never
     explain what the consumable type does or restate its mechanic in different words ("unlimited
     uses gated by a cooldown" is still a mechanic explainer, not ship-specific flavor). Look up
     the actual numbers for *this ship* (lay/action time, screen or heal duration, radius,
     cooldown, charge count, hp/s, speed or range bonus) and lead with them — a comparative phrase
     ("longest dissipation of any early destroyer smoke") is good when the raw number alone isn't
     meaningful. See `SPEC.md`'s consumables section for a bad/good example before writing these.
     If a consumable is genuinely stock and undifferentiated at this bracket, say so in one clause,
     don't pad it.
   - `turrets` is main battery turrets **in physical bow-to-stern order** (array order is the
     diagram order for `FiringArcDiagram`). `arcs` lists the zones (`bow`/`stern`/`port`/`starboard`)
     the turret can actually hit, not which it's blocked from. Most turrets cover 3 of 4 (blocked
     only opposite their mount), but confirm precisely rather than assuming — amidships or unusual
     mounts can be far more restricted (New York's turret 3 needs a full broadside, only
     `port`/`starboard`). Use `note` for a real sourced detail like that, not filler. Leave the
     array empty (default) rather than guess if you can't confirm the layout. **This is
     all-or-nothing per ship, not turret-by-turret**: writing only the turrets you did confirm
     (e.g. 2 of 5) actively misplaces them instead of just being incomplete — don't write a
     partial array. If research (including asking the user, see step 2) can't confirm every
     turret, leave the whole array empty and say so in your final summary, don't bury the gap
     only in `research-log.md`.
     - `position` (`'centerline' | 'port' | 'starboard'`, default `'centerline'`) tells the
       diagram which side of the hull to draw the turret marker on. Leave it unset for standard
       turreted mounts that can traverse to fire from the centerline — the vast majority of
       ships. Only set `'port'`/`'starboard'` for casemate-style mounts physically fixed to one
       broadside (this usually lines up with an `arcs` that's `['port']` or `['starboard']`
       only, but set it deliberately rather than inferring one from the other — they're separate
       fields). `FiringArcDiagram.astro` lines up turrets sharing the same occurrence index
       within their side (1st `port` with 1st `starboard`, 2nd with 2nd, ...) on the same
       fore-aft line, and gives each `centerline` turret its own line, in bow-to-stern array
       order — so when researching a casemate ship, also confirm *which* fore-aft line each
       port/starboard mount sits on (i.e. which port mount is roughly level with which starboard
       mount), not just which side it's on, or turrets will pair with the wrong line. See
       `chikuma.json`/`weymouth.json` for a worked example (8 single mounts: centerline bow,
       three port/starboard pairs, centerline stern). The diagram only draws the wedge for zones
       actually in `arcs` (no dashed "blocked" wedge anymore), so there's no need to worry about
       wedge overlap when a turret is offset to one side.
   - `torpedoMounts` is the same idea for torpedo tubes. `side: 'centerline'` (can fire either
     broadside, player's choice per launch) vs `'port'`/`'starboard'` (fixed to that side only) is
     a real, meaningful difference — Clemson's four mounts are all centerline, Omaha's are fixed
     per-broadside, and this changes how the ship plays. The optional `firingSector` (qualitative
     train-limit vs. peers), `spreadPattern` (narrow/wide salvo-dispersion degrees, set both or
     neither), and `singleTubeFire` (mostly a British-line mechanic) fields are frequently
     unconfirmable from available sources — see the "Torpedo mount detail fields" section of
     `.claude/skills/research-log.md` before spending too long chasing them, and leave a field
     unset rather than guess if no source gives a real number. Empty array (default) for ships
     without torpedoes or without confirmed data yet.
     - `FiringArcDiagram.astro` reuses the turret pairing scheme here too, keyed off `side`
       directly (no extra field needed, unlike turrets' `position`): a `port`/`starboard` mount is
       offset toward that side of the hull, and pairs with the same-occurrence mount on the
       opposite side (1st `port` with 1st `starboard`, 2nd with 2nd, ...) on a shared fore-aft
       line — so when researching a ship like Omaha, confirm which port mount is roughly level
       with which starboard mount, not just the side each is on. Every mount always draws a solid
       firing-sector wedge (no arrow), sized by `firingSector` when confirmed or a default average
       span when it's not — there's no empty/unconfirmed state for the wedge the way `arcs` has
       for turrets, so don't worry about leaving it "blank."
   - `image`/`imageCredit` — set from step 3's research if a licensed photo was found; leave both
     unset otherwise (cards fall back to a class icon, and the detail page just skips the banner).
   - `playstyle.summary` is an array of short bullet lines (tactical-briefing voice), not one
     paragraph — however many distinct points the ship earns, no fixed count. It describes the
     ship's *identity* (what it is, how it behaves), never instructions. If a line could sit in
     `tips` unchanged, it's misplaced — move it there or rewrite it as identity, not action.
     `playstyle.detail` is a fuller paragraph (naval/thematic voice).
   - `tips` uses the friendly-clanmate voice and is the only field that tells the player what to
     *do*. Cross-check against `playstyle.summary` before finishing: the two must not restate the
     same point in different words.
   - No field needs to land on exactly 3 bullets. `strengths`, `weaknesses`, `tips`,
     `playstyle.summary`, `threats` should each have as many non-redundant points as the ship
     actually earns, not a padded or trimmed round number.
   - Follow the "Writing like a person, not a model" checklist in `SPEC.md` for every prose field:
     no em dashes, no AI-vocabulary tics, no rule-of-three lists, no manufactured grandeur.
5. **Tag `goalTags` conservatively.** Only tag a category from `GOAL_TAGS` if the ship is
   genuinely notable for it, with a short `note` explaining why. It's fine for a ship to have zero
   or several tags.
6. **Never touch `captainsNotes`.** This field is hand-written by the site owner only. If it
   exists on a file you're updating, leave it exactly as-is. Don't add it to a new ship; omit the
   field entirely and let the owner add it later.
7. **Write the file** to `src/content/ships/<slug>.json`.
8. **Validate**: run `npm run check`. Fix any schema errors it reports before finishing.
9. Summarize what changed (new ship, or which fields were updated on an existing one, e.g. after a
   balance patch) in your final response.

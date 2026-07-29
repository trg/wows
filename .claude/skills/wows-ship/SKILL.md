---
name: wows-ship
description: Research and create or update a World of Warships Legends ship entry in src/content/ships/. Use when the user wants to add a new ship to the companion site, or refresh an existing one after a balance patch.
allowed-tools: WebSearch, WebFetch, Read, Write, Edit, Bash(npm run check), Bash(curl:*), Bash(sips:*), Bash(mkdir:*), Bash(.claude/skills/wows-ship/scripts/*.sh:*)
---

Research and author (or refresh) one ship's data file for the companion site.

## Before you start

`.claude/skills/wows-ship/scripts/` has three helper scripts that wrap the repetitive
curl/parsing steps research keeps needing — prefer these over hand-rolling the same `curl` +
Python one-liners again:

- `fetch-navy-page.sh <PageTitle>` — fetches a `wiki.wargaming.net/en/Navy:<PageTitle>` page,
  confirms the Legends breadcrumb (retrying via the Jina proxy if the direct fetch hits the bot
  stub), and prints clean plain text.
- `fetch-wowsbuilds.sh <slug> [base|consumables|modifications]` — fetches a `wowsbuilds.com`
  ship page. `base` prints the splash-art URL, the `peerStats` tier/class peer-group
  means/stdevs, and the ship's own parameters JSON; `consumables`/`modifications` print the
  slot-grouped readable text.
- `fetch-commons-image.sh "<Commons file name>" <output/path.jpg> [max-dimension]` — downloads a
  Commons file via `Special:FilePath` and resizes it to a normal web size (existing
  `public/images/ships/*.jpg` files run roughly 300KB-2MB; raw Commons originals can be far
  larger). Confirm the license on the file's Commons page yourself first — the script doesn't
  check it.

The two wiki-page scripts snapshot every successful fetch into a gitignored `scripts/.cache/`
directory as a last-resort fallback only, used when the live fetch fails outright (bot-check stub
with no Jina success, empty response) — never treated as equivalent to a fresh fetch, since a live
page can change after a balance patch. A fallback prints a loud age warning; treat that data as
provisional and re-fetch once the live page is reachable.

Read `SPEC.md` at the repo root — it is the authoritative schema and tone guide. Also read
`src/content.config.ts` for the exact Zod shape and `src/lib/goals.ts` for the fixed `goalTags`
taxonomy. Look at 1-2 existing files in `src/content/ships/` (e.g. `omaha.json`) as a concrete
reference for shape and voice.

## Procedure

1. **Identify the target.** Confirm the ship name and whether this is a new entry or an update to
   an existing file (`src/content/ships/<slug>.json`, slug = kebab-case of the name). `nation` is
   a fixed enum in `src/content.config.ts`, not a free string — if the ship's nation isn't listed
   yet, add it there and to the flag map in `src/lib/nations.ts` (a one-line change each) rather
   than forcing an existing value. Done repeatedly already (Japan, UK, France, USSR, Italy, Spain)
   with no component needing changes — see `research-quickref.md` for precedent.
2. **Research current data** via WebSearch/WebFetch. This site covers **World of Warships:
   Legends only**, a different game from the original PC/Steam *World of Warships* with its own
   balance and values — never use `wiki.worldofwarships.com` or the `wiki.wargaming.net/en/Ship:`
   namespace. **Read `.claude/skills/research-quickref.md` first**: it has the confirmed-good/bad
   source list, the splash-art ceiling (forward turret cluster only — cap effort at one crop,
   don't iterate chasing bow/stern orientation), the all-or-nothing rule for
   `turrets`/`torpedoMounts`, and other standing gotchas — don't re-derive what's already there.
   Its source list isn't an exhaustive whitelist; reach for other Legends-specific sites too and
   add what you learn. Put a full narrative writeup in `.claude/skills/research-log.md` only for
   something genuinely new.

   Research hull HP, gun/torpedo stats, consumables, upgrade slots (tier I has none —
   `upgrades: []` is correct there, not a gap), any legendary module, and physical turret/torpedo
   layout (bow-to-stern order, firing arcs, centerline vs. fixed-broadside). Once splash art hits
   its ceiling, **ask the user to confirm in-game** (port-view camera rotation, or train limits
   while aiming) rather than continuing image forensics or guessing — faster for them and their
   stated preference; only leave `turrets`/`torpedoMounts` empty if they have no way to check
   either. Cross-check sources when values disagree, and research peer ships at the same
   tier/class since you'll need that for `rating`. Never substitute a PC-game value for a missing
   Legends number — write the field qualitatively instead, or flag it in your final summary as
   needing a better source.
3. **Source a reference photo.** Find a real-world photo of the historical vessel for the `image`
   field via Wikimedia Commons, not Wikipedia article pages — see `research-quickref.md`'s Commons
   bullet for licensing/fetch details (PD-\*/CC-BY-SA only, fetch via `Special:FilePath`, watch for
   name-sharing conflicts between unrelated ships). This is illustration, not gameplay data, so
   it's unrelated to the "real ship history is out of scope" rule.
   - Save to `public/images/ships/<slug>.jpg` (convert first if needed, e.g. `sips -s format jpeg
     in.png --out out.jpg`), and set `image: "/images/ships/<slug>.jpg"`. No manual cropping
     needed — CSS handles thumbnail vs. full-page display.
   - Set `imageCredit` whenever the license isn't plain public domain/CC0 (e.g. `"Photo: Jane Doe,
     CC BY-SA 4.0, via Wikimedia Commons"`); fine to add for PD images too, just not required.
   - If no clearly-licensed photo of the *right* hull exists, leave `image`/`imageCredit` unset
     rather than guess or use a fair-use image.
4. **Draft the JSON** matching the schema in `src/content.config.ts` exactly. In particular:
   - `isPremium` — `true` for a premium/reward hull (bought or earned outside the tech tree),
     otherwise omit (defaults `false`). It renders as a gold badge next to the class pill, so
     **never write "premium" into prose** (`shortDescription`, `role`, `playstyle`,
     `strengths`/`weaknesses`/`tips`, consumable `flavor`) — the badge is the only place that
     status shows. Fine to describe a non-tech-tree ship's identity factually (war-reparations
     hull, fictional design) without using the word itself.
   - `stats` is an array of `{ label, value, rating }` rows. Give each a `rating` of
     `strong | average | weak` relative to peers at the same tier and class, unless there's
     genuinely no useful comparison to make.
   - `consumables` is an array of `{ name, flavor, rating }`. Pasteable-onto-any-other-ship test:
     if the line would work unchanged for any other ship with the same consumable, rewrite it —
     that includes restating the mechanic in different words ("unlimited uses gated by a cooldown"
     is still a mechanic explainer, not flavor). Lead with this ship's actual numbers (lay/action
     time, duration, radius, cooldown, charges, hp/s, bonus), adding a comparative phrase only when
     the raw number alone isn't meaningful. See `SPEC.md`'s consumables section for a bad/good
     example. If genuinely stock and undifferentiated at this bracket, say so in one clause, don't
     pad it.
   - `turrets` is main battery turrets **in physical bow-to-stern order** (array order = diagram
     order for `FiringArcDiagram`). `arcs` lists the zones (`bow`/`stern`/`port`/`starboard`) the
     turret can actually hit, not what blocks it. Most cover 3 of 4 (blocked only opposite their
     mount), but confirm rather than assume — amidships/unusual mounts can be far more restricted
     (New York's turret 3: only `port`/`starboard`). Use `note` for a real sourced detail like
     that, not filler. **All-or-nothing per ship** (see `research-quickref.md`) — leave the whole
     array empty rather than write a partial one, and say so in your final summary if research
     can't confirm every turret.
     - `position` (`'centerline' | 'port' | 'starboard'`, default `'centerline'`) tells the
       diagram which side of the hull to draw the marker on. Leave unset for standard traversing
       mounts; set explicitly only for casemate mounts fixed to one broadside (usually, but not
       automatically, paired with an `arcs` of just that side — they're independent fields, don't
       infer one from the other). `FiringArcDiagram.astro` pairs turrets by same-occurrence index
       within their side (1st `port` with 1st `starboard`, etc.) onto a shared fore-aft line, with
       each `centerline` turret on its own line, in bow-to-stern array order — so for a casemate
       ship, confirm *which* fore-aft line each port/starboard mount sits on, not just its side,
       or the diagram will pair the wrong turrets. See `chikuma.json`/`weymouth.json` for a worked
       example (8 single mounts: centerline bow, three port/starboard pairs, centerline stern).
       The diagram only draws a wedge for zones actually in `arcs`, so side-offset turrets don't
       need wedge-overlap handling.
   - `torpedoMounts` is the same idea for tubes. `side: 'centerline'` (either broadside, player's
     choice per launch) vs. `'port'`/`'starboard'` (fixed) is a real gameplay difference —
     Clemson's four mounts are centerline, Omaha's are fixed per-broadside. `firingSector`,
     `spreadPattern` (set both or neither), and `singleTubeFire` are rarely confirmable from
     available sources — see `research-log.md`'s "Torpedo mount detail fields" section before
     spending long chasing them; leave unset rather than guess. Empty array (default) if the ship
     has no torpedoes or no confirmed data.
     - Uses the same pairing scheme as `turrets` above, keyed off `side` directly. Every mount
       always draws a solid firing-sector wedge (no arrow), sized by `firingSector` when confirmed
       or a default span otherwise — no "blank" state to worry about here.
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

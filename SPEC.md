# SPEC — WoWS Legends Companion Site

Source of truth for the content schema, tone/voice, and architecture. Both human authors and the
`wows-ship` / `wows-map` Claude Skills should follow this document rather than duplicating these
rules elsewhere.

## Architecture

- **Astro**, static output (`output: 'static'`). No SSR adapter, no React/Vue/Tailwind.
- Content lives as **hand-authored JSON files** under `src/content/ships/*.json` and
  `src/content/maps/*.json`, validated against Zod schemas in `src/content.config.ts` (Astro
  Content Layer API, `glob` loader). Each file's slug (`id`) is its filename minus `.json`.
- Pages are generated at build time via `getStaticPaths` — see `src/pages/ships/[id].astro` and
  `src/pages/maps/[id].astro`.
- The **only** client-side JavaScript on the site is the inline `<script>` in
  `src/components/ShipSearch.astro` — a progressive-enhancement search/filter over already-static
  HTML. No framework, no hydration directives. Keep it that way; if a future feature seems to need
  more, that's a signal to reconsider the feature before reaching for a framework component.
- Run `npm run check` (`astro check`) before `npm run build` — this is how hand- or
  skill-authored JSON gets validated against the schema, since it isn't typed in an editor.

## Theming

All theme-relevant values are CSS custom properties in `:root` in `src/styles/global.css` — see
the doc comment at the top of that file for the authoritative, current list. Component `<style>`
blocks must reference these vars, never a hardcoded hex value. Dark/CRT is the only mode; there is
no light mode.

- **Surfaces** (`--color-bg`/`surface`/`surface-raised`/`border`): background layers, darkest to
  lightest, plus the shared border color.
- **Text** (`--color-text`/`text-muted`): body copy and de-emphasized text.
- **Accent** (`--color-accent`): headings, links, active nav state, and the glow color source.
- **Class colors** (`--color-dd`/`cruiser`/`bb`): per-ship-type color. Kept distinct rather than
  collapsed to monochrome so ship type stays scannable at a glance — this is also the "multi-trace"
  look (like a radar display with more than one signal color). Used for badges, the ship-class
  icons in `src/components/icons/`, and the torpedo firing-sector wedge in `FiringArcDiagram`.
- **Rating colors** (`--color-rating-strong`/`average`/`weak`): stat and consumable quality
  indicators, rendered as short colored descriptive text (e.g. "Strong for tier", "Average for
  tier"), not glyphs/symbols or SVGs.

### Typography

Two self-hosted, OFL-licensed monospace fonts (`public/fonts/*.woff2`, loaded via `@font-face` in
`global.css` — no CDN/external font requests):

- `--font-display` (`VT323`): h1/h2/h3, nav labels, badges/pills. Blocky bitmap-terminal
  character — use only where text is short and large.
- `--font-body` (`Share Tech Mono`): paragraphs, stat labels/values, list items, and any other
  long-form text. Still reads as terminal but stays legible at length.

`body` sets `--font-body` as the default; headings and `.badge` override to `--font-display`. When
adding a new component, default to `--font-body` unless the text is short, large, and
label/heading-like.

### Radius and borders

`--radius` is `0` — no rounded corners anywhere on the site. Every surface (`.card`, `.badge`,
thumbnails, etc.) is always bordered with `1px solid var(--color-border)`. Don't reintroduce
`border-radius` on new components.

### Glow

A faint global `text-shadow: 0 0 0.3px currentColor` on body text gives a soft phosphor-bleed look
without hurting legibility. A stronger accent glow (`text-shadow`/`box-shadow` using
`--color-accent`) is reserved for **emphasis and interactive states only**: headings, the active
nav link, link hover/focus, and card borders on hover/active. Don't apply the stronger glow to
ambient body text or add it to new elements by default — it marks emphasis, not decoration. There
is no scanline overlay or flicker/animation effect; keep it that way, this is a lookup tool used
mid-match and needs to read clean on a phone screen.

## Content Schema

### Ship (`src/content/ships/<slug>.json`)

See `src/content.config.ts` for the authoritative Zod schema. Field notes:

- `type` and `tier` render as **two separate pills**, not combined text (e.g. not "T3 Destroyer"
  as one badge — a `T3` pill and a `Destroyer` pill, side by side).
- `stats` is an **array of rows**, not a fixed object, so each ship can list whichever stats
  actually matter for it:
  ```
  stats: [{ label, value, rating? }]
  ```
  `rating` is `"strong" | "average" | "weak"`, judged relative to the ship's own tier and class
  (a destroyer's speed rating is relative to other destroyers around that tier, not to
  battleships). Omit `rating` only when there's genuinely no useful peer comparison to make (rare
  — most stats have one). This renders as small text under the value, not a separate column.
- `consumables` describes **flavor**, not mechanics:
  ```
  consumables: [{ name, flavor, rating? }]
  ```
  The test: would a player who already knows the game learn something ship-specific from this
  line, or could it be pasted onto any ship with the same consumable name unchanged? If the
  latter, it's not done yet. Don't explain what the consumable type does (no "puts out fires and
  floods," no "creates a smoke screen that blocks sight") — every reader already knows that part.
  Don't re-describe the mechanic in different words either ("unlimited uses gated by a cooldown"
  is still explaining what Damage Control Party *is*, not what *this ship's* version is like).
  Say only what's actually specific to this hull, as tight as possible, and back it with the real
  number when you have it (lay/action time, screen or heal duration, radius, cooldown, charge
  count, hp/s, speed or range bonus). A comparative phrase ("shortest cooldown of any destroyer
  class") is fine and often better than a bare number when the number alone isn't meaningful. If
  every ship at this consumable's bracket is genuinely identical, the whole entry can be as short
  as a fact plus a comparison, e.g. *"3 charges, 30s to lay, 160s cooldown — standard USN
  destroyer smoke."* If it's a stock, undifferentiated version with nothing to add, say that in
  one clause and move on, don't pad it into a full sentence of restated mechanics.
  - Bad: *"Lays a wide screen that lingers long enough to sit inside with a teammate instead of
    just running through it. Built for hiding, not for a quick getaway."* (explains what smoke
    generically does, no numbers, could describe any camping-style smoke on any nation)
  - Good: *"112s screen off a 30s lay, longest dissipation of any early destroyer smoke. Built to
    park a team in, not dash through."*
  `rating` (`strong | average | weak`) is how this specific consumable stacks up against peers at
  the tier, e.g. a smoke generator with a short duration and small radius is a weak escape tool
  even if having smoke at all is nominally a strength.
- `turrets` — main battery turrets, **listed in physical bow-to-stern order** (array order is the
  diagram order):
  ```
  turrets: [{ label, guns, arcs: ('bow' | 'stern' | 'port' | 'starboard')[], position?: 'centerline' | 'port' | 'starboard', note? }]
  ```
  `arcs` is which of the four zones the turret can actually fire into, not which it's blocked
  from — omit a zone rather than listing it as blocked. This powers the top-down
  `FiringArcDiagram` component. Most turrets cover 3 of the 4 zones (blocked only from the arc
  directly opposite their mount), but say so precisely rather than assuming — ships with
  amidships turrets or unusual layouts can be much more restricted (see New York's turret 3,
  which needs a full broadside and only covers `port`/`starboard`). Use `note` for a real,
  sourced detail like that, not filler. Leave the array empty (default) for ships without
  populated turret data yet, or when a source can't be confirmed.

  `position` defaults to `'centerline'` and only needs to be set for casemate-style mounts fixed
  to one broadside (e.g. Chikuma/Weymouth's 8x1 layouts). It places the turret's marker on that
  side of the hull in the diagram; turrets sharing the same occurrence index within their side
  (1st `port` with 1st `starboard`, 2nd with 2nd, ...) are drawn on the same fore-aft line, and
  each `centerline` turret gets its own line, in bow-to-stern array order.
- `torpedoMounts` — same idea for torpedo tubes, for ships that have them:
  ```
  torpedoMounts: [{ label, tubes, side: 'centerline' | 'port' | 'starboard', note? }]
  ```
  `side: 'centerline'` means the mount can fire to either broadside (the player picks per
  launch); `port`/`starboard` means it's fixed to that one side only. This is a real, meaningful
  difference between ships that both nominally "have torpedoes" and worth calling out. Empty
  array (default) for ships without torpedoes or without populated data yet.

  In the diagram, `port`/`starboard` mounts are offset toward that side of the hull, and pair
  with the same-occurrence mount on the opposite side (1st `port` with 1st `starboard`, ...) on
  a shared fore-aft line, the same scheme as `turrets`' `position` field — no separate field
  needed here since `side` already carries it. Each mount always draws a solid firing-sector
  wedge (no arrow), sized by `firingSector` when set or a default average span otherwise; there's
  no "no data" state for this, unlike `arcs` on turrets.
- `upgrades`, `threats` — arrays of short objects, not paragraphs.
- `strengths` / `weaknesses` / `tips` — short bullet strings. `tips` uses the **friendly-clanmate**
  voice (see Tone below) and is where *how to play* the ship lives: actions, decisions, sequencing
  ("smoke up the second you're spotted").
- `playstyle.summary` — an **array of short bullet lines** (not one paragraph), tactical-briefing
  voice, meant to be read in a few seconds in the game lobby. This describes what the ship *is* —
  its character, role, and how it behaves in a fight — not what to *do* with it. If a bullet here
  could sit in `tips` unchanged, it's in the wrong field; move it or rewrite it as identity rather
  than instruction. *"Slow, heavily armored, built to sit on a flank and grind"* is a summary line;
  *"Pick your spot early and commit"* is a tip.
- `playstyle.detail` — a fuller paragraph, **naval/thematic** voice.
- **List lengths are not fixed.** `strengths`, `weaknesses`, `tips`, `playstyle.summary`,
  `threats`, `goalTags` etc. don't need to land on 3 items — that's a side effect of past drafts,
  not a target. Use however many genuinely distinct, non-redundant points the ship earns; 2 is
  fine, 5 is fine, as long as none of them are filler.
- `goalTags` — array of `{ tag, note }` where `tag` is one of the fixed categories in
  `src/lib/goals.ts` (`GOAL_TAGS`). This is what powers the `/goals/` "Best Ships For..." lists —
  don't hand-maintain a separate list, just tag the ship. Add a category to `src/lib/goals.ts`
  only if an existing one genuinely doesn't fit; don't invent one-off tags per ship.
- `captainsNotes` — **freeform, hand-written by the site owner only.** Personal opinions and
  vibes about the ship, in first person. **Skills must never write, generate, or overwrite this
  field.** If it's already present on a ship being updated, leave it untouched.
- `image` / `imageCredit` — a real-world reference photo of the ship (the actual historical
  vessel, not in-game art), sourced from Wikimedia Commons by the `wows-ship` skill. Used as both
  the squared-off list-view thumbnail (CSS `object-fit: cover` handles the crop, no image editing
  needed) and a banner on the ship's own page. Only use images that are public domain or
  Creative Commons licensed for reuse — never a Wikipedia "fair use" file. `imageCredit` is a short
  attribution line, required whenever the license isn't plain public domain/CC0 (e.g. `"Photo:
  Jane Doe, CC BY-SA 4.0, via Wikimedia Commons"`); optional but fine to set for public-domain
  images too. Leave both unset if no clearly-licensed photo of the right hull exists.

### Map (`src/content/maps/<slug>.json`)

- `keyAreas` — a single unified list (not separate capture/camping/callout arrays) with a `type`
  of `capture-point | camping-spot | chokepoint | flank-route | open-water`.
- `strategyNotes` — team-level tactics, short bullets.

## Tone & Voice

Overall feel: **fun and approachable, not silly.** No/minimal emojis, no forced jokes, no
try-hard competitive-meta-guide dryness ("optimal DPM," min-max lecturing). Numbers belong in
`stats`, not prose.

- **`tips`** — friendly-clanmate voice. Casual, direct, like a teammate texting advice. Short
  sentences, contractions are fine. *"Smoke up the second you get spotted, don't try to out-brawl
  anything bigger."*
- **`playstyle.summary`** — tactical-briefing voice, as short bullets, describing the ship's
  identity and behavior, not instructions. *"Fast, fragile, hits well above her tier in a straight
  torpedo line."* Not *"Flank early, torp the choke"* — that's a tip.
- **`playstyle.detail`** — naval/thematic voice. A paragraph with some character, but still
  grounded and useful, not purple prose.
- **`captainsNotes`** — the site owner's own voice, whatever that is. Skills don't touch it.

### Writing like a person, not a model

All prose fields (`tips`, `playstyle.detail`, `consumables[].flavor`, map `description` and
`strategyNotes`) must read like a person wrote them, not an LLM. Concretely, avoid the patterns
documented at [Wikipedia:Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing):

- **No em dashes.** Use a period, comma, or just start a new sentence instead.
- **Don't dodge "is/are."** Skip "stands as," "serves as," "functions as," "represents," "marks" —
  just say what it is.
- **Skip the AI vocabulary tics:** boasts, showcases, underscores, testament to, crucial, pivotal,
  vital role, robust, meticulous, intricate, delve, garner, foster, enhance, align with, key
  (as filler), landscape (metaphorical), tapestry, vibrant, notably, additionally, moreover,
  furthermore.
- **No "not just X, but also Y" / "not X, but Y" / "X rather than Y" parallelism.** Say the thing
  once, plainly.
- **No rule-of-three lists** ("fast, agile, and deadly"). Pick the one or two things that actually
  matter instead of padding to three.
- **No manufactured grandeur.** Nothing "is a testament to" anything; nothing "plays a crucial role."
  A smoke generator is just a smoke generator, not a legacy.
- **Vary sentence length naturally**, including some short, blunt sentences. Don't make every
  sentence the same balanced length and shape.
- Straight quotes and apostrophes, not curly ones.

If a draft reads like a product description or a press release, rewrite it plainer.

- **No unverified superlatives, whatever they're scoped to.** Never write things like "the only
  other tier IV battleship on this site" or "quickest reset of any class on this site" — the
  site's current content coverage isn't game data and changes as ships get added. But rephrasing
  the same claim as "on this site" isn't the fix: "slowest DCP cycle of any ship class" or
  "fastest reset in the game" has the identical problem if it's really just describing every ship
  *researched so far*, not every ship in the game. Only make an absolute/game-wide superlative
  claim if a source actually supports comparing across the whole game; otherwise scope the claim
  to something checkable from the ship's own data (tier, nation, class at that tier) or drop the
  comparison and just state the number.

## Goal Categories (`src/lib/goals.ts`)

Fixed taxonomy powering `/goals/`: `fire-starter`, `torpedo-alpha`, `stealth-play`,
`tank-brawler`, `aa-defense`, `utility-support`. Each ship can carry zero or more, each with a
short `note` explaining *why* it earns the tag.

## Adding/Updating Content

Use the `wows-ship` and `wows-map` skills (`.claude/skills/`) — they research current in-game
values via web search, draft/update the JSON against this schema and tone guide, and run
`npm run check` before finishing. Manual edits are fine too; just follow the same schema and tone
rules, and never fabricate a `captainsNotes` entry.

**This site is *World of Warships: Legends* only.** It is a different game from *World of
Warships* (the original PC/Steam release) with its own balance and values, even though Legends now
also runs on PC — "console" vs. "PC" is shorthand for Legends vs. the original game, not a
statement about platform. `wiki.worldofwarships.com` (and its `wiki.wargaming.net` redirect) is the
wiki for the **original, non-Legends game and must not be used as a source**, including for values
that seem like they'd obviously be identical (hull counts, turret arrangement, etc.) — confirm
against a Legends-specific source instead. See `.claude/skills/research-sources.md` for sources
that have actually checked out as Legends-accurate.

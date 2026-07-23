# Retheme: 80s CRT terminal look

## Background

The site currently uses a generic dark UI: system font stack, blue/green/orange accents,
rounded corners, no custom icons. The owner wants to move away from that default toward a
distinctive look: an old green-phosphor computer terminal, like pulling up a ship's tactical
console mid-match. Dark mode only (already the case; no light mode exists or is wanted).

All theme-relevant values already live as CSS custom properties in `src/styles/global.css`, with
a handful of component-local `<style>` blocks that reference the same vars. A few hardcoded hex
values exist outside `global.css` and should be folded into the variable system as part of this
work (see "Cleanup" below) — partly because they're stragglers, partly because the owner asked
explicitly that colors/fonts stay tweakable via CSS variables going forward.

## Palette

All new/changed values live in `:root` in `global.css`. Class colors and rating colors are kept
(not collapsed to monochrome) so ship type and stat quality are still scannable at a glance —
this doubles as a "multi-trace" look, like a radar display with more than one signal color.

```
--color-bg:              #0a0f0b   /* near-black, faint green cast */
--color-surface:         #0f1912
--color-surface-raised:  #142219
--color-border:          #244a30   /* dim phosphor green, all borders, always 1px, never rounded */
--color-text:            #b8f0c4   /* soft phosphor green, body copy */
--color-text-muted:      #5f9873
--color-accent:          #39ff6a   /* bright phosphor green: headings, links, active states, glow source */

--color-dd:               #4fd9c4  /* cyan-green */
--color-cruiser:          #39ff6a  /* = accent */
--color-bb:                #ffb454  /* amber */

--color-rating-strong:   var(--color-accent)
--color-rating-average:  var(--color-text-muted)
--color-rating-weak:     #ff5f56   /* alert red */
```

`--radius` changes from `10px` to `0` — no rounded corners anywhere on the site.

## Typography

Two self-hosted, OFL-licensed monospace fonts, added as woff2 files under `public/fonts/` and
loaded via `@font-face` in `global.css` (no external/CDN requests, consistent with the site's
no-CDN-JS stance):

- `--font-display: 'VT323', monospace` — h1/h2/h3, nav labels, badges/pills. Authentic blocky
  bitmap-terminal character; used only where text is short and large.
- `--font-body: 'Share Tech Mono', monospace` — paragraphs, stat labels/values, list items.
  Still reads as terminal but stays legible for the long-form fields (`playstyle.detail`,
  `captainsNotes`, consumable flavor text).

`body` sets `--font-body` as the default; headings and `.badge` override to `--font-display`.

## CRT effect (subtle, not full retro)

- A faint global text blur via `text-shadow: 0 0 0.3px currentColor` on body text — soft
  phosphor-bleed look without hurting legibility.
- A stronger glow (`text-shadow` / `box-shadow` using `--color-accent`) reserved for: headings,
  the active nav link, links/hover states, and card borders on `:active`/hover. Not applied to
  every element — glow marks emphasis and interactivity, it isn't ambient.
- No scanline overlay texture, no flicker/animation. This is a lookup tool used mid-match; the
  effect should read as "terminal" instantly without adding noise on a phone screen.

## Icons

- New `src/components/icons/` directory: small single-stroke SVG hull silhouettes for
  Destroyer/Cruiser/Battleship, stroked in the matching class-accent color
  (`--color-dd`/`--color-cruiser`/`--color-bb`). Used in `TierTypePills` and the `ShipCard`
  thumbnail (replacing today's plain letter-in-a-box placeholder).
- Stat/consumable rating indicators stay as compact text glyphs (▲ strong / ▶ average / ▼ weak)
  colored via the `--color-rating-*` vars, not SVGs — matches the terminal-native feel and needs
  no new assets.
- `public/favicon.svg` redrawn to match: a simple terminal/crosshair glyph in
  `--color-accent`-equivalent green on the near-black background, replacing the current blue
  circle-with-figure icon.

## Cleanup: fold stray hex values into variables

Currently hardcoded outside `global.css`, all representing the same "weak rating" red — replace
with `var(--color-rating-weak)`:
- `src/components/StatGrid.astro:63`
- `src/pages/ships/[id].astro:161`
- `src/components/KeyAreaList.astro:61` (`--color-warn`-equivalent use for the chokepoint badge;
  confirm visually whether this should be `--color-rating-weak` or its own semantic var if its
  meaning turns out to be distinct from "weak stat" — likely fine to share.)

`src/components/FiringArcDiagram.astro:227,229` has `var(--color-cruiser, #6ab0de)` — the
hardcoded fallback becomes stale once `--color-cruiser` changes; drop the fallback now that the
var is always defined.

## Documentation for future agents/skills

- New **"Theming"** section in `SPEC.md`, alongside the existing Architecture section, covering:
  the CSS variable groups above (surface/text/accent/class/rating), the display-vs-body font
  split and when to use which, the radius-0 + always-bordered convention, and the glow-usage rule
  (headings/interactive elements only, never ambient body text). Purpose: so a future component
  or the `wows-ship`/`wows-map` skills don't reintroduce a hardcoded hex or a rounded corner.
- A short comment block at the top of `global.css`'s `:root` listing what each variable group is
  for, as an in-file quick reference next to the values themselves.

## Files touched

- `src/styles/global.css` — palette, fonts, radius, glow tokens, `@font-face`, doc comment.
- `public/fonts/*.woff2` — new, self-hosted VT323 + Share Tech Mono.
- `public/favicon.svg` — redrawn.
- `src/components/icons/*.astro` — new ship-class SVGs.
- `src/components/TierTypePills.astro`, `ShipCard.astro`, `KeyAreaList.astro`, `StatGrid.astro`,
  `FiringArcDiagram.astro`, `src/pages/ships/[id].astro` — swap hardcoded hex for vars, wire in
  class icons where noted above.
- `src/layouts/BaseLayout.astro` — add font preload/`@font-face` hookup if not fully handled by
  the `global.css` import alone.
- `SPEC.md` — new Theming section.

## Out of scope

- No light mode — dark/CRT is the only mode, as explicitly requested.
- No changes to page structure, routing, or the search island's behavior — this is a visual
  retheme only, no new client JS.
- No scanline/flicker animation (considered and explicitly declined in favor of a subtler,
  more usable effect).
- Ship/map content JSON is untouched; this only touches presentation layer files listed above.

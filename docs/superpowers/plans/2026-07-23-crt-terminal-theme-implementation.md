# CRT Terminal Retheme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Retheme the site from its generic dark UI to an 80s green-phosphor CRT terminal look, per
`docs/superpowers/specs/2026-07-23-crt-terminal-theme-design.md`.

**Architecture:** All theme values are CSS custom properties in `src/styles/global.css`; component
`<style>` blocks consume the same vars. This plan rewrites the token set in `global.css`, adds two
self-hosted fonts, folds stray hardcoded hex values into vars, adds three new ship-class icon
components, redraws the favicon, and documents the system in `SPEC.md`.

**Tech Stack:** Astro 7 (static output), plain CSS custom properties, no framework, no new client
JS.

**Note on verification:** This repo has no unit test suite. The correctness gate is `npm run
build` (runs `astro check` — Zod content validation — then the static build) after every task.
Tasks that change visible output also require a visual check via the dev server, since `astro
check`/`build` do not catch a wrong color or a missing glow.

## Global Constraints

- Dark/CRT is the only mode — no light mode, none is wanted.
- `--radius` is `0` everywhere — no rounded corners anywhere on the site.
- No scanline overlay texture, no flicker/animation.
- No new client-side JavaScript; the only JS island remains `ShipSearch.astro`.
- Fonts are self-hosted under `public/fonts/*.woff2`, loaded via `@font-face` — no CDN/external
  font requests at runtime.
- `src/content/ships/*.json` and `src/content/maps/*.json` are untouched by this work.
- `captainsNotes` on ship entries must never be generated or overwritten (not touched by this
  plan, but `src/pages/ships/[id].astro` is edited — do not touch that field or its rendering
  logic beyond the noted hex-var swap).
- Run `npm run build` after every task; it must exit 0 before moving on.

---

### Task 1: Self-host the two CRT terminal fonts

**Files:**
- Create: `public/fonts/vt323.woff2`
- Create: `public/fonts/share-tech-mono.woff2`

**Interfaces:**
- Produces: two font files at fixed paths that Task 2's `@font-face` rules point to
  (`/fonts/vt323.woff2`, `/fonts/share-tech-mono.woff2`).

Both are OFL-licensed, served from Google Fonts' static CDN (`fonts.gstatic.com`) as the
underlying asset host — downloading a copy once here, not linking to it at runtime, satisfies the
"self-hosted, no CDN request" requirement. Using the "latin" subset is sufficient; all site content
is English.

- [ ] **Step 1: Create the fonts directory and download both files**

```bash
mkdir -p public/fonts
curl -sL -o public/fonts/vt323.woff2 \
  "https://fonts.gstatic.com/s/vt323/v18/pxiKyp0ihIEF2isfFJU.woff2"
curl -sL -o public/fonts/share-tech-mono.woff2 \
  "https://fonts.gstatic.com/s/sharetechmono/v16/J7aHnp1uDWRBEqV98dVQztYldFcLowEF.woff2"
```

- [ ] **Step 2: Verify both are valid woff2 files**

Run: `file public/fonts/*.woff2`
Expected:
```
public/fonts/share-tech-mono.woff2: Web Open Font Format (Version 2), TrueType, length 13500, version 1.0
public/fonts/vt323.woff2:            Web Open Font Format (Version 2), TrueType, length 17936, version 1.0
```

- [ ] **Step 3: Commit**

```bash
git add public/fonts/vt323.woff2 public/fonts/share-tech-mono.woff2
git commit -m "Add self-hosted VT323 and Share Tech Mono fonts"
```

---

### Task 2: Rewrite `global.css` — palette, fonts, radius, and CRT glow

This is the core retheme task. It replaces the entire token set and base rules in one pass because
palette, typography, and glow all live in the same `:root`/base-rule block in the same file —
splitting it across tasks would mean three partial rewrites of the same ~120-line file.

**Files:**
- Modify: `src/styles/global.css` (full rewrite)
- Modify: `src/layouts/BaseLayout.astro` (font preload)

**Interfaces:**
- Produces: `--color-bg`, `--color-surface`, `--color-surface-raised`, `--color-border`,
  `--color-text`, `--color-text-muted`, `--color-accent`, `--color-dd`, `--color-cruiser`,
  `--color-bb`, `--color-rating-strong`, `--color-rating-average`, `--color-rating-weak`,
  `--font-display`, `--font-body`, `--radius: 0` — all consumed by Task 3's hex-to-var swaps and
  by every existing component `<style>` block (unchanged references, new values).

- [ ] **Step 1: Replace `src/styles/global.css` in full**

```css
/*
 * Theme tokens for the CRT terminal look. Groups:
 *   - Surfaces (--color-bg/surface/surface-raised/border): background layers, darkest to
 *     lightest, plus the shared border color (always 1px, never rounded).
 *   - Text (--color-text/text-muted): body copy and de-emphasized text.
 *   - Accent (--color-accent): headings, links, active states, and the glow color source.
 *   - Class colors (--color-dd/cruiser/bb): per-ship-type color, doubles as a "multi-trace"
 *     signal color (radar-style) across badges, icons, and diagrams.
 *   - Rating colors (--color-rating-strong/average/weak): stat and consumable quality.
 *   - Fonts (--font-display/--font-body): see the Theming section in SPEC.md for which to use
 *     where.
 */
:root {
  --color-bg: #0a0f0b;
  --color-surface: #0f1912;
  --color-surface-raised: #142219;
  --color-border: #244a30;
  --color-text: #b8f0c4;
  --color-text-muted: #5f9873;
  --color-accent: #39ff6a;

  --color-dd: #4fd9c4;
  --color-cruiser: #39ff6a;
  --color-bb: #ffb454;

  --color-rating-strong: var(--color-accent);
  --color-rating-average: var(--color-text-muted);
  --color-rating-weak: #ff5f56;

  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-5: 1.5rem;
  --space-6: 2rem;
  --radius: 0;
  --nav-height: 60px;

  --font-display: 'VT323', monospace;
  --font-body: 'Share Tech Mono', monospace;
}

@font-face {
  font-family: 'VT323';
  font-style: normal;
  font-weight: 400;
  font-display: swap;
  src: url('/fonts/vt323.woff2') format('woff2');
}

@font-face {
  font-family: 'Share Tech Mono';
  font-style: normal;
  font-weight: 400;
  font-display: swap;
  src: url('/fonts/share-tech-mono.woff2') format('woff2');
}

* {
  box-sizing: border-box;
}

html {
  -webkit-text-size-adjust: 100%;
}

body {
  margin: 0;
  background: var(--color-bg);
  color: var(--color-text);
  font-family: var(--font-body);
  line-height: 1.5;
  padding-bottom: calc(var(--nav-height) + var(--space-4));
  text-shadow: 0 0 0.3px currentColor;
}

h1, h2, h3 {
  font-family: var(--font-display);
  line-height: 1.25;
  margin: 0 0 var(--space-3);
  text-shadow: 0 0 6px var(--color-accent);
}

p {
  margin: 0 0 var(--space-3);
}

a {
  color: inherit;
  text-decoration: none;
}

a:hover,
a:focus-visible {
  text-shadow: 0 0 6px currentColor;
}

ul {
  margin: 0;
  padding-left: 1.1em;
}

li + li {
  margin-top: var(--space-2);
}

main {
  max-width: 720px;
  margin: 0 auto;
  padding: var(--space-4);
}

.badge {
  display: inline-block;
  font-family: var(--font-display);
  padding: 0.15em 0.6em;
  border-radius: var(--radius);
  font-size: 0.75rem;
  font-weight: 600;
  letter-spacing: 0.02em;
  background: var(--color-surface-raised);
  border: 1px solid var(--color-border);
}

.badge--Destroyer { color: var(--color-dd); border-color: var(--color-dd); }
.badge--Cruiser { color: var(--color-cruiser); border-color: var(--color-cruiser); }
.badge--Battleship { color: var(--color-bb); border-color: var(--color-bb); }

.card {
  display: block;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  padding: var(--space-4);
  margin-bottom: var(--space-3);
}

.card[hidden] {
  display: none;
}

.card:hover,
.card:active {
  background: var(--color-surface-raised);
  border-color: var(--color-accent);
  box-shadow: 0 0 8px var(--color-accent);
}

.section {
  margin-bottom: var(--space-6);
}

.section h2 {
  font-size: 1.05rem;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--color-text-muted);
}

.back-link {
  display: block;
  margin-bottom: var(--space-4);
  color: var(--color-accent);
  font-size: 0.9rem;
}

@media (min-width: 640px) {
  main {
    padding: var(--space-6);
  }
}
```

- [ ] **Step 2: Add font preload hints to `BaseLayout.astro`**

In `src/layouts/BaseLayout.astro`, in the `<head>`, add preload links right after the `<meta
name="description">` line and before the favicon `<link>`:

```astro
    <link
      rel="preload"
      href="/fonts/vt323.woff2"
      as="font"
      type="font/woff2"
      crossorigin
    />
    <link
      rel="preload"
      href="/fonts/share-tech-mono.woff2"
      as="font"
      type="font/woff2"
      crossorigin
    />
```

- [ ] **Step 3: Build and confirm no errors**

Run: `npm run build`
Expected: exits 0, `astro check` reports 0 errors, static build completes.

- [ ] **Step 4: Visual spot-check**

```bash
astro dev --background
```

Open `http://localhost:4321/` in a browser (or use the project's `run` skill) and confirm: near-black
background with a green cast, phosphor-green body text, blocky VT323 headings, square (non-rounded)
cards and badges, a faint glow on the "WoWS Legends Companion" `<h1>`.

- [ ] **Step 5: Commit**

```bash
git add src/styles/global.css src/layouts/BaseLayout.astro
git commit -m "Retheme to CRT terminal palette, fonts, and glow"
```

---

### Task 3: Fold stray hardcoded hex values into CSS variables

**Files:**
- Modify: `src/components/StatGrid.astro:63`
- Modify: `src/pages/ships/[id].astro:161`
- Modify: `src/components/KeyAreaList.astro:61`
- Modify: `src/components/FiringArcDiagram.astro:227,229`

**Interfaces:**
- Consumes: `--color-rating-weak`, `--color-cruiser` from Task 2's `global.css` `:root`.

All four instances represent the same "weak rating" red, now `var(--color-rating-weak)`
(`#ff5f56`) from Task 2 — same red family as the old hardcoded `#e07070`, so no separate semantic
var is needed for the `KeyAreaList` chokepoint badge either (confirmed visually in Task 3 Step 5:
both readings are "this is a hazard," consistent to share the same token).

- [ ] **Step 1: `StatGrid.astro`**

In `src/components/StatGrid.astro`, change:
```css
  .stat-grid__rating--weak { color: #e07070; }
```
to:
```css
  .stat-grid__rating--weak { color: var(--color-rating-weak); }
```

- [ ] **Step 2: `ships/[id].astro`**

In `src/pages/ships/[id].astro`, change:
```css
  .consumable-rating--weak { color: #e07070; }
```
to:
```css
  .consumable-rating--weak { color: var(--color-rating-weak); }
```

- [ ] **Step 3: `KeyAreaList.astro`**

In `src/components/KeyAreaList.astro`, change:
```css
  .key-areas__badge--chokepoint { color: #e07070; border-color: #e07070; }
```
to:
```css
  .key-areas__badge--chokepoint { color: var(--color-rating-weak); border-color: var(--color-rating-weak); }
```

- [ ] **Step 4: `FiringArcDiagram.astro`**

In `src/components/FiringArcDiagram.astro`, change both occurrences (drop the now-stale fallback):
```css
  .sector-wedge {
    fill: var(--color-cruiser, #6ab0de);
    fill-opacity: 0.18;
    stroke: var(--color-cruiser, #6ab0de);
    stroke-opacity: 0.5;
    stroke-width: 1;
  }
```
to:
```css
  .sector-wedge {
    fill: var(--color-cruiser);
    fill-opacity: 0.18;
    stroke: var(--color-cruiser);
    stroke-opacity: 0.5;
    stroke-width: 1;
  }
```

- [ ] **Step 5: Build, grep, and visually confirm**

Run: `npm run build`
Expected: exits 0.

Run: `grep -rnE "#[0-9a-fA-F]{3,6}" src --include="*.astro" --include="*.css" | grep -v global.css`
Expected: no output (no stray hex left outside `global.css`).

Open a ship page with a `weak`-rated stat/consumable and a map page with a chokepoint key area in
the browser; confirm both still read as red/alert-colored, and the torpedo firing-sector wedge on a
ship with `torpedoMounts` still renders in the cruiser-green tone.

- [ ] **Step 6: Commit**

```bash
git add src/components/StatGrid.astro src/pages/ships/\[id\].astro \
  src/components/KeyAreaList.astro src/components/FiringArcDiagram.astro
git commit -m "Fold stray hardcoded hex colors into CSS variables"
```

---

### Task 4: Ship-class SVG icons

**Files:**
- Create: `src/components/icons/DestroyerIcon.astro`
- Create: `src/components/icons/CruiserIcon.astro`
- Create: `src/components/icons/BattleshipIcon.astro`
- Modify: `src/components/TierTypePills.astro`
- Modify: `src/components/ShipCard.astro`

**Interfaces:**
- Produces: three Astro components, each accepting an optional `class?: string` prop and
  rendering a `<svg viewBox="0 0 24 24">` with `stroke="currentColor"` (no fill) — color is set by
  whatever wraps them, matching the existing `.badge--<Type>` / `.ship-card__thumb--<Type>`
  pattern.
- Consumes (in `TierTypePills.astro` and `ShipCard.astro`): the ship `type` prop
  (`'Destroyer' | 'Cruiser' | 'Battleship'`), used to select which icon component to render.

Each icon is a single-stroke top-down/profile hull silhouette, visually distinct at small (badge)
size: Destroyer is low and slender with one mast line, Cruiser is a mid hull with one
superstructure block, Battleship is a long hull with two turret blocks flanking a tall bridge.

- [ ] **Step 1: Create `src/components/icons/DestroyerIcon.astro`**

```astro
---
interface Props {
  class?: string;
}

const { class: className } = Astro.props;
---

<svg
  class={className}
  viewBox="0 0 24 24"
  fill="none"
  stroke="currentColor"
  stroke-width="1.5"
  stroke-linecap="round"
  stroke-linejoin="round"
  aria-hidden="true"
>
  <path d="M2 15 L5 15 L7 11 L19 11 L22 15 L19 16.5 L5 16.5 Z" />
  <line x1="11" y1="11" x2="11" y2="7" />
</svg>
```

- [ ] **Step 2: Create `src/components/icons/CruiserIcon.astro`**

```astro
---
interface Props {
  class?: string;
}

const { class: className } = Astro.props;
---

<svg
  class={className}
  viewBox="0 0 24 24"
  fill="none"
  stroke="currentColor"
  stroke-width="1.5"
  stroke-linecap="round"
  stroke-linejoin="round"
  aria-hidden="true"
>
  <path d="M2 16 L5 16 L6 12 L18 12 L19 16 L22 16 L20 18 L4 18 Z" />
  <rect x="9" y="7" width="6" height="5" />
</svg>
```

- [ ] **Step 3: Create `src/components/icons/BattleshipIcon.astro`**

```astro
---
interface Props {
  class?: string;
}

const { class: className } = Astro.props;
---

<svg
  class={className}
  viewBox="0 0 24 24"
  fill="none"
  stroke="currentColor"
  stroke-width="1.5"
  stroke-linecap="round"
  stroke-linejoin="round"
  aria-hidden="true"
>
  <path d="M1 15 L3 15 L4 11 L20 11 L23 15 L20 17 L4 17 Z" />
  <rect x="5" y="8" width="3" height="3" />
  <rect x="16" y="8" width="3" height="3" />
  <rect x="10" y="5" width="4" height="6" />
</svg>
```

- [ ] **Step 4: Wire icons into `TierTypePills.astro`**

Replace the full contents of `src/components/TierTypePills.astro` with:

```astro
---
import DestroyerIcon from './icons/DestroyerIcon.astro';
import CruiserIcon from './icons/CruiserIcon.astro';
import BattleshipIcon from './icons/BattleshipIcon.astro';

interface Props {
  type: 'Destroyer' | 'Cruiser' | 'Battleship';
  tier: number;
}

const { type, tier } = Astro.props;

const ICONS = {
  Destroyer: DestroyerIcon,
  Cruiser: CruiserIcon,
  Battleship: BattleshipIcon,
};

const Icon = ICONS[type];
---

<span class="pills">
  <span class="badge badge--tier">T{tier}</span>
  <span class={`badge badge--${type}`}>
    <Icon class="pills__icon" />
    {type}
  </span>
</span>

<style>
  .pills {
    display: inline-flex;
    gap: var(--space-2);
  }

  .badge--tier {
    color: var(--color-text-muted);
  }

  .pills__icon {
    width: 0.9em;
    height: 0.9em;
    vertical-align: -0.1em;
    margin-right: 0.3em;
  }
</style>
```

- [ ] **Step 5: Wire icons into `ShipCard.astro`**

Replace the full contents of `src/components/ShipCard.astro` with:

```astro
---
import TierTypePills from './TierTypePills.astro';
import DestroyerIcon from './icons/DestroyerIcon.astro';
import CruiserIcon from './icons/CruiserIcon.astro';
import BattleshipIcon from './icons/BattleshipIcon.astro';

interface Props {
  id: string;
  name: string;
  type: 'Destroyer' | 'Cruiser' | 'Battleship';
  tier: number;
  shortDescription: string;
  image?: string;
}

const { id, name, type, tier, shortDescription, image } = Astro.props;

const ICONS = {
  Destroyer: DestroyerIcon,
  Cruiser: CruiserIcon,
  Battleship: BattleshipIcon,
};

const Icon = ICONS[type];
---

<a
  href={`/ships/${id}/`}
  class="card ship-card"
  data-name={name.toLowerCase()}
  data-type={type.toLowerCase()}
  data-tier={tier}
>
  <div class="ship-card__row">
    <div class={`ship-card__thumb ship-card__thumb--${type}`}>
      {image ? <img src={image} alt="" loading="lazy" /> : <Icon class="ship-card__thumb-icon" />}
    </div>
    <div class="ship-card__body">
      <div class="ship-card__title">
        <TierTypePills type={type} tier={tier} />
      </div>
      <h3>{name}</h3>
      <p>{shortDescription}</p>
    </div>
  </div>
</a>

<style>
  .ship-card__row {
    display: flex;
    gap: var(--space-4);
  }

  .ship-card__thumb {
    flex: none;
    width: 56px;
    height: 56px;
    border-radius: var(--radius);
    background: var(--color-surface-raised);
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    color: var(--color-text-muted);
    overflow: hidden;
  }

  .ship-card__thumb img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .ship-card__thumb-icon {
    width: 60%;
    height: 60%;
  }

  .ship-card__thumb--Destroyer { color: var(--color-dd); }
  .ship-card__thumb--Cruiser { color: var(--color-cruiser); }
  .ship-card__thumb--Battleship { color: var(--color-bb); }

  .ship-card__title {
    margin-bottom: var(--space-2);
  }

  .ship-card h3 {
    margin: 0 0 var(--space-1);
    font-size: 1.05rem;
  }

  .ship-card p {
    margin: 0;
    color: var(--color-text-muted);
    font-size: 0.9rem;
  }
</style>
```

- [ ] **Step 6: Build and visually confirm**

Run: `npm run build`
Expected: exits 0.

Open `/ships/` in the browser: every type badge in the pills shows a small class-colored hull icon
next to the type label, and every ship card without an `image` shows the matching icon (in the
class color) in its thumbnail instead of a plain letter.

- [ ] **Step 7: Commit**

```bash
git add src/components/icons/ src/components/TierTypePills.astro src/components/ShipCard.astro
git commit -m "Add ship-class hull icons to type pills and ship card thumbnails"
```

---

### Task 5: Redraw the favicon

**Files:**
- Modify: `public/favicon.svg`

**Interfaces:** none (standalone static asset).

- [ ] **Step 1: Replace `public/favicon.svg`**

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128">
  <rect x="0" y="0" width="128" height="128" fill="#0a0f0b" />
  <g fill="none" stroke="#39ff6a" stroke-width="6">
    <circle cx="64" cy="64" r="34" />
    <line x1="64" y1="14" x2="64" y2="34" />
    <line x1="64" y1="94" x2="64" y2="114" />
    <line x1="14" y1="64" x2="34" y2="64" />
    <line x1="94" y1="64" x2="114" y2="64" />
    <circle cx="64" cy="64" r="4" fill="#39ff6a" stroke="none" />
  </g>
</svg>
```

This is a crosshair/target glyph — `--color-accent`-equivalent green (`#39ff6a`) on the
`--color-bg`-equivalent near-black (`#0a0f0b`) background, matching the design spec's "terminal /
crosshair glyph" description. Colors are inlined literally here (not `var(...)`) because favicons
are requested standalone by the browser, outside any page's CSS context.

- [ ] **Step 2: Build and visually confirm**

Run: `npm run build`
Expected: exits 0.

Open the dev server in a browser tab and check the tab's favicon: a green crosshair/target on a
near-black square, replacing the old blue circle-with-figure icon.

- [ ] **Step 3: Commit**

```bash
git add public/favicon.svg
git commit -m "Redraw favicon as a green terminal crosshair glyph"
```

---

### Task 6: Document the theme system in `SPEC.md`

**Files:**
- Modify: `SPEC.md`

**Interfaces:** none (documentation only).

- [ ] **Step 1: Add a "Theming" section**

In `SPEC.md`, insert a new section immediately after the `## Architecture` section (before `##
Content Schema`):

```markdown
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
  indicators, rendered as text glyphs (▲/▶/▼), not SVGs.

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
```

- [ ] **Step 2: Build**

Run: `npm run build`
Expected: exits 0 (documentation-only change, but confirms nothing else broke).

- [ ] **Step 3: Commit**

```bash
git add SPEC.md
git commit -m "Document the CRT theming system in SPEC.md"
```

---

### Task 7: Full visual QA pass

**Files:** none (verification only; may produce small follow-up fixes to files touched in Tasks
2-5 if something reads wrong).

**Interfaces:** none.

- [ ] **Step 1: Start the dev server**

```bash
astro dev --background
```

- [ ] **Step 2: Walk every page type**

Using a browser (or the project's `run` skill), open and check each of:

- `/` — home page: h1 glow, three home-link cards square with visible borders, VT323 on card
  headings, body text in Share Tech Mono.
- `/ships/` — search input (still functional — type a ship name/type/tier and confirm filtering
  still works, since this is the one page with client JS), ship cards with class icons in
  thumbnails (for ships with no `image`), type pills showing icon + label.
- `/ships/<some-id>/` — a ship detail page with `turrets` and/or `torpedoMounts` populated: firing
  arc diagram renders, torpedo sector wedge (if present) is cruiser-green, stat grid `weak` rating
  reads red, consumable `weak` rating (if any ship has one) reads red.
- `/maps/` and `/maps/<some-id>/` — map card, key area list with a `chokepoint` type badge reading
  red.
- `/goals/` — goal category lists render with the new palette/fonts.
- `/404` (a nonexistent path) — still renders the not-found page correctly themed.

- [ ] **Step 3: Confirm the constraints held**

- No rounded corners anywhere (`--radius: 0` applied consistently).
- No scanline texture or flicker/animation anywhere.
- Favicon shows the new green crosshair in the browser tab.
- `grep -rn "border-radius" src --include="*.astro" --include="*.css"` shows only `var(--radius)`
  references, no literal px/percentage values.

Run: `grep -rn "border-radius" src --include="*.astro" --include="*.css"`
Expected: every match uses `var(--radius)`.

- [ ] **Step 4: Final build gate**

Run: `npm run build`
Expected: exits 0.

- [ ] **Step 5: Stop the dev server**

```bash
astro dev stop
```

No commit for this task unless Step 2/3 surfaces a fix — if so, make the fix in the relevant file
from Tasks 2-5, re-run Steps 3-4, then commit that fix on its own with a message describing what
was wrong (e.g. "Fix chokepoint badge glow contrast").

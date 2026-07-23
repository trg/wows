# Torpedo mount details: firing sector, spread toggle, single-tube fire

## Background

The TODO item asked for "an SVG and data about the torpedoes, the same way we have the one about
the main battery," plus relative-to-tier-and-class stat info, plus attributes for unusually
wide/narrow torpedo spread and single-tube firing.

Investigation showed most of this already exists: `FiringArcDiagram.astro` already draws torpedo
mounts on the same top-down hull diagram as the main battery (arrows for centerline/port/starboard
mounts), and the `stats` array already carries Torpedo Range/Damage with `strong/average/weak`
ratings for the three ships that currently have torpedoes (Clemson, Farragut, Omaha).

Three real gaps remain, refined through discussion with the site owner:

1. **Firing sector** — how far forward/aft a torpedo mount can physically train before the hull or
   superstructure blocks it. Not currently tracked at all; conflated during initial design with
   torpedo salvo dispersion, which is a different mechanic (see next point).
2. **Spread toggle** — a player-selectable choice, before firing, between a narrow or wide
   dispersion pattern for the torpedoes in that salvo. Distinct from firing sector. Each mode is a
   real number of degrees between the leftmost and rightmost torpedo in the salvo, and both numbers
   vary by ship/mount (e.g. one ship might be 10 degrees narrow / 30 wide, another 20 / 40) — this
   isn't a plain yes/no capability flag, it's a pair of ship-specific values. Likely hard to source
   for every mount; omit when not readily available rather than guessing.
3. **Single-tube fire** — some mounts let the player fire individual tubes instead of the full
   salvo at once.
4. **Torpedo speed** as a rated stat — no schema change needed, just a data gap (fits the existing
   `stats` array).

## Schema changes

`src/content.config.ts`, `torpedoMounts` array gains three new optional fields:

```ts
torpedoMounts: z.array(
  z.object({
    label: z.string(),
    tubes: z.string(),
    side: z.enum(['centerline', 'port', 'starboard']),
    firingSector: z.enum(['narrow', 'average', 'wide']).optional(),
    spreadPattern: z.object({
      narrowDeg: z.number().positive(),
      wideDeg: z.number().positive(),
    }).optional(),
    singleTubeFire: z.boolean().optional(),
    note: z.string().optional(),
  })
).default([]),
```

- `firingSector` — qualitative, relative to peer mounts of the same type/tier (same convention as
  `stats[].rating`), not exact degrees. Omit only when genuinely unresearched. Real degree numbers,
  when a source actually states them, go in the existing `note` field (e.g. "trains 40 degrees off
  either bow before the hull blocks it").
- `spreadPattern` — present only if the mount has a real in-game narrow/wide toggle *and* both
  degree values are sourced; `narrowDeg`/`wideDeg` are the angle between the leftmost and
  rightmost torpedo in that mode's salvo. Both fields or neither — a toggle with only one value
  confirmed isn't useful data. Omit entirely if unresearched or the mount has no toggle at all.
- `singleTubeFire` — true if the mount can fire individual tubes instead of the full salvo.
- All three are optional and additive; existing ship files with none of them set continue to
  validate and render exactly as today (single solid line, no wedge).

## Diagram changes (`FiringArcDiagram.astro`)

- Each active side of a torpedo mount (port and/or starboard, depending on `side`) gets a filled
  wedge centered on the beam (90 degrees off bow for starboard, 270 for port), sized by
  `firingSector`: narrow ~= 40 degrees total, average ~= 90 degrees, wide ~= 140 degrees. This
  mirrors the existing main-battery zone-wedge visual language but uses its own color/opacity so
  the two aren't confused, and only appears when `firingSector` is set (absent = today's plain
  arrow with no wedge).
- The existing directional line + arrowhead is drawn on top of the wedge, unchanged in position.
  It becomes **dashed** instead of solid when `singleTubeFire` is true.
- `spreadPattern` gets no new SVG shape (it's a per-launch player choice, not a fixed physical
  trait of the mount's position) — it only adds a legend-text clause with the actual numbers.
- Legend text gains clauses for whichever fields are set on a given mount, e.g.:
  > Torpedo Mount 1 (4 tubes): fires to either side, narrow firing sector, spread toggle 10°
  > narrow / 30° wide.

## Data backfill

Research and fill `firingSector` (+ `spreadPattern` degrees and/or `singleTubeFire` where actually
true/known) for the three ships that currently have torpedoes: Clemson, Farragut, Omaha. Follow the
same Legends-only sourcing rules as the rest of the site (see
`.claude/skills/research-sources.md`); if a value can't be confirmed from a Legends-specific
source, leave that field unset rather than guessing. `spreadPattern` in particular may not be
documented anywhere for Legends specifically — it's fine for it to end up unset on some or all
mounts if the degree numbers aren't findable.

Also add a "Torpedo Speed" row to `stats` for those same three ships, with a `strong/average/weak`
rating relative to peer destroyers/cruisers at the same tier.

## Out of scope

- No change to how `side` (centerline/port/starboard) works — it's still the coarse "which
  broadside(s)" field, `firingSector` is a separate, finer-grained detail layered on top.
- `firingSector` has no exact-degree requirement — qualitative rating only, real degrees are
  opportunistic detail in `note`. `spreadPattern` is the one field that's exact-degrees-or-nothing.
- Ships without torpedoes are unaffected; this doesn't touch the main-battery arc rendering.

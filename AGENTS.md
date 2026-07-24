## Project notes

This is the WoWS Legends Companion site. **Read `SPEC.md` first** — it's the source of truth for
the content schema, tone/voice rules, and architecture decisions. Don't duplicate schema or tone
rules here; update `SPEC.md` instead and keep this file to process/environment notes.

## Commands

| Command         | Action                                              |
| :--------------- | :--------------------------------------------------- |
| `npm install`    | Install dependencies                                |
| `npm run dev`    | Start local dev server at `localhost:4321`           |
| `npm run check`  | Validate content JSON against the schema (`astro check`) |
| `npm run build`  | Type-check (`check`), then build static site to `./dist/` |
| `npm run preview`| Preview the production build locally                |

There is no test suite or lint script in this repo; `npm run check` (Zod schema validation via
`astro check`) is the only correctness gate, and CI-equivalent is `npm run build`.

- **This site covers *World of Warships: Legends* only** — a different game from *World of
  Warships* (the original PC/Steam game), with its own balance, tiering, and consumable values,
  even though Legends is now also playable on PC. "Console version" and "PC version" are loose
  shorthand people use for Legends vs. the original game, not a statement about platform. When
  researching content, sources for the original *World of Warships* (its wiki at
  wiki.worldofwarships.com, most build sites) are NOT authoritative for Legends and may actively
  disagree with it — treat them only as a rough approximation pending a Legends-specific source,
  and say so in the data if a number is unverified. See `.claude/skills/research-quickref.md` for
  which sources have actually turned out to be Legends-accurate so far (full narrative detail in
  `.claude/skills/research-log.md`).
- Content lives in `src/content/ships/*.json` and `src/content/maps/*.json`, validated by
  `src/content.config.ts` (note: not `src/content/config.ts` — Astro 6+ moved this to
  `src/content.config.ts`, one level up from where older docs/tutorials show it).
- Run `npm run check` after editing any content JSON or the schema. It won't type-check in an
  editor otherwise, and `npm run build` runs it automatically first.
- Adding/updating a ship or map: use the `wows-ship` / `wows-map` skills in `.claude/skills/`
  rather than hand-writing JSON from scratch, so research and tone stay consistent.
- `captainsNotes` on ship entries is hand-written by the site owner only. Never generate, fill in,
  or overwrite it.
- Runtime is managed via **asdf**, not a global/Homebrew Node install — see `.tool-versions`.
  Don't install another Node via Homebrew even if `node`/`npm` seem missing in a fresh shell; the
  asdf shims just need to be on `PATH` (`$HOME/.asdf/shims`). Never install other system tools
  without asking first.
- Keep the client-side JS surface to the one search island in `ShipSearch.astro`. If a new feature
  seems to need more JS than that, treat it as a signal to reconsider the feature, not to reach for
  a framework.

## Deployment

Push to `main` and GitHub Actions builds and publishes to GitHub Pages — that's the whole deploy,
no manual step exists. Run `scripts/deploy.sh` from a clean `main` to build locally first (catches
failures before they're pushed) and watch the Actions run; see the README's Deployment section for
details. Never force-push or bypass the pre-flight build without telling the user first.

## Development

When starting the dev server, use background mode:

```
astro dev --background
```

Manage the background server with `astro dev stop`, `astro dev status`, and `astro dev logs`.

## Documentation

Full documentation: https://docs.astro.build

Consult these guides before working on related tasks:

- [Adding pages, dynamic routes, or middleware](https://docs.astro.build/en/guides/routing/)
- [Working with Astro components](https://docs.astro.build/en/basics/astro-components/)
- [Using React, Vue, Svelte, or other framework components](https://docs.astro.build/en/guides/framework-components/)
- [Adding or managing content](https://docs.astro.build/en/guides/content-collections/)
- [Adding styles or using Tailwind](https://docs.astro.build/en/guides/styling/)
- [Supporting multiple languages](https://docs.astro.build/en/guides/internationalization/)

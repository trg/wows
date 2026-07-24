# Research log (internal notes, not site content)

Narrative case log of ship/map research passes — how each finding was confirmed, exact quotes,
dead ends, and the lessons that came out of them. Not linked from the site or `SPEC.md`.

**For the compact source good/bad list and gotcha bullets, check `research-quickref.md` first.**
Come here when it doesn't cover your specific case, or when you want the full story behind a rule.
Add a new section here when a research pass produces a genuinely new lesson worth the narrative
detail; add a straightforward new good/bad source to `research-quickref.md` instead.

This site covers **World of Warships: Legends only** — a different game from the original
PC/Steam *World of Warships*, with its own balance and values.

## Resolved: full re-verification pass (all 5 ships)

All five ships originally launched with PC-wiki-sourced data have now been re-verified against
`Navy:` pages and corrected. Notable findings for future reference:

- **Tiers were wrong across the board, in different directions.** Clemson II→III, Farragut V→IV,
  Omaha V→IV, New York III→IV. New Mexico's V was already correct. Confirmed via each ship's own
  `Navy:` page tier field plus cross-check against `Navy:All_Ships`'s tech tree ordering. Don't
  assume a ship's tier carries over from the PC game or from an earlier draft — check it
  explicitly, it's one of the easiest things to get wrong silently since the ship still "makes
  sense" at the wrong tier.
- **Torpedo/gun counts can differ substantially, not just cosmetically**, from PC-game intuition:
  Clemson is 4x3 torpedo tubes (12 total) not 2x3; Omaha is an 8x1 + 2x2 152mm mixed
  casemate/turret arrangement (12 guns) not a uniform 10x1, and her torpedoes are 4x2/4x3 fixed
  per-broadside mounts (no centerline swing), the opposite of Clemson's centerline tubes.
- Omaha's Sonar and Catapult Fighter consumables replaced a previously-invented Repair Party and
  Defensive AA Fire that don't exist on her in Legends at all (a plausible-sounding but fabricated
  loadout from the original PC-wiki-based pass).

Every ship's `stats`, `consumables`, `turrets`, and (where applicable) `torpedoMounts` are now
sourced from `Navy:` pages. Remaining soft spots: Omaha's deck armor thickness (only an overall
"6-76mm" range confirmed, no deck-specific number), and some `rating` calls where peer-comparison
data at the corrected tier is thin (marked conservatively as "average").

## Tier I ships have no upgrade slots

Confirmed via `Navy:Albany` (no "Slot 1/2/3" section, just a single non-slotted "Fire Control"
hull-tied module, Mk1 mod. 2, +10% range) and corroborated by general search: the slot-based
upgrade system in Legends starts at tier IV (1 slot), scaling up to 4 slots from tier VII on.
`upgrades: []` is correct for any tier I ship, not a sign of missing research.

## Splash art can show a second bow-like structure at the far end that isn't the bow

Checked for Albany: the crop at the image's far edge (opposite the main close-up bow) showed
another raised deck with a jackstaff, railings, and what reads as a gun barrel, easy to mistake for
a confirmed stern gun mount. Given the well-established pattern that these splash arts don't
reliably show the stern (rigging/masts obscure it, per the Clemson/Farragut note above), treat a
lone stern-end crop that merely *resembles* the bow shot as inconclusive, not confirmation. For
Albany's 6x1 152mm battery, the art clearly confirmed one bow-mounted single gun and one hull-side
casemate near it, but not enough to reconstruct all 6 gun positions bow-to-stern with confidence,
so `turrets` was left empty rather than guessed. If a future pass finds a text source (not just
art) describing the casemate count/split, revisit.

## First non-US ship (König, Germany): schema + sourcing notes

`nation` was `z.literal('USA')` until König; extended to `z.enum(['USA', 'Germany'])` in
`src/content.config.ts`. No component assumed `nation === 'USA'` at the time (checked via grep
before extending) so this was a one-line change, not a refactor — re-check that's still true
before assuming it stays a one-liner as more nations get added.

The `Navy:<Ship_Name>` page pattern holds for non-US ships too (confirmed for `Navy:König`,
breadcrumb "Homepage / WoWS Legends"), including the same ship-trait callouts (e.g. König's own
page explicitly labels her "Modest Guns" and "Superior HE pen" as named traits) which are good
direct sourcing for `strengths`/`weaknesses` prose — better than inferring from raw numbers alone.
`wowsbuilds.com/ships/<slug>` also worked as a second tier-confirmation source for a German ship
(slug `konig`, no umlaut, matching the file's own kebab-case slug convention).

König's own `Navy:` page includes a design-rationale line ("arranged in a more rational manner
that allowed the ship to fire a broadside with all main battery guns") comparing her turret layout
to her Kaiser-class predecessor. This is genuine Legends-wiki text about this specific ship, not
real-world-history substitution, but it's a general design statement, not a per-turret arc
breakdown — resist the pull to reconstruct the classic 5-turret bow/amidships/stern arc pattern
from real dreadnought knowledge just because it rhymes with what the text implies. Splash art for
König (`konig.webp`) clearly confirmed only the two forward superfiring turrets; the amidships and
aft turrets were never visible (obscured past the bridge/funnels, same pattern as every other ship
checked so far). Left `turrets: []` initially — **later confirmed directly by the user in-game**
(see the "ask the user" entry below) and filled in: turrets 1/2 forward and 4/5 aft each cover
bow-or-stern plus both broadsides, turret 3 (amidships, between the funnels) is restricted to
`port`/`starboard` only, same narrow-arc pattern as New York's turret 3. So the real layout did
turn out to match the classic dreadnought pattern here — the point isn't that real-world knowledge
is always wrong, it's that it isn't a *citable source* for this site without in-game or wiki
confirmation, and in this case that confirmation came from the user, not a document.

**Player Opinion Pros/Cons sections on `Navy:` pages are useful, terse, ready-made
strength/weakness signal** — e.g. König's listed "Decent top speed / Good HP pool / Better than
average secondary batteries" as Pros and "Poor rudder shift time / Poor torpedo damage reduction /
Mediocre dispersion" as Cons directly matched and confirmed the numeric stats already pulled from
the table, and gave a fast way to decide `rating` values without needing an external peer-ship
comparison for every stat.

**Reference photo (schema's `image` field) may not exist for every ship, even famous ones.**
Checked Wikimedia Commons thoroughly for König (Battle of Jutland veteran, well-documented in
histories) and found no genuine photograph of her specifically — only a Royal Navy Intelligence
recognition drawing (`SMS Konig.jpg`, PD-UKGov/PD-US) and a couple of illustrations, which is also
what enwiki's own infobox uses for this ship. Used the recognition drawing as a fallback since it's
period-accurate documentation of the real vessel (not in-game art) with solid PD licensing, but
flagged this as a drawing-not-photo substitution in the summary rather than silently treating it as
equivalent to Albany's actual photograph — worth a second look if a real photo turns up later.

## König revisited: splash art is a source *type* ceiling, not a per-image gap — ask the user

Re-checked König's empty `turrets` array later and tried harder before concluding it was still
unconfirmable. Found a second, better splash-art source in the process:
**`https://wiki.wgcdn.co/images/<hash-path>/Legends_<Ship_Name>_splash.png`**, linked from the
ship's own `wiki.wargaming.net/en/Navy:<Ship_Name>` file description page (`File:Legends_..._splash.png`,
findable via the page's `<img>` tag). Older/archived resolutions of the same file live at
`.../images/archive/<hash-path>/<timestamp>%21Legends_<Ship_Name>_splash.png` — check the file
description page's history for multiple timestamps and grab the largest (König's went
325x183 → 422x249 → 573x322 across three revisions). This is a genuine in-game screenshot (ship
underway in a fjord port-background scene), not a cutout render, and can be higher-resolution or
differently cropped than the `wowsbuilds.com` splash art.

For König specifically, this didn't actually solve the gap: the official image uses the *same*
bow-quartering promotional camera angle as the `wowsbuilds.com` one, so it still only confirmed the
forward superfiring pair (turrets 1-2) and left turrets 3-5 hidden behind the bridge/funnels —
consistent with every other ship checked (Albany, Chikuma). **The takeaway isn't "check both
hosts," it's that this whole source type — official Legends splash/promo art, regardless of which
host serves it — is framed the same way and has the same blind spot.** Don't treat a
differently-hosted splash image as a fresh chance to see the stern; it won't be. Once the forward
cluster is confirmed and the rest isn't visible, that's the ceiling for this source type, full
stop — move on rather than re-fetching more splash art variants.

**Also, `research-sources.md`'s lists are a leaderboard, not a whitelist.** Nothing here stops a
research pass from using other Legends-specific sites (forum posts, community wikis, other build
sites) if something better turns up — the "Good" list just tracks what's already paid off so the
next pass doesn't re-discover it from scratch.

**When physical layout still can't be confirmed after exhausting reasonable sources, ask the
user instead of defaulting to an empty array.** The site owner may own the ship in-game and can
check the port-view camera or firing-arc train limits directly — faster and more authoritative
than continued web research, and it was the correct move here (this exact situation prompted the
user to say so explicitly). Only leave `turrets`/`torpedoMounts` empty if the user has no way to
check either.

## Torpedo mount detail fields (`firingSector`, `spreadPattern`, `singleTubeFire`)

- **`https://wiki.wargaming.net/en/Navy:Torpedoes`** is the general mechanics hub, useful for
  vocabulary and rough categories but has no per-ship numbers: confirms the narrow/wide spread
  toggle exists (button/trigger toggles between the two) and that single-tube fire is a real
  alternate mode, but explicitly "does not provide specific degree measurements" for either
  traverse limits or spread angle, for any ship.
- **Single-tube fire is a mostly-British mechanic** per that page: "Most British ships equipped
  with torpedoes as well as a few others in other nations instead have a choice between a narrow
  spread and firing torpedoes one at a time." None of Clemson/Farragut/Omaha (all USN) had this
  confirmed on their own `Navy:` pages, so `singleTubeFire` was left unset on all three rather than
  assumed false-by-omission or guessed true.
- **`spreadPattern` (narrow/wide degree pair) could not be sourced for any ship checked so far**
  (Clemson, Farragut, Omaha) — neither the per-ship `Navy:` pages nor the general mechanics page
  give exact angle numbers. Left unset; revisit if a source with per-mount numeric data turns up.
- Per-ship `Navy:` pages do list **Torpedo Speed** in their stock/upgraded module tables (e.g.
  Clemson 56 kt, Farragut 56/58 kt, Omaha 56 kt, Nicholas 56 kt, Wickes 48/56 kt) even when they
  don't cover firing sector or spread — good source for that stat specifically.
- **`firingSector` (qualitative train-limit rating) was only confirmed for Clemson** ("wide"),
  inferred from the already-sourced note that all four mounts traverse a full 180° — the widest
  category the general mechanics page describes ("can fire close to directly forwards to close to
  directly backwards"). Farragut (centerline, traverses to either broadside but no comparative
  detail found) and Omaha (fixed per-broadside, no centerline swing) had no comparative source for
  this field and were left unset rather than guessed.

## First British ship (Weymouth): schema notes, and a full-broadside splash art resolved via the user

`nation` extended to `z.enum(['USA', 'Germany', 'Japan', 'United Kingdom'])` in `src/content.config.ts`,
plus a `'United Kingdom': '🇬🇧'` entry in `src/lib/nations.ts`'s `NATION_FLAGS` (checked first, no
component assumed a fixed nation list, so still a two/one-line change). Note the wiki's own field
naming is inconsistent about this nation across namespaces on the same page: breadcrumb says
"British", the infobox's `Navy:` field says "UK", and its `Nation:` field says "United Kingdom" —
used the full `Nation:` field value for the enum to match the existing full-name style (`Germany`,
`Japan`), not the abbreviation.

Weymouth's `Navy:Weymouth` page (fetched raw via `curl`, not WebFetch's summarizer, since the
Modules/Consumables tables are exactly the kind of content research-sources.md already flags as
lossy through the summarizer) had unusually good direct-sourcing text: two named Ship Traits,
"Surgical Shells" (short fuse time, lower over-penetration chance) and "Flair for Piercing"
(equipped with AP shells only, no HE at all) — a real, load-bearing mechanical quirk for a tier I
cruiser, not flavor text. The Player Opinion Pros/Cons section explicitly confirmed this is
game-wide notable ("Only Tier I ship equipped with AP shells, making her able to overmatch and
citadel the other Tier I cruisers"), which is the kind of source-backed superlative SPEC.md's
tone rules do allow (contrast with an *inferred* superlative we can't back with a source).

**Splash art can be a full-broadside view (like Chikuma's) rather than the usual 3/4 bow-quarter
shot, and this one clearly showed 3 of the 8 single 152mm mounts** (one forecastle gun forward of
the bridge tower, two waist guns further aft along the visible side) via `sips` crops at
`https://<supabase-project>.supabase.co/storage/v1/object/public/ships/weymouth.webp`. Bow vs.
stern was disambiguated the same way as Chikuma: anchor hawsepipe rust streaks plus the breaking
bow wave were on the end with *less* rigging/mast prominence, not more — resist the instinct to
call the taller-masted end "the front." Even with 3 of 8 guns visually confirmed and a plausible
mirrored pattern, this was still **not enough to populate `turrets` alone** — the far broadside is
never visible in a broadside-framed splash shot, so per the standing all-or-nothing rule the right
move was to ask the user rather than guess the remaining 5.

**Asking the user resolved it in two short exchanges, faster than continued image forensics would
have.** First answer: "front and back are similar, essentially mirrors of each other" (checked via
in-game port view). That alone wasn't precise enough to write per-turret arcs, so a follow-up
question proposed the exact Chikuma-style split (1 bow gun bow+both-broadsides / 3 fixed-port waist
guns / 3 fixed-starboard waist guns / 1 stern gun stern+both-broadsides = 8 total) as a concrete
yes/no rather than an open-ended "what's the layout" — the user confirmed it matched exactly. A
specific, falsifiable proposed layout got a fast confirm where "what's the layout?" would likely
have needed more back-and-forth.

**Correction to the earlier Chikuma entry above:** that note says `turrets: []` was left empty
pending user confirmation. `chikuma.json` on disk now has the full 8-turret array (identical
1-bow/3-port/3-starboard/1-stern pattern used for Weymouth here) — the user must have confirmed it
in-game in a later pass that wasn't written back into this file. Don't trust this file's Chikuma
note as the current state of that ship's data; the actual JSON is authoritative. Worth remembering
that research-sources.md itself can drift stale relative to the content files it's meant to
support — if the two disagree, the content file wins.

## Dresden (German cruiser): wowsbuilds.com had a wrong gun count, Navy wiki was right

`Navy:Dresden`'s stat table stated "12x1" main battery arrangement twice (intro infobox and the
detailed module table), consistent both places. `wowsbuilds.com/ships/dresden`'s Overview tab
instead showed "105 mm 2x1" for Main Battery, and its own HE Alpha Strike figure (2,400) was
internally consistent with that wrong 2-gun count (2,400 = 2 x 1,200 HE Damage) rather than the
real 12. Cross-checked wowsbuilds' own Main Battery field convention against Weymouth and Chikuma
(both correctly showed "8x1" there, matching their confirmed real counts), which ruled out "this
field means something else, like broadside count" and pointed to a plain data error unique to
Dresden's own listing on that site. **Lesson: when Navy: and wowsbuilds disagree on a hard number
and wowsbuilds' own downstream stat (like an alpha-strike total) is self-consistent with its wrong
value, don't treat that self-consistency as corroboration** — check wowsbuilds' same field against
other already-confirmed ships first; if it's normally reliable for that field, the anomaly is more
likely an error on the one outlier ship than a real discrepancy.

A `WebSearch` for Dresden's gun count separately pulled in `pc.wowsbuilds.com` (the PC-game
version, no `pc.` prefix ever means Legends) and `wowsb.fandom.com` ("World of Warships **Blitz**
Wiki" — a third, mobile game, distinct from both Legends and PC) and synthesized a "10 guns, tier
II" answer blending those wrong-game sources. Both are new entries for the "wrong game" list:
Blitz is a separate mobile title from Legends, not just a namespace mixup like the PC wiki.

**12 individual casemate mounts (the highest gun count in this DB by far) could not be
reconstructed from splash art at all** — the bow-quartering shot confirmed only the forecastle gun
plus one ambiguous amidships mount, nowhere near enough for 12 positions. Asked the user, who
checked in-game across three chat exchanges: (1) "6 per side, no centerline guns" (rules out any
swinging bow/stern mount, unlike Weymouth's centerline bow/stern pair), (2) confirmed the 6
port/starboard pairs run bow-to-stern with the last pair as "turrets 11 and 12," (3) described the
extended-arc mounts as able to "shoot centerline as well as port/starboard." That chat description
got misread as the *aftmost* two pairs (9/10 and 11/12) being able to cross-fire to the opposite
broadside, written into the file that way, and was still wrong — the user caught it, corrected it
again in chat (still not quite right), then just hand-edited the JSON directly to the actual final
layout. **The confirmed-accurate layout is the one in `dresden.json`, not this narrative**: turrets
1/2 (bow-most pair) each cover their own broadside *plus the bow arc*, turrets 11/12 (stern-most
pair) each cover their own broadside *plus the stern arc*, and turrets 3-10 (the 8 casemates
between them) are fixed to one broadside only. **None of the 12 mounts can cross-fire to the
opposite broadside** — that cross-broadside capability was never actually part of the real layout;
it was an artifact of how a verbal description of in-game arcs got interpreted through two rounds
of chat back-and-forth. Lesson: a fine-grained multi-part physical layout (which sides, plus which
fore/aft zones, per mount, across 12 mounts) is easy to mishear even after asking specific
yes/no-style confirming questions — if the user ends up directly hand-editing the content file,
treat that file as ground truth over the chat history, and re-read it before writing any summary
of "how this was confirmed" rather than trusting the earlier exchange.

**Commons category names for real ships can be redirects that don't show files directly** —
searching gave `Category:SMS_Dresden_(1907)`, which loaded but contained zero files and a
"category redirect" notice pointing to the real location, `Category:Dresden (ship, 1907)` (no
"SMS", comma before "ship" not before "Dresden"). `WebFetch` resolved the redirect target from the
page's own text in one call; a plain `curl` fetch of the same URL doesn't surface that redirect
notice as easily since it's wrapped in template CSS/markup rather than a clean top-level link. Use
`WebFetch` first for any Commons category page to check for this before concluding a category has
no media.

Photo picked from that category: `SMS Dresden 1909 LOC det 4a16116.jpg`, a Detroit Publishing Co.
side-profile photo from the 1909 Hudson-Fulton fleet review in New York harbor, PD-US (published
pre-1931). Skipped another candidate on the same category page, `SMS Dresden, 1907.jpg`
(`PD-self`, uploaded by a Commons user with full camera EXIF and a "likely taken at a museum"
framing) — its own metadata suggested it was a photo *of* a museum photo/print or model rather
than an original period photograph, so a clearly-original LOC/Detroit Publishing Co. source was
preferred even though both were technically clear on licensing.

## Real-ship reference photos (for `image`/`imageCredit`, not gameplay data)

This is the one legitimate use of real-ship history sources on this project. The "General
naval-history sites... explicitly out of scope" rule above is about *gameplay data* (turret
counts, arrangement, stats) — using a real photo purely as illustration on the ship's page doesn't
contradict it, since nothing about the photo is being used to infer game mechanics.

- **`commons.wikimedia.org`, not `wikipedia.org` directly.** Commons only hosts media that's
  actually cleared for reuse (public domain or Creative Commons), so the license is verifiable on
  the file's own page instead of having to reason about Wikipedia's fair-use exceptions. Find the
  ship's category (e.g. `Category:USS Albany (1899)`) or search Commons directly for the hull name
  plus commissioning year to disambiguate from other real ships sharing the name.
- **Check the license template on the file page before using anything.** Public domain
  (`PD-USGov-Military-Navy`, `PD-old`, etc.) needs no attribution though a credit is still fine;
  `CC-BY`/`CC-BY-SA` needs an `imageCredit` line naming the author and license. Skip anything
  tagged fair-use/non-free — those are cleared for use in Wikipedia articles only, not for reuse on
  another site.
- **Get the file via `https://commons.wikimedia.org/wiki/Special:FilePath/<File name>`**, which
  redirects straight to the actual media (works with `curl -L`) — the wiki page HTML itself is just
  a description page, not the image.
- **Name disambiguation matters more here than for splash art.** A common hull name (e.g.
  "Albany") can refer to multiple unrelated real vessels across eras; confirm the Commons
  category/file actually matches the specific ship (class, commissioning year) Legends models
  before using its photo, or skip it if that can't be confirmed. Confirmed sharp danger case:
  "Chikuma" names both the tier I 1912 Chikuma-class protected cruiser Legends actually models
  *and* an unrelated WWII Tone-class heavy cruiser of the same name — searching Commons for just
  "Chikuma" without the class/year risks pulling a photo of the wrong ship entirely. Commons'
  `Category:Chikuma (ship, 1911)` disambiguates correctly.

## Port/starboard turret and torpedo layouts are almost always mirrored

User feedback after the Jurien pass: it's safe to *default toward* assuming port and starboard
mounts mirror each other (same count, same fore-aft positions) rather than treating each side as
an independent unknown — true asymmetry is rare. This doesn't remove the need to confirm the
near-side layout and the total count (splash art still only shows one broadside, per the standing
limitation below), but once the near side and total gun count are confirmed, a symmetric mirror is
the reasonable default to propose to the user for a fast yes/no, rather than treating the far side
as equally uncertain. Jurien's confirmed layout (1 bow + 3 port + 3 starboard + 1 stern) is exactly
this: near-side casemates observed directly, far side inferred by mirroring and confirmed correct
by the user in one exchange.

## First French ship (Jurien): schema notes, mixed turret/casemate layout

`nation` extended to `z.enum(['USA', 'Germany', 'Japan', 'United Kingdom', 'France'])` in
`src/content.config.ts`, plus a `France: '🇫🇷'` entry in `src/lib/nations.ts`'s `NATION_FLAGS`
(checked first, no component assumed a fixed nation list, so still a two-line change, same as every
prior nation addition).

**Legends' own ship name can be shorter than the real ship's name.** The real vessel and the PC-game
ship are both "Jurien de la Gravière" (PC wiki: tier II), but Legends calls this ship just "Jurien"
and lists her at **tier I** — confirmed via breadcrumb ("Homepage / WoWS Legends / Jurien") on
`wiki.wargaming.net/en/Navy:Jurien`, and cross-checked on `wowsbuilds.com/ships/jurien` ("I Jurien",
Tier I). Don't assume the Legends slug/name matches the full historical/PC-game name; check the
`Navy:` page's own title and breadcrumb.

**`Navy:Jurien` fetched cleanly via plain `curl` (with a browser `User-Agent` header — a bare `curl`
with no UA returned an empty body, a new finding; adding `-A "Mozilla/5.0 ..."` fixed it) and gave a
complete verbatim stat/module/consumable/Player-Opinion table** in one pass, no lossy-summarizer
issues this time. Notable sourced content: a "Big Guns" Ship Trait ("armed with high-caliber main
battery guns"), and a Player Opinion Con that directly compares her to another cataloged ship —
"Despite their impressive calibre, her guns have inferior performance than the smaller guns of
Chikuma" — a genuinely useful, source-backed, tier-scoped comparison for `weaknesses`/`playstyle`
prose, not an inferred one.

**Splash art for Jurien was a full broadside side-on view (like Chikuma/Weymouth) and showed a
genuinely mixed layout**, not a single design repeated 8 times: one open/shielded gun right at the
bow (centerline) plus casemate-style hull-side mounts amidships between the funnels, consistent
with "mixed configuration" language a `WebSearch` summary used (treated cautiously per the standing
rule about trusting search-synthesized claims, but corroborated here by direct visual inspection of
the official art, not just the search snippet). No stern gun was visible in the crop, and the far
broadside was never visible, so per the all-or-nothing rule this went to the user rather than being
guessed or left empty — see the mirroring note above for how it resolved (1 bow + 3+3 casemate pairs
+ 1 stern, matching Chikuma/Weymouth's pattern despite the different real-world hull and bigger
165mm caliber).

**Bow/stern disambiguation on this splash art**: both ends showed breaking wave foam (a
stylistic rendering quirk, not a reliable tell by itself here), but the bow was still identifiable
by the same anchor-hawsepipe-rust-streak tell used on prior ships, plus the fact that an actual gun
mount was visible right at that end's tip while the other end's tip showed no gun at all.

**Reference photo**: Wikimedia Commons' `Category:Jurien_de_la_Gravière_(ship_1899)` had 9 files;
used `NH 55994 JURIEN DE LA GRAVIERE.tif` (Naval History and Heritage Command, public domain /
CC0 mark, sourced from history.navy.mil) — a real period bow-quarter harbor photo, not a diagram or
painting. Downloaded via `Special:FilePath`, converted `.tif` to `.jpg` with `sips`. The raw
NHHC-scanned `.tif` was 3934x2712 / ~10MB; downsized to 1600px wide (`sips -Z 1600`) before saving
to `public/images/ships/`, dropping it to ~450KB — worth doing for any similarly large NHHC-sourced
scan, the full scan resolution is unnecessary for a page banner/thumbnail.

## Dover (British premium tier VII battleship): fictional "variant" ships share a hull with a real tech-tree ship, no photo possible

Dover is confirmed genuinely fictional in Legends, not modeling any real vessel or paper design at
all: `Navy:Dover`'s own infobox lists **"Year of Design: 1179"** (Dover Castle's construction date
under Henry II, a deliberate joke, not a ship year) and the ship is a `Navy:`-page-labeled
**"Variant"** of an existing tech-tree ship, `Hawke` (itself a real paper-design 1943 British
battlecruiser project, K2/K3 lineage). A "Variant" relationship means Dover reuses Hawke's hull,
turret arrangement, and torpedo arrangement exactly (confirmed identical 3x3 406mm / 4x1 533mm on
both pages) but is **not** a stats clone: Dover's own numbers (77,500 hp vs Hawke's 66,000/73,800,
17.6 km range vs 15.2/16.8 km, Sigma 2 vs 1.7, no Engine Boost consumable, no Hidden trait) were
pulled from `Navy:Dover` directly, not assumed to match Hawke. When a ship's page says "Variant",
fetch the base ship's `Navy:` page too, both for physical-layout corroboration and because the base
ship's **Player Opinion Pros/Cons section is valid, directly-transferable sourcing for the variant's
armor/citadel-specific weaknesses** if the variant's own page lacks one (Dover's page had no Player
Opinion section at all; Hawke's did, and its Cons "extensively covered in 32mm armor," "bow and
stern armor of only 25mm," "huge turrets are easily incapacitated" all apply unchanged since the
hull is identical).

**No real-world reference photo is possible for a "Year of Design: 1179" joke ship**, unlike every
other ship catalogued so far where at least a paper-design drawing or the real hull's photo exists.
Correctly left `image`/`imageCredit` unset rather than substituting a photo of the real Dover Castle
(a building, not a vessel, and not what the schema's `image` field is for) or reaching for Hawke's
own real-world inspiration instead of Dover's.

**Splash art again confirmed only the forward turret cluster** (2 of 3 406mm triple turrets,
superfiring, both pointing toward the bow) even on this heavily re-skinned castle-themed hull, the
same ceiling documented for every prior ship. The long aft deck visible in this particular
broadside-angled splash art showed no third turret at all (obscured or just not rendered in view),
so the aft turret's position and arc were resolved by asking the user directly rather than guessing
or spending further crops, consistent with [[feedback_turret_layout_research]]. Also asked the torpedo
mount question in the same pass (2 fixed per side, per the standing "ask early once past the
confirmed cluster" guidance) rather than treating it as a separate research round, worth doing
proactively whenever turret layout also needs a user check, since it's the same in-game look either
way (port-view camera / train limits).

## First Japanese ship (Chikuma): schema notes, splash art limits

`nation` extended to `z.enum(['USA', 'Germany', 'Japan'])` in `src/content.config.ts`, plus a
`Japan: '🇯🇵'` entry in `src/lib/nations.ts`'s `NATION_FLAGS` (checked first, no component assumed
a fixed nation list, so still a two-line change). The `Navy:<Ship_Name>` and `wowsbuilds.com`
per-ship-page patterns both held for a Japanese ship with no extra friction, and
`wiki.wargaming.net/en/Navy:All_Ships`'s tech tree listing confirmed Chikuma as tier I, the first
ship in the Japanese cruiser line (only other tier I cruiser in this DB, Albany, is USA — a clean
direct peer for `rating` comparisons at this tier).

**Splash art orientation isn't always bow-toward-camera.** Chikuma's splash art
(`chikuma.webp`) is a full broadside side-on view, not the usual 3/4 bow-forward shot the earlier
ships had — and on first glance the *masts* made it easy to misread which end was the bow (the
end with more visible rigging/tripod mast looked like it should be "the front"). The actual
tell that resolved it: anchor hawsepipe rust streaks and a breaking bow wave were on the end
initially assumed to be the stern, and a small ensign staff was on the opposite end — flip the
assumption and re-check for these physical tells before trusting which end looks more
bow-shaped.

## Duke of York (British premium tier VI battleship): splash art can't distinguish quad from twin at a glance, and Legends can reorder a real class's turret calibers

`Navy:Duke_of_York`'s module table gives arrangement as aggregate counts only ("1x2" plus "2x4", i.e. one twin mount and two quad mounts, 10 guns total) with no indication of which physical position (A/B/Y) holds which. The forward-cluster splash art crop (`duke-of-york.webp` via wowsbuilds.com, standard bow-quartering angle, same ceiling as every other ship — only the forward two turrets visible) was read as "both quad" at first glance, since overlapping barrels in a 3/4 perspective shot are easy to miscount. The user corrected this from in-game knowledge: A (bow-most) is quad, B (superfiring over A) is twin, Y (stern) is quad — the twin sits in the middle position, not aft. This also doesn't match the real King George V-class's actual historical turret calibers (A and B quad, Y twin) — a reminder that even when Legends visibly models a real ship's general silhouette accurately, per-turret specifics can still diverge from the real vessel, so real-world class knowledge isn't a substitute for in-game or wiki confirmation even as a tie-breaker between two visually similar turrets. Sister tech-tree ship `Navy:King_George_V` was a useful stat-comparison peer (same class, same 2x4+1x2 aggregate arrangement, but 25s reload vs Duke of York's slower 29.5s) despite not resolving the per-position question either — its module table has the identical aggregate-only limitation.

## First Soviet ship (Novik): schema notes, and a Player Opinion blurb that contradicted the ship's own stat table

`nation` extended to `z.enum(['USA', 'Germany', 'Japan', 'United Kingdom', 'France', 'USSR'])` in
`src/content.config.ts`, plus a `USSR: '☭'` entry in `src/lib/nations.ts`'s `NATION_FLAGS` (checked
first, no component assumed a fixed nation list, still a two-line change like every prior nation
addition). Unicode has no flag emoji for a dissolved country, so the hammer-and-sickle symbol
stands in for the flag pill instead of a real-world national flag.

`Navy:Novik`'s own breadcrumb says "Homepage / WoWS Legends / Novik" (confirmed genuine) but its
infobox fields are inconsistent about the nation name across the page, same pattern already seen
on Weymouth: "Nation: U.S.S.R" in the infobox, "Soviet" in the prose blurb, "Legends Nation USSR"
in the page's own category tag. Used `USSR` for the enum (matches the category tag and is the
common short form, same reasoning as keeping `USA` instead of "United States").

**A ship's Player Opinion blurb can go stale relative to its own stat table on the same page.**
Novik's Player Opinion Cons list "Low HP pool" as a con, but the page's own stat table lists
14,500 hull HP, actually the highest of any tier I cruiser catalogued here (Weymouth 14,200,
Jurien 14,100, Chikuma 13,100, Albany 11,500). Trusted the hard number from the stat table over
the prose blurb rather than writing a contradictory weakness into the file; the "Slow shell speed"
con had no contradicting hard number available so it was left out of `weaknesses` rather than
either trusted or actively contradicted (120mm shells having lower velocity than heavier-caliber
peers is plausible but wasn't independently confirmed).

**Tier I ship confirmed to have no upgrade slots again** (`Navy:Novik`'s Modules section jumps
from the Main Battery module table straight to Consumables, no Slot 1/2/3 section), consistent
with every other tier I ship checked so far. The only non-slotted module was a hull-tied
"Targeting System I mod. 2" giving +10% range (9.4 → 10.3 km), the same non-slotted-Fire-Control
pattern documented for Albany.

**Splash art (`novik.webp`) was a broadside-length view like Chikuma/Weymouth/Jurien's, not the
usual bow-quarter shot, and still hit the same ceiling.** Crops confirmed one open bow-mounted gun
and a second gun position further aft, but the far end of the hull showed the exact "second
bow-like structure that isn't the bow" ambiguity documented under Albany above, not a real stern
confirmation. Went straight to the user rather than spending a fourth crop chasing it, per
[[feedback_turret_layout_research]] and the standing token-spend guidance in wows-ship's SKILL.md.
Proposed the specific Chikuma/Weymouth/Jurien 1-bow/3-port/3-starboard/1-stern layout as a
concrete yes/no rather than an open question (Novik's own 8x1 120mm arrangement made this a strong
prior) and the user confirmed it matched exactly, resolving it in one exchange.

**Reference photo**: Wikimedia Commons' `Category:Novik_(ship,_1900)` had 11 files, only two real
photographs among mostly paintings/diagrams. Used `Novik1904Port-Artur.jpg` (Russian cruiser Novik
underway at Port Arthur, 1904, sourced from navsource.narod.ru's Russian/Soviet navy photo
archive, tagged PD-RusEmpire/PD-old/CC-PD-Mark) over the other real photo on the same page
(`Novik scuttled at Koraskhov Bay.jpg`, showing the ship sunk after her final action) since an
underway photo is a better illustration than a wreck shot when both are equally well-licensed.

## Hyūga (Japanese premium tier V battleship): MBRB data page, and turret layout confirmed by the user fast

**`https://wiki.wargaming.net/en/Navy:MBRB_Data`** has a per-ship table of Main Battery Reload
Booster numbers (duration/reload/charge count and the reload % reduction) — confirmed Hyūga's row
(-50%, 15s, 150s, 2 charges). Useful any time a ship's consumable list includes this booster and
the per-ship `Navy:<Ship>` page itself doesn't spell out the percentage.

Hyūga's turret layout (6x2 356mm, none of the six turrets able to hit the bow arc at all; the
amidships pair further restricted to port/starboard only) was resolved by asking the user directly
after only one splash-art crop confirming the forward pair — not through further image analysis.
The user does not want token spend on multi-crop bow/stern orientation forensics for turret/torpedo
layout; per updated `wows-ship` SKILL.md guidance, ask promptly once the forward cluster is
confirmed rather than iterating on images. See [[feedback_turret_layout_research]] in the memory
system for the standing preference.

Legends models Hyūga in her original 6-turret battleship configuration, not the 1943+ hybrid
carrier conversion (flight deck aft) — when picking a reference photo, use a pre-1943 photo
(`Hyuga1941.jpg` on Commons, PD-Japan-oldphoto/PD-1996/PD-US-alien-property, dated December 1941,
via the Kure Maritime Museum album) rather than a wartime photo showing the converted flight deck.

**8x1 152mm confirmed by both `Navy:Chikuma` and `wowsbuilds.com`, but bow-to-stern turret
detail stayed unconfirmed even with a full broadside splash art available.** The art clearly
showed one shielded single mount at the forecastle break (bow) and one at the aft deck (stern),
plus several more shielded mounts amidships between the funnels — consistent with 8 guns total —
but distinguishing actual gun mounts from ship's-boat davit cradles (visually similar cylindrical
shield shapes at a glance) amidships, and not being able to see the far broadside at all, meant
the count and per-mount arcs couldn't be reconstructed with confidence. Left `turrets: []` rather
than guess, per the standing rule — a full-broadside splash art is better than a 3/4 bow shot for
this but still isn't sufficient alone for a precise mount-by-mount layout.

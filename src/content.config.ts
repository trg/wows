import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';
import { GOAL_TAGS } from './lib/goals';

const ships = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/ships' }),
  schema: z.object({
    name: z.string(),
    nation: z.enum(['USA', 'Germany', 'Japan', 'United Kingdom', 'France', 'USSR', 'Italy', 'Spain']),
    type: z.enum(['Destroyer', 'Cruiser', 'Battleship']),
    tier: z.number().int().min(1).max(11),
    isPremium: z.boolean().default(false),
    shortDescription: z.string(),
    role: z.string(),
    stats: z.array(
      z.object({
        label: z.string(),
        value: z.string(),
        rating: z.enum(['strong', 'average', 'weak']).optional(),
      })
    ),
    consumables: z.array(
      z.object({
        name: z.string(),
        flavor: z.string(),
        rating: z.enum(['strong', 'average', 'weak']).optional(),
      })
    ),
    // Main battery turrets, listed bow-to-stern in physical order (array order determines
    // fore-to-aft diagram order). Powers the top-down firing-arc diagram. `position` places the
    // turret's marker on the hull: 'centerline' (default) for standard turreted mounts, or
    // 'port'/'starboard' for casemate-style mounts fixed to one side. Turrets sharing the same
    // occurrence index within port/starboard (1st port with 1st starboard, etc.) are drawn on
    // the same fore-aft line.
    turrets: z
      .array(
        z.object({
          label: z.string(),
          guns: z.number().int().positive(),
          arcs: z.array(z.enum(['bow', 'stern', 'port', 'starboard'])),
          position: z.enum(['centerline', 'port', 'starboard']).default('centerline'),
          note: z.string().optional(),
        })
      )
      .default([]),
    // Torpedo tube mounts, for ships that have them. `side: 'centerline'` means the mount can
    // fire to either broadside (player's choice per launch); `port`/`starboard` means fixed to
    // that side only.
    torpedoMounts: z
      .array(
        z.object({
          label: z.string(),
          tubes: z.string(),
          side: z.enum(['centerline', 'port', 'starboard']),
          // Qualitative train/traverse limit relative to peer mounts, not exact degrees.
          // Real degree numbers, when sourced, go in `note` instead.
          firingSector: z.enum(['narrow', 'average', 'wide']).optional(),
          // The in-game narrow/wide salvo-dispersion toggle. Both angles are the spread
          // between the leftmost and rightmost torpedo in that mode's salvo; set both or
          // neither, since one confirmed value isn't useful without the other.
          spreadPattern: z
            .object({
              narrowDeg: z.number().positive(),
              wideDeg: z.number().positive(),
            })
            .optional(),
          // True if the mount can fire individual tubes instead of the full salvo at once.
          singleTubeFire: z.boolean().optional(),
          note: z.string().optional(),
        })
      )
      .default([]),
    upgrades: z.array(
      z.object({
        slot: z.string(),
        recommended: z.string(),
        alternative: z.string().optional(),
      })
    ),
    legendaryModule: z
      .object({
        name: z.string(),
        effect: z.string(),
        unlockNote: z.string(),
      })
      .optional(),
    strengths: z.array(z.string()),
    weaknesses: z.array(z.string()),
    tips: z.array(z.string()),
    threats: z.array(
      z.object({
        threat: z.string(),
        reason: z.string(),
      })
    ),
    playstyle: z.object({
      summary: z.array(z.string()),
      detail: z.string(),
    }),
    goalTags: z
      .array(
        z.object({
          tag: z.enum(GOAL_TAGS),
          note: z.string(),
        })
      )
      .default([]),
    // Freeform, hand-written by the site owner — opinions and vibes, not
    // researched fact. Skills must never generate or overwrite this field.
    captainsNotes: z.string().optional(),
    image: z.string().optional(),
    // Attribution line, required whenever `image`'s license isn't public domain/CC0
    // (e.g. a Wikimedia Commons CC-BY-SA photo). Fine to set for PD images too.
    imageCredit: z.string().optional(),
  }),
});

const maps = defineCollection({
  loader: glob({ pattern: '**/*.json', base: './src/content/maps' }),
  schema: z.object({
    name: z.string(),
    size: z.string(),
    gameModes: z.array(z.string()),
    description: z.string(),
    keyAreas: z.array(
      z.object({
        name: z.string(),
        type: z.enum(['capture-point', 'camping-spot', 'chokepoint', 'flank-route', 'open-water']),
        notes: z.string(),
      })
    ),
    strategyNotes: z.array(z.string()),
    image: z.string().optional(),
  }),
});

export const collections = { ships, maps };

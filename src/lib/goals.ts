// Fixed taxonomy for the "Best Ships For..." goal lists.
// Ships opt into these via `goalTags` in their content entry; the /goals/ page
// derives its lists from ship data rather than a hand-maintained separate list.

export const GOAL_TAGS = [
  'fire-starter',
  'torpedo-alpha',
  'stealth-play',
  'tank-brawler',
  'aa-defense',
  'utility-support',
] as const;

export type GoalTag = (typeof GOAL_TAGS)[number];

export const GOAL_CATEGORIES: Record<GoalTag, { title: string; description: string }> = {
  'fire-starter': {
    title: 'Best for Starting Fires',
    description: 'High fire chance and HE spam to burn down anything that shows broadside.',
  },
  'torpedo-alpha': {
    title: 'Best for Devastating Torpedo Hits',
    description: 'Devastating torpedo salvos that can delete a ship in one well-placed hit.',
  },
  'stealth-play': {
    title: 'Best for Stealth Play',
    description: 'Low detectability for scouting, ambushing, and slipping past the front line.',
  },
  'tank-brawler': {
    title: 'Best for Brawling & Tanking',
    description: 'Heavy armor and hit points built for close-range slugging matches.',
  },
  'aa-defense': {
    title: 'Best for AA Defense',
    description: 'Strong anti-air to protect the fleet from carrier strikes.',
  },
  'utility-support': {
    title: 'Best for Team Utility',
    description: 'Smoke, heals, spotting, and other tools that make the whole team better.',
  },
};

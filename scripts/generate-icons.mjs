#!/usr/bin/env node
// Rasterizes public/favicon.svg into the PNG sizes iOS home-screen icons and
// the web manifest need (SVG isn't supported for either), plus a generic
// branded OG/Twitter share image. Re-run this after changing favicon.svg.
//
// Usage: node scripts/generate-icons.mjs

import { readFileSync } from 'node:fs';
import { mkdir, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import sharp from 'sharp';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const favicon = readFileSync(join(root, 'public/favicon.svg'));

const iconsDir = join(root, 'public/icons');
await mkdir(iconsDir, { recursive: true });

const iconSizes = [
  ['apple-touch-icon.png', 180],
  ['icon-192.png', 192],
  ['icon-512.png', 512],
];

for (const [name, size] of iconSizes) {
  await sharp(favicon, { density: 384 })
    .resize(size, size)
    .flatten({ background: '#0a0f0b' })
    .png()
    .toFile(join(iconsDir, name));
  console.log(`wrote public/icons/${name}`);
}

// Generic OG/Twitter card for pages without their own image (home, listing
// pages, about, 404). Uses a generic monospace font since the site's custom
// webfonts don't rasterize reliably through librsvg.
const ogWidth = 1200;
const ogHeight = 630;
const markSize = 220;
const ogSvg = `
<svg xmlns="http://www.w3.org/2000/svg" width="${ogWidth}" height="${ogHeight}">
  <rect width="${ogWidth}" height="${ogHeight}" fill="#0a0f0b" />
  <g transform="translate(${ogWidth / 2 - markSize / 2}, 70)">
    <g fill="none" stroke="#39ff6a" stroke-width="10">
      <circle cx="${markSize / 2}" cy="${markSize / 2}" r="${markSize * 0.34}" />
      <line x1="${markSize / 2}" y1="${markSize * 0.11}" x2="${markSize / 2}" y2="${markSize * 0.27}" />
      <line x1="${markSize / 2}" y1="${markSize * 0.73}" x2="${markSize / 2}" y2="${markSize * 0.89}" />
      <line x1="${markSize * 0.11}" y1="${markSize / 2}" x2="${markSize * 0.27}" y2="${markSize / 2}" />
      <line x1="${markSize * 0.73}" y1="${markSize / 2}" x2="${markSize * 0.89}" y2="${markSize / 2}" />
      <circle cx="${markSize / 2}" cy="${markSize / 2}" r="6" fill="#39ff6a" stroke="none" />
    </g>
  </g>
  <text x="${ogWidth / 2}" y="380" text-anchor="middle" font-family="'Courier New', monospace" font-size="56" font-weight="bold" fill="#e9fff0">WoWS Legends Companion</text>
  <text x="${ogWidth / 2}" y="430" text-anchor="middle" font-family="'Courier New', monospace" font-size="28" fill="#8fae9b">Loadouts, tips, and playstyle notes for World of Warships: Legends</text>
</svg>
`;

await sharp(Buffer.from(ogSvg)).png().toFile(join(root, 'public/og-default.png'));
console.log('wrote public/og-default.png');

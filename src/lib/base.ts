// Astro's BASE_URL reflects the `base` config option (e.g. "/wows/" when
// deployed under a GitHub Pages project path). Normalize to always have a
// trailing slash so callers can safely do `${base}ships/`.
const raw = import.meta.env.BASE_URL;
export const base = raw.endsWith('/') ? raw : `${raw}/`;

export function withBase(path: string): string {
  return `${base}${path.replace(/^\//, '')}`;
}

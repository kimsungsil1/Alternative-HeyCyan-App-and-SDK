const memoryStore = new Map<string, number>();

export function allowByCooldown(key: string, cooldownMs: number): boolean {
  const now = Date.now();
  const last = memoryStore.get(key);
  if (last && now - last < cooldownMs) return false;
  memoryStore.set(key, now);
  return true;
}

export function upstashStubNote() {
  return 'Replace lib/rateLimit.ts with Upstash Redis sliding window for multi-instance deployments.';
}

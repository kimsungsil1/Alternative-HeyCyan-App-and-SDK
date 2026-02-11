const SAFETY_KEYWORDS = ['죽고싶', '자해', '극단적', '목숨', '사라지고싶'];
const PROFANITY_KEYWORDS = ['ㅅㅂ', '개새', '병신'];

export function detectSafetyRisk(text: string): boolean {
  const normalized = text.toLowerCase().replace(/\s+/g, '');
  return SAFETY_KEYWORDS.some((keyword) => normalized.includes(keyword));
}

export function containsProfanity(text: string): boolean {
  const normalized = text.toLowerCase();
  return PROFANITY_KEYWORDS.some((keyword) => normalized.includes(keyword));
}

export function sanitizeText(text: string): string {
  return text.trim();
}

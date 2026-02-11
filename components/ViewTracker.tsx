'use client';

import { useEffect } from 'react';

export default function ViewTracker({ postId }: { postId: number }) {
  useEffect(() => {
    const key = `post_view_${postId}`;
    const now = Date.now();
    const last = Number(localStorage.getItem(key) ?? 0);
    if (now - last < 10 * 60 * 1000) return;

    fetch('/api/views', {
      method: 'POST',
      body: JSON.stringify({ postId })
    }).finally(() => localStorage.setItem(key, String(now)));
  }, [postId]);

  return null;
}

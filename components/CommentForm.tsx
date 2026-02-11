'use client';

import { FormEvent, useState } from 'react';
import { detectSafetyRisk } from '@/lib/moderation';

export default function CommentForm({ postId, canWrite }: { postId: number; canWrite: boolean }) {
  const [body, setBody] = useState('');
  const [showSafety, setShowSafety] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    if (!canWrite) return;
    if (detectSafetyRisk(body)) {
      setShowSafety(true);
      return;
    }
    const res = await fetch('/api/comments', {
      method: 'POST',
      body: JSON.stringify({ postId, body })
    });
    if (res.ok) {
      setBody('');
      location.reload();
    }
  }

  return (
    <form onSubmit={onSubmit} className="space-y-2 rounded-lg border border-zinc-200 bg-white p-4">
      <h3 className="font-semibold">댓글 작성</h3>
      {!canWrite && <p className="text-sm text-amber-700">인증 완료 사용자만 댓글을 작성할 수 있습니다.</p>}
      {showSafety && (
        <div className="rounded bg-rose-50 p-3 text-sm text-rose-900">
          지금은 안전이 먼저입니다. 내용을 다시 확인하고 필요 시 <a href="/help">도움 페이지</a>를 이용해 주세요.
        </div>
      )}
      <textarea
        className="w-full rounded border p-2"
        rows={3}
        value={body}
        onChange={(e) => setBody(e.target.value)}
        disabled={!canWrite}
      />
      <button disabled={!canWrite} className="rounded bg-zinc-900 px-3 py-2 text-sm text-white disabled:bg-zinc-400">
        댓글 등록
      </button>
    </form>
  );
}

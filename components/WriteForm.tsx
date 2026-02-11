'use client';

import { FormEvent, useState } from 'react';
import { containsProfanity, detectSafetyRisk } from '@/lib/moderation';

const categories = ['연애', '불안', '일상', '질문', '썰'];

export default function WriteForm({ canWrite }: { canWrite: boolean }) {
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [category, setCategory] = useState(categories[0]);
  const [showSafety, setShowSafety] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    if (!canWrite) return;
    if (detectSafetyRisk(`${title}\n${body}`)) {
      setShowSafety(true);
      return;
    }
    if (containsProfanity(`${title}\n${body}`)) {
      alert('과도한 비속어가 포함되어 수정이 필요합니다.');
      return;
    }
    const res = await fetch('/api/posts', {
      method: 'POST',
      body: JSON.stringify({ title, body, category })
    });
    if (res.ok) {
      window.location.href = '/';
    }
  }

  return (
    <form onSubmit={onSubmit} className="space-y-3 rounded-lg border border-zinc-200 bg-white p-4">
      {showSafety && (
        <div className="rounded bg-rose-50 p-3 text-sm text-rose-900">
          지금은 안전이 먼저입니다. 게시 전에 내용을 다시 확인하고 필요 시 <a href="/help">도움 페이지</a>를 확인하세요.
        </div>
      )}
      <div>
        <label className="mb-1 block text-sm font-medium">카테고리</label>
        <select className="w-full rounded border p-2" value={category} onChange={(e) => setCategory(e.target.value)}>
          {categories.map((c) => (
            <option key={c}>{c}</option>
          ))}
        </select>
      </div>
      <div>
        <label className="mb-1 block text-sm font-medium">제목</label>
        <input className="w-full rounded border p-2" value={title} onChange={(e) => setTitle(e.target.value)} />
      </div>
      <div>
        <label className="mb-1 block text-sm font-medium">본문</label>
        <textarea className="w-full rounded border p-2" rows={10} value={body} onChange={(e) => setBody(e.target.value)} />
      </div>
      <button disabled={!canWrite} className="rounded bg-zinc-900 px-4 py-2 text-white disabled:bg-zinc-400">
        게시
      </button>
    </form>
  );
}

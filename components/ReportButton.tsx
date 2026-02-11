'use client';

import { useState } from 'react';

type Props = {
  targetType: 'post' | 'comment';
  targetId: number;
};

export default function ReportButton({ targetType, targetId }: Props) {
  const [reason, setReason] = useState('');
  const [open, setOpen] = useState(false);

  async function submitReport() {
    const res = await fetch('/api/reports', {
      method: 'POST',
      body: JSON.stringify({ targetType, targetId, reason })
    });
    if (res.ok) {
      setReason('');
      setOpen(false);
      alert('신고가 접수되었습니다.');
    }
  }

  return (
    <div className="inline-flex items-center gap-2">
      <button
        className="rounded border border-zinc-300 px-2 py-1 text-xs hover:bg-zinc-100"
        onClick={() => setOpen(!open)}
      >
        신고
      </button>
      {open && (
        <div className="flex items-center gap-2">
          <input
            className="rounded border px-2 py-1 text-xs"
            placeholder="신고 사유"
            value={reason}
            onChange={(e) => setReason(e.target.value)}
          />
          <button className="rounded bg-red-600 px-2 py-1 text-xs text-white" onClick={submitReport}>
            제출
          </button>
        </div>
      )}
    </div>
  );
}

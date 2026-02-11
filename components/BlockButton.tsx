'use client';

type Props = {
  blockedId: string;
};

export default function BlockButton({ blockedId }: Props) {
  async function blockUser() {
    const res = await fetch('/api/block', {
      method: 'POST',
      body: JSON.stringify({ blockedId })
    });
    if (res.ok) {
      alert('사용자를 차단했습니다.');
    }
  }

  return (
    <button className="rounded border border-zinc-300 px-2 py-1 text-xs hover:bg-zinc-100" onClick={blockUser}>
      차단
    </button>
  );
}

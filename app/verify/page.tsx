'use client';

import { FormEvent, useState } from 'react';

const questions = Array.from({ length: 12 }, (_, i) => `${i + 1}. 최근 일상 스트레스와 감정 상태를 스스로 체크해 보세요.`);

export default function VerifyPage() {
  const [answers, setAnswers] = useState<number[]>(Array(12).fill(3));
  const [agreeRules, setAgreeRules] = useState(false);
  const [pledge, setPledge] = useState(false);

  async function submit(e: FormEvent) {
    e.preventDefault();
    if (!agreeRules || !pledge) {
      alert('규칙 동의와 안전 서약이 필요합니다.');
      return;
    }

    const res = await fetch('/api/verify', {
      method: 'POST',
      body: JSON.stringify({ answers, agreeRules, pledge })
    });

    if (res.ok) {
      alert('작성 권한 인증이 완료되었습니다.');
      window.location.href = '/me';
    }
  }

  return (
    <form className="space-y-4" onSubmit={submit}>
      <h1 className="text-2xl font-bold">멘헤라 인증 (커뮤니티 참여 인증)</h1>
      <p className="text-sm text-zinc-700">의학적 진단이 아닌, 안전한 참여를 위한 절차입니다.</p>

      <section className="space-y-3 rounded-lg border border-zinc-200 bg-white p-4">
        <h2 className="font-semibold">1단계: 자기 점검 (12문항)</h2>
        {questions.map((q, idx) => (
          <label key={q} className="block text-sm">
            <span className="mb-1 block">{q}</span>
            <input
              type="range"
              min={1}
              max={5}
              value={answers[idx]}
              onChange={(e) => {
                const next = [...answers];
                next[idx] = Number(e.target.value);
                setAnswers(next);
              }}
            />
            <span className="ml-2">{answers[idx]}</span>
          </label>
        ))}
      </section>

      <section className="space-y-2 rounded-lg border border-zinc-200 bg-white p-4 text-sm">
        <h2 className="font-semibold">2단계: 규칙 동의</h2>
        <p>상대 존중, 위기 조장 금지, 개인정보 보호 규칙에 동의합니다.</p>
        <label className="flex gap-2">
          <input type="checkbox" checked={agreeRules} onChange={(e) => setAgreeRules(e.target.checked)} />
          규칙에 동의합니다.
        </label>
      </section>

      <section className="space-y-2 rounded-lg border border-zinc-200 bg-white p-4 text-sm">
        <h2 className="font-semibold">3단계: 안전 서약</h2>
        <label className="flex gap-2">
          <input type="checkbox" checked={pledge} onChange={(e) => setPledge(e.target.checked)} />
          위기 상황을 조장하지 않고, 안전을 최우선으로 커뮤니티에 참여하겠습니다.
        </label>
      </section>

      <button className="rounded bg-zinc-900 px-4 py-2 text-white">인증 완료</button>
    </form>
  );
}

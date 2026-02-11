'use client';

import { FormEvent, useState } from 'react';
import { createClient } from '@/lib/supabase/client';

export default function SignupPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [nickname, setNickname] = useState('');

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    const supabase = createClient();
    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        emailRedirectTo: `${location.origin}/login`,
        data: { nickname }
      }
    });
    if (error) return alert(error.message);
    alert('인증 메일을 확인해주세요.');
    window.location.href = '/login';
  }

  return (
    <form onSubmit={onSubmit} className="mx-auto max-w-md space-y-3 rounded-lg border bg-white p-6">
      <h1 className="text-xl font-bold">회원가입</h1>
      <input className="w-full rounded border p-2" placeholder="닉네임" value={nickname} onChange={(e) => setNickname(e.target.value)} />
      <input className="w-full rounded border p-2" placeholder="이메일" value={email} onChange={(e) => setEmail(e.target.value)} />
      <input
        type="password"
        className="w-full rounded border p-2"
        placeholder="비밀번호"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />
      <button className="w-full rounded bg-zinc-900 py-2 text-white">가입하기</button>
    </form>
  );
}

'use client';

import Link from 'next/link';
import { FormEvent, useState } from 'react';
import { createClient } from '@/lib/supabase/client';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) return alert(error.message);
    window.location.href = '/';
  }

  return (
    <form onSubmit={onSubmit} className="mx-auto max-w-md space-y-3 rounded-lg border bg-white p-6">
      <h1 className="text-xl font-bold">로그인</h1>
      <input className="w-full rounded border p-2" placeholder="이메일" value={email} onChange={(e) => setEmail(e.target.value)} />
      <input
        type="password"
        className="w-full rounded border p-2"
        placeholder="비밀번호"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
      />
      <button className="w-full rounded bg-zinc-900 py-2 text-white">로그인</button>
      <p className="text-sm">회원이 아니신가요? <Link href="/signup">회원가입</Link></p>
    </form>
  );
}

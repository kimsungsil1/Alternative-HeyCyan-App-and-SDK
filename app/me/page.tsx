import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';

export default async function MePage() {
  const supabase = await createClient();
  const { data } = await supabase.auth.getUser();
  if (!data.user) redirect('/login');

  const [{ data: profile }, { data: posts }, { data: comments }, { data: blocks }] = await Promise.all([
    supabase.from('profiles').select('nickname,created_at,is_verified_posting').eq('id', data.user.id).single(),
    supabase.from('posts').select('id,title,created_at').eq('author_id', data.user.id).eq('is_deleted', false).limit(10),
    supabase.from('comments').select('id,body,created_at').eq('author_id', data.user.id).eq('is_deleted', false).limit(10),
    supabase.from('blocks').select('id,blocked_id,created_at').eq('blocker_id', data.user.id).limit(20)
  ]);

  return (
    <div className="space-y-4">
      <section className="rounded-lg border bg-white p-4">
        <h1 className="text-xl font-bold">내 프로필</h1>
        <p>닉네임: {profile?.nickname}</p>
        <p>가입일: {profile?.created_at ? new Date(profile.created_at).toLocaleDateString('ko-KR') : '-'}</p>
        <p>작성 권한 인증: {profile?.is_verified_posting ? '완료' : '미완료'}</p>
      </section>

      <section className="rounded-lg border bg-white p-4">
        <h2 className="mb-2 font-semibold">내 게시글</h2>
        <ul className="list-disc pl-5 text-sm">
          {posts?.map((p) => <li key={p.id}>{p.title}</li>)}
        </ul>
      </section>

      <section className="rounded-lg border bg-white p-4">
        <h2 className="mb-2 font-semibold">내 댓글</h2>
        <ul className="list-disc pl-5 text-sm">
          {comments?.map((c) => <li key={c.id}>{c.body}</li>)}
        </ul>
      </section>

      <section className="rounded-lg border bg-white p-4">
        <h2 className="mb-2 font-semibold">차단 목록</h2>
        <ul className="list-disc pl-5 text-sm">
          {blocks?.map((b) => <li key={b.id}>{b.blocked_id}</li>)}
        </ul>
      </section>
    </div>
  );
}

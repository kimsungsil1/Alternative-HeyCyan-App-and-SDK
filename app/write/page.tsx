import { redirect } from 'next/navigation';
import WriteForm from '@/components/WriteForm';
import { createClient } from '@/lib/supabase/server';

export default async function WritePage() {
  const supabase = await createClient();
  const { data } = await supabase.auth.getUser();
  if (!data.user) redirect('/login');

  const { data: profile } = await supabase
    .from('profiles')
    .select('is_verified_posting')
    .eq('id', data.user.id)
    .single();

  return (
    <div className="space-y-3">
      <h1 className="text-2xl font-bold">글쓰기</h1>
      {!profile?.is_verified_posting && (
        <p className="rounded bg-amber-50 p-3 text-sm text-amber-900">
          인증 완료 사용자만 게시글 작성이 가능합니다. <a href="/verify">인증 페이지</a>로 이동해 주세요.
        </p>
      )}
      <WriteForm canWrite={!!profile?.is_verified_posting} />
    </div>
  );
}

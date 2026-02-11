import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';

export default async function AdminPage() {
  const supabase = await createClient();
  const { data } = await supabase.auth.getUser();
  if (!data.user) redirect('/login');

  const { data: profile } = await supabase.from('profiles').select('role').eq('id', data.user.id).single();
  if (profile?.role !== 'admin') redirect('/');

  const { data: reports } = await supabase
    .from('reports')
    .select('id,target_type,target_id,reason,status,created_at,reporter_id')
    .order('created_at', { ascending: false })
    .limit(100);

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-bold">관리자 대시보드</h1>
      <div className="rounded-lg border bg-white p-4">
        <h2 className="mb-3 font-semibold">신고 검토</h2>
        <ul className="space-y-2 text-sm">
          {reports?.map((r) => (
            <li key={r.id} className="rounded border p-2">
              [{r.status}] {r.target_type} #{r.target_id} - {r.reason}
            </li>
          ))}
          {!reports?.length && <li>신고가 없습니다.</li>}
        </ul>
      </div>
    </div>
  );
}

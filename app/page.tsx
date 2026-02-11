import Link from 'next/link';
import PostList from '@/components/PostList';
import SidebarHotPosts from '@/components/SidebarHotPosts';
import { createClient } from '@/lib/supabase/server';

export default async function Home({
  searchParams
}: {
  searchParams: { sort?: 'latest' | 'popular'; q?: string; tab?: string; category?: string };
}) {
  const supabase = await createClient();
  const sort = searchParams.sort ?? 'latest';
  const q = searchParams.q ?? '';
  const category = searchParams.category ?? '';

  let query = supabase
    .from('posts')
    .select('id,title,category,created_at,views_count,like_count,profiles(nickname)', { count: 'exact' })
    .eq('is_deleted', false)
    .limit(30);

  if (q) query = query.or(`title.ilike.%${q}%,body.ilike.%${q}%`);
  if (category) query = query.eq('category', category);

  if (sort === 'popular') {
    query = query.order('like_count', { ascending: false }).order('views_count', { ascending: false });
  } else {
    query = query.order('created_at', { ascending: false });
  }

  const [{ data: posts }, { data: hotPosts }] = await Promise.all([
    query,
    supabase
      .from('posts')
      .select('id,title')
      .eq('is_deleted', false)
      .order('like_count', { ascending: false })
      .order('views_count', { ascending: false })
      .limit(8)
  ]);

  return (
    <div className="grid gap-6 lg:grid-cols-[1fr_280px]">
      <section className="space-y-4">
        <div className="flex flex-wrap items-center justify-between gap-3 rounded-lg border border-zinc-200 bg-white p-3">
          <div className="flex gap-2 text-sm">
            <Link href="/?sort=latest" className="rounded border px-3 py-1">최신</Link>
            <Link href="/?sort=popular" className="rounded border px-3 py-1">인기</Link>
            <Link href="/?tab=notice" className="rounded border px-3 py-1">공지</Link>
          </div>
          <form className="flex gap-2" action="/">
            <input name="q" defaultValue={q} className="rounded border px-2 py-1 text-sm" placeholder="제목/본문 검색" />
            <button className="rounded bg-zinc-900 px-3 py-1 text-sm text-white">검색</button>
          </form>
        </div>

        <div className="flex gap-2 text-sm">
          {['', '연애', '불안', '일상', '질문', '썰'].map((item) => (
            <Link key={item || 'all'} href={item ? `/?category=${item}` : '/'} className="rounded border px-2 py-1">
              {item || '전체'}
            </Link>
          ))}
        </div>

        <PostList posts={posts ?? []} />
      </section>
      <SidebarHotPosts hotPosts={hotPosts ?? []} />
    </div>
  );
}

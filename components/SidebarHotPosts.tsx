import Link from 'next/link';

type Props = {
  hotPosts: Array<{ id: number; title: string }>;
};

export default function SidebarHotPosts({ hotPosts }: Props) {
  return (
    <aside className="space-y-4">
      <section className="rounded-lg border border-zinc-200 bg-white p-4">
        <h3 className="mb-2 text-sm font-bold">인기글</h3>
        <ul className="space-y-2 text-sm">
          {hotPosts.map((post) => (
            <li key={post.id}>
              <Link href={`/post/${post.id}`} className="text-zinc-800 hover:underline">
                {post.title}
              </Link>
            </li>
          ))}
          {hotPosts.length === 0 && <li className="text-zinc-500">아직 인기글이 없습니다.</li>}
        </ul>
      </section>
      <section className="rounded-lg border border-zinc-200 bg-white p-4 text-sm">
        <h3 className="mb-2 font-bold">커뮤니티 안전 규칙 요약</h3>
        <ul className="list-disc space-y-1 pl-4 text-zinc-700">
          <li>상대 비난/혐오 표현 금지</li>
          <li>위기 상황 유도/조장 금지</li>
          <li>개인정보 공유 금지</li>
        </ul>
      </section>
    </aside>
  );
}

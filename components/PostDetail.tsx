import BlockButton from './BlockButton';
import ReportButton from './ReportButton';

export default function PostDetail({
  post
}: {
  post: {
    id: number;
    title: string;
    body: string;
    created_at: string;
    author_id: string;
    views_count: number;
    like_count: number;
    category: string;
    profiles?: { nickname: string } | null;
  };
}) {
  return (
    <article className="rounded-lg border border-zinc-200 bg-white p-4">
      <div className="mb-2 flex items-center justify-between">
        <h1 className="text-xl font-semibold">[{post.category}] {post.title}</h1>
        <div className="flex gap-2">
          <BlockButton blockedId={post.author_id} />
          <ReportButton targetType="post" targetId={post.id} />
        </div>
      </div>
      <p className="mb-4 text-xs text-zinc-500">
        {post.profiles?.nickname ?? '익명'} · {new Date(post.created_at).toLocaleString('ko-KR')} · 조회 {post.views_count} · 추천 {post.like_count}
      </p>
      <div className="prose prose-sm max-w-none whitespace-pre-wrap">{post.body}</div>
    </article>
  );
}

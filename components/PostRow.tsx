import Link from 'next/link';

type Props = {
  post: {
    id: number;
    title: string;
    comment_count?: number;
    views_count: number;
    like_count: number;
    category: string;
    created_at: string;
    profiles?: { nickname: string } | null;
  };
};

export default function PostRow({ post }: Props) {
  return (
    <tr className="border-b border-zinc-200 text-sm hover:bg-zinc-50">
      <td className="px-3 py-2 text-zinc-500">{post.id}</td>
      <td className="px-3 py-2">
        <Link href={`/post/${post.id}`} className="font-medium text-zinc-900 hover:underline">
          [{post.category}] {post.title}
          {!!post.comment_count && <span className="ml-1 text-emerald-700">({post.comment_count})</span>}
        </Link>
      </td>
      <td className="px-3 py-2">{post.profiles?.nickname ?? '익명'}</td>
      <td className="px-3 py-2">{new Date(post.created_at).toLocaleString('ko-KR')}</td>
      <td className="px-3 py-2 text-right">{post.views_count}</td>
      <td className="px-3 py-2 text-right">{post.like_count}</td>
    </tr>
  );
}

import PostRow from './PostRow';

type Props = {
  posts: Array<{
    id: number;
    title: string;
    category: string;
    created_at: string;
    views_count: number;
    like_count: number;
    comment_count?: number;
    profiles?: { nickname: string } | null;
  }>;
};

export default function PostList({ posts }: Props) {
  return (
    <div className="overflow-x-auto rounded-lg border border-zinc-200 bg-white">
      <table className="min-w-full">
        <thead className="bg-zinc-100 text-xs text-zinc-700">
          <tr>
            <th className="px-3 py-2 text-left">번호</th>
            <th className="px-3 py-2 text-left">제목</th>
            <th className="px-3 py-2 text-left">작성자</th>
            <th className="px-3 py-2 text-left">작성시각</th>
            <th className="px-3 py-2 text-right">조회</th>
            <th className="px-3 py-2 text-right">추천</th>
          </tr>
        </thead>
        <tbody>
          {posts.map((post) => (
            <PostRow key={post.id} post={post} />
          ))}
          {posts.length === 0 && (
            <tr>
              <td colSpan={6} className="px-3 py-8 text-center text-zinc-500">
                게시글이 없습니다.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

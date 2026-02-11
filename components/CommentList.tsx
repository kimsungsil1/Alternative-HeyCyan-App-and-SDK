import BlockButton from './BlockButton';
import ReportButton from './ReportButton';

type Comment = {
  id: number;
  body: string;
  created_at: string;
  author_id: string;
  profiles?: { nickname: string } | null;
};

export default function CommentList({ comments }: { comments: Comment[] }) {
  return (
    <ul className="divide-y divide-zinc-200 rounded-lg border border-zinc-200 bg-white">
      {comments.map((comment) => (
        <li key={comment.id} className="p-4">
          <div className="mb-2 flex items-center justify-between text-xs text-zinc-500">
            <span>
              {comment.profiles?.nickname ?? '익명'} · {new Date(comment.created_at).toLocaleString('ko-KR')}
            </span>
            <div className="flex gap-2">
              <BlockButton blockedId={comment.author_id} />
              <ReportButton targetType="comment" targetId={comment.id} />
            </div>
          </div>
          <p className="whitespace-pre-wrap text-sm">{comment.body}</p>
        </li>
      ))}
      {comments.length === 0 && <li className="p-4 text-sm text-zinc-500">댓글이 없습니다.</li>}
    </ul>
  );
}

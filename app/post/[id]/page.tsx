import { notFound } from 'next/navigation';
import CommentForm from '@/components/CommentForm';
import CommentList from '@/components/CommentList';
import PostDetail from '@/components/PostDetail';
import { createClient } from '@/lib/supabase/server';
import ViewTracker from '@/components/ViewTracker';

export default async function PostPage({ params }: { params: { id: string } }) {
  const supabase = await createClient();
  const postId = Number(params.id);

  const [{ data: post }, { data: comments }, { data: userInfo }] = await Promise.all([
    supabase
      .from('posts')
      .select('id,title,body,category,author_id,created_at,views_count,like_count,profiles(nickname)')
      .eq('id', postId)
      .eq('is_deleted', false)
      .single(),
    supabase
      .from('comments')
      .select('id,body,created_at,author_id,profiles(nickname)')
      .eq('post_id', postId)
      .eq('is_deleted', false)
      .order('created_at', { ascending: true }),
    supabase.auth.getUser()
  ]);

  if (!post) return notFound();

  let canWrite = false;
  if (userInfo.user) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('is_verified_posting')
      .eq('id', userInfo.user.id)
      .single();
    canWrite = !!profile?.is_verified_posting;
  }

  return (
    <div className="space-y-4">
      <ViewTracker postId={postId} />
      <PostDetail post={post} />
      <CommentList comments={comments ?? []} />
      <CommentForm postId={postId} canWrite={canWrite} />
    </div>
  );
}

import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

export async function POST(req: Request) {
  const supabase = await createClient();
  const { postId } = await req.json();

  const { data: post, error: fetchError } = await supabase
    .from('posts')
    .select('views_count')
    .eq('id', postId)
    .eq('is_deleted', false)
    .single();

  if (fetchError || !post) return NextResponse.json({ error: 'Not found' }, { status: 404 });

  const { error } = await supabase.from('posts').update({ views_count: (post.views_count ?? 0) + 1 }).eq('id', postId);

  if (error) return NextResponse.json({ error: error.message }, { status: 400 });
  return NextResponse.json({ ok: true });
}

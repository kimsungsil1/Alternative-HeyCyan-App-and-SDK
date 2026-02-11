import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';
import { allowByCooldown } from '@/lib/rateLimit';
import { sanitizeText } from '@/lib/moderation';

export async function POST(req: Request) {
  const supabase = await createClient();
  const { data } = await supabase.auth.getUser();
  if (!data.user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const { data: profile } = await supabase.from('profiles').select('is_verified_posting').eq('id', data.user.id).single();
  if (!profile?.is_verified_posting) return NextResponse.json({ error: 'Verification required' }, { status: 403 });

  if (!allowByCooldown(`comment:${data.user.id}`, 20_000)) {
    return NextResponse.json({ error: 'Slow down' }, { status: 429 });
  }

  const payload = await req.json();
  const { error } = await supabase.from('comments').insert({
    post_id: payload.postId,
    author_id: data.user.id,
    body: sanitizeText(payload.body)
  });

  if (error) return NextResponse.json({ error: error.message }, { status: 400 });
  return NextResponse.json({ ok: true });
}

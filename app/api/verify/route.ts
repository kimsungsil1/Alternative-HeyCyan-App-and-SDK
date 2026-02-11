import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

export async function POST(req: Request) {
  const supabase = await createClient();
  const { data } = await supabase.auth.getUser();
  if (!data.user) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const payload = await req.json();
  if (!payload.agreeRules || !payload.pledge) {
    return NextResponse.json({ error: 'Agreement required' }, { status: 400 });
  }

  const { error } = await supabase.from('profiles').update({ is_verified_posting: true }).eq('id', data.user.id);
  if (error) return NextResponse.json({ error: error.message }, { status: 400 });

  return NextResponse.json({ ok: true, status: 'Verified for posting' });
}

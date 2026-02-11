import { NextResponse, type NextRequest } from 'next/server';
import { createServerClient } from '@supabase/ssr';

export async function middleware(req: NextRequest) {
  const res = NextResponse.next();
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return req.cookies.get(name)?.value;
        },
        set(name: string, value: string) {
          res.cookies.set(name, value);
        },
        remove(name: string) {
          res.cookies.set(name, '');
        }
      }
    }
  );

  const { data } = await supabase.auth.getUser();
  const pathname = req.nextUrl.pathname;

  if ((pathname.startsWith('/me') || pathname.startsWith('/write') || pathname.startsWith('/verify') || pathname.startsWith('/admin')) && !data.user) {
    return NextResponse.redirect(new URL('/login', req.url));
  }

  if (data.user && pathname.startsWith('/write')) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('is_verified_posting')
      .eq('id', data.user.id)
      .single();
    if (!profile?.is_verified_posting) {
      return NextResponse.redirect(new URL('/verify', req.url));
    }
  }

  if (data.user && pathname.startsWith('/admin')) {
    const { data: profile } = await supabase.from('profiles').select('role').eq('id', data.user.id).single();
    if (profile?.role !== 'admin') {
      return NextResponse.redirect(new URL('/', req.url));
    }
  }

  return res;
}

export const config = {
  matcher: ['/me/:path*', '/write/:path*', '/admin/:path*', '/verify/:path*']
};

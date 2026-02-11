import type { Metadata } from 'next';
import Link from 'next/link';
import './globals.css';
import CrisisBanner from '@/components/CrisisBanner';

export const metadata: Metadata = {
  title: '멘헤라 커뮤니티',
  description: '익명 기반 공감/지지 커뮤니티'
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ko">
      <body>
        <CrisisBanner />
        <header className="border-b border-zinc-200 bg-white">
          <div className="mx-auto flex max-w-6xl items-center justify-between px-4 py-3">
            <Link href="/" className="text-lg font-bold text-zinc-900">멘헤라 커뮤니티</Link>
            <nav className="flex gap-3 text-sm">
              <Link href="/write">글쓰기</Link>
              <Link href="/verify">인증</Link>
              <Link href="/me">내 정보</Link>
              <Link href="/login">로그인</Link>
            </nav>
          </div>
        </header>
        <main className="mx-auto max-w-6xl px-4 py-6">{children}</main>
      </body>
    </html>
  );
}

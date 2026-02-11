import Link from 'next/link';

export default function CrisisBanner() {
  return (
    <div className="border-b border-rose-300 bg-rose-50">
      <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-2 text-sm">
        <p className="text-rose-900">
          지금 힘들다면 혼자 버티지 마세요. 이 커뮤니티는 의료 서비스가 아니며, 안전이 가장 먼저입니다.
        </p>
        <Link
          href="/help"
          className="rounded bg-rose-600 px-3 py-1 font-medium text-white hover:bg-rose-700"
        >
          긴급 도움
        </Link>
      </div>
    </div>
  );
}

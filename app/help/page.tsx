export default function HelpPage() {
  return (
    <div className="space-y-4 rounded-lg border border-zinc-200 bg-white p-6">
      <h1 className="text-2xl font-bold">도움말 / 안전 리소스</h1>
      <p className="text-sm text-zinc-700">
        이 사이트는 의료 서비스가 아닙니다. 즉각적인 위험이 느껴진다면 지역의 공식 응급 기관, 신뢰할 수 있는 주변인,
        전문 상담 기관에 바로 연락하세요.
      </p>
      <ul className="list-disc space-y-1 pl-4 text-sm">
        <li>지역 응급 서비스 연락처 (placeholder)</li>
        <li>지역 정신건강 지원 기관 정보 (placeholder)</li>
        <li>신뢰할 수 있는 가족/지인에게 도움 요청하기</li>
      </ul>
    </div>
  );
}

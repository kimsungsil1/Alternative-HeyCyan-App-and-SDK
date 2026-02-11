# 멘헤라 커뮤니티 MVP (Next.js + Supabase)

익명 닉네임 기반의 한국어 커뮤니티 MVP입니다. 이 서비스는 **의학적 진단 서비스가 아니며**, 커뮤니티 참여 인증(작성 권한 인증)으로 운영됩니다.

## 1) Supabase 설정

1. Supabase 프로젝트 생성
2. SQL Editor에서 아래 순서대로 실행
   - `db/schema.sql`
   - `db/rls.sql`
   - `db/seed.sql`
3. Auth 설정
   - Email/Password 활성화
   - Email confirmation 활성화
4. Redirect URL 설정
   - 로컬: `http://localhost:3000/login`
   - 운영: `https://<your-domain>/login`

## 2) 환경변수

`.env.local` 예시:

```bash
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

Optional (Upstash rate limit 교체 시):

```bash
UPSTASH_REDIS_REST_URL=...
UPSTASH_REDIS_REST_TOKEN=...
```

## 3) 실행

```bash
npm install
npm run dev
```

## 4) Vercel 배포

1. GitHub 저장소 연결
2. Vercel 환경변수에 위 3개 추가
3. 빌드 명령: `next build` (기본값)
4. 배포 후 Supabase Auth redirect URL 운영 도메인 반영

## 5) 관리자 승격

Supabase SQL Editor:

```sql
update public.profiles
set role = 'admin'
where id = '<auth-user-uuid>';
```

## 6) 인증(작성 권한) 동작

- `/verify`에서
  1) 12문항 자기 점검
  2) 규칙 동의
  3) 안전 서약
- 완료 시 `profiles.is_verified_posting = true`
- 결과는 **"Verified for posting"** 이며 진단/질병 라벨을 부여하지 않습니다.

## 7) 안전 기능 요약

- 전 페이지 위기 배너 + `/help` 연결
- 게시/댓글 작성 중 안전 키워드 감지 시 인터스티셜 노출 후 수정 유도
- 신고 기능(`reports`)
- 사용자 차단(`blocks`)
- 게시/댓글 쿨다운 기반 rate limit (단일 인스턴스 메모리 구현)
- `/help`: 안내/placeholder 리소스, 실제 번호 임의 생성 없음

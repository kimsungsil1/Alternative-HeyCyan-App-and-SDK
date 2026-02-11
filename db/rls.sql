alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.likes enable row level security;
alter table public.reports enable row level security;
alter table public.blocks enable row level security;

create policy "profiles self read" on public.profiles
for select to authenticated
using (id = auth.uid() or role = 'admin');

create policy "profiles self update" on public.profiles
for update to authenticated
using (id = auth.uid() or exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

create policy "posts public read" on public.posts
for select
using (is_deleted = false);

create policy "posts verified insert" on public.posts
for insert to authenticated
with check (
  author_id = auth.uid()
  and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_verified_posting = true)
);

create policy "posts owner or admin update" on public.posts
for update to authenticated
using (author_id = auth.uid() or exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

create policy "comments public read" on public.comments
for select
using (is_deleted = false);

create policy "comments verified insert" on public.comments
for insert to authenticated
with check (
  author_id = auth.uid()
  and exists (select 1 from public.profiles p where p.id = auth.uid() and p.is_verified_posting = true)
);

create policy "comments owner or admin update" on public.comments
for update to authenticated
using (author_id = auth.uid() or exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

create policy "reports insert auth" on public.reports
for insert to authenticated
with check (reporter_id = auth.uid());

create policy "reports admin read" on public.reports
for select to authenticated
using (exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));

create policy "blocks owner read" on public.blocks
for select to authenticated
using (blocker_id = auth.uid());

create policy "blocks owner insert" on public.blocks
for insert to authenticated
with check (blocker_id = auth.uid());

create policy "likes read" on public.likes
for select using (true);

create policy "likes insert auth" on public.likes
for insert to authenticated
with check (user_id = auth.uid());

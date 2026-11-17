-- KOTOBA LAB V2 — chạy toàn bộ trong Supabase Dashboard > SQL Editor.
-- Có thể chạy lại khi nâng cấp. Không dán mật khẩu hay API secret vào SQL.

create table if not exists public.kotoba_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.kotoba_lessons (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 100),
  words jsonb not null check (
    jsonb_typeof(words) = 'array' and jsonb_array_length(words) between 1 and 5000
  ),
  published boolean not null default true,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.kotoba_touch_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists kotoba_lessons_touch on public.kotoba_lessons;
create trigger kotoba_lessons_touch
before update on public.kotoba_lessons
for each row execute function public.kotoba_touch_updated_at();

alter table public.kotoba_admins enable row level security;
alter table public.kotoba_lessons enable row level security;

-- Mỗi người chỉ xem được trạng thái admin của chính họ. Không cấp quyền tự thêm/sửa admin.
revoke all on public.kotoba_admins from anon, authenticated;
grant select on public.kotoba_admins to authenticated;
drop policy if exists "kotoba_admin_read_self" on public.kotoba_admins;
create policy "kotoba_admin_read_self" on public.kotoba_admins
for select to authenticated using (user_id = (select auth.uid()));

-- Khách không đăng nhập chỉ đọc các bài đã công khai.
revoke all on public.kotoba_lessons from anon, authenticated;
grant select on public.kotoba_lessons to anon, authenticated;
grant insert, update, delete on public.kotoba_lessons to authenticated;

drop policy if exists "kotoba_read_public_or_admin" on public.kotoba_lessons;
create policy "kotoba_read_public_or_admin" on public.kotoba_lessons
for select to anon, authenticated
using (
  published = true or exists (
    select 1 from public.kotoba_admins a where a.user_id = (select auth.uid())
  )
);

drop policy if exists "kotoba_admin_insert" on public.kotoba_lessons;
create policy "kotoba_admin_insert" on public.kotoba_lessons
for insert to authenticated
with check (
  created_by = (select auth.uid())
  and exists (select 1 from public.kotoba_admins a where a.user_id = (select auth.uid()))
);

drop policy if exists "kotoba_admin_update" on public.kotoba_lessons;
create policy "kotoba_admin_update" on public.kotoba_lessons
for update to authenticated
using (exists (select 1 from public.kotoba_admins a where a.user_id = (select auth.uid())))
with check (exists (select 1 from public.kotoba_admins a where a.user_id = (select auth.uid())));

drop policy if exists "kotoba_admin_delete" on public.kotoba_lessons;
create policy "kotoba_admin_delete" on public.kotoba_lessons
for delete to authenticated
using (exists (select 1 from public.kotoba_admins a where a.user_id = (select auth.uid())));

-- THÊM ADMIN SAU KHI TẠO USER TRONG SUPABASE AUTH:
-- 1. Dashboard > Authentication > Users > Add user (tạo email/mật khẩu, xác thực email).
-- 2. Lấy UUID của user vừa tạo rồi chạy lệnh dưới với UUID thật:
-- insert into public.kotoba_admins (user_id)
-- values ('THAY_BANG_UUID_CUA_ADMIN') on conflict (user_id) do nothing;
--
-- Nếu trước đây có bài V1 trên trình duyệt admin, vào mục Kho bài > Nhập bài V1.
-- Không chạy script dùng service_role key trên frontend.

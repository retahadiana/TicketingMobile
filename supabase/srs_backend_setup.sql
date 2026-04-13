-- SRS backend schema + RLS policies for E-Ticketing Helpdesk
-- Run this in Supabase SQL editor.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role text not null check (role in ('User', 'Helpdesk', 'Admin')) default 'User',
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles add column if not exists full_name text;
alter table public.profiles add column if not exists role text default 'User';
alter table public.profiles add column if not exists email text;
alter table public.profiles add column if not exists created_at timestamptz default now();
alter table public.profiles add column if not exists updated_at timestamptz default now();

update public.profiles
set role = 'User'
where role is null;

create table if not exists public.tickets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  user_name text not null,
  title text not null,
  description text not null,
  status text not null check (status in ('Open', 'In Progress', 'Resolved', 'Closed')) default 'Open',
  priority text,
  image_url text,
  assigned_to text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.tickets add column if not exists user_name text;
alter table public.tickets add column if not exists title text;
alter table public.tickets add column if not exists description text;
alter table public.tickets add column if not exists priority text;
alter table public.tickets add column if not exists image_url text;
alter table public.tickets add column if not exists assigned_to text;
alter table public.tickets add column if not exists status text default 'Open';
alter table public.tickets add column if not exists created_at timestamptz default now();
alter table public.tickets add column if not exists updated_at timestamptz default now();

create table if not exists public.ticket_comments (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid not null references public.tickets(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  author_name text not null,
  author_role text not null check (author_role in ('User', 'Helpdesk', 'Admin')),
  message text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.ticket_tracking (
  id uuid primary key default gen_random_uuid(),
  ticket_id uuid not null references public.tickets(id) on delete cascade,
  actor_name text not null,
  message text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.ticket_notifications (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  message text not null,
  ticket_id uuid not null references public.tickets(id) on delete cascade,
  target_role text not null check (target_role in ('User', 'Helpdesk', 'Admin')),
  target_user_id uuid references public.profiles(id) on delete cascade,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_tickets_user_id on public.tickets(user_id);
create index if not exists idx_tickets_status on public.tickets(status);
create index if not exists idx_tickets_updated_at on public.tickets(updated_at desc);
create index if not exists idx_ticket_comments_ticket_id on public.ticket_comments(ticket_id);
create index if not exists idx_ticket_tracking_ticket_id on public.ticket_tracking(ticket_id);
create index if not exists idx_ticket_notifications_target on public.ticket_notifications(target_role, target_user_id);

alter table public.profiles enable row level security;
alter table public.tickets enable row level security;
alter table public.ticket_comments enable row level security;
alter table public.ticket_tracking enable row level security;
alter table public.ticket_notifications enable row level security;

-- Helper function to avoid recursive profile policy checks
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
set row_security = off
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role = 'Admin'
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

-- Profiles
drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
for select to authenticated
using (id = auth.uid());

drop policy if exists profiles_select_admin_all on public.profiles;
create policy profiles_select_admin_all on public.profiles
for select to authenticated
using (public.is_admin());

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
for update to authenticated
using (id = auth.uid())
with check (id = auth.uid());

drop policy if exists profiles_update_admin_all on public.profiles;
create policy profiles_update_admin_all on public.profiles
for update to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles
for insert to authenticated
with check (id = auth.uid());

-- Tickets (User own tickets, Helpdesk/Admin all)
drop policy if exists tickets_select_role_based on public.tickets;
create policy tickets_select_role_based on public.tickets
for select to authenticated
using (
  user_id = auth.uid()
  or public.is_admin()
  or exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'Helpdesk'
  )
);

drop policy if exists tickets_insert_user_only on public.tickets;
create policy tickets_insert_user_only on public.tickets
for insert to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'User'
  )
);

drop policy if exists tickets_update_support_only on public.tickets;
create policy tickets_update_support_only on public.tickets
for update to authenticated
using (
  public.is_admin()
  or exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'Helpdesk'
  )
)
with check (
  public.is_admin()
  or exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'Helpdesk'
  )
);

-- Comments (visible if ticket visible, insert by owner/support)
drop policy if exists comments_select_role_based on public.ticket_comments;
create policy comments_select_role_based on public.ticket_comments
for select to authenticated
using (
  exists (
    select 1 from public.tickets t
    where t.id = ticket_id
      and (
        t.user_id = auth.uid()
        or public.is_admin()
        or exists (
          select 1 from public.profiles p
          where p.id = auth.uid() and p.role = 'Helpdesk'
        )
      )
  )
);

drop policy if exists comments_insert_role_based on public.ticket_comments;
create policy comments_insert_role_based on public.ticket_comments
for insert to authenticated
with check (
  author_id = auth.uid()
  and exists (
    select 1 from public.tickets t
    where t.id = ticket_id
      and (
        t.user_id = auth.uid()
        or public.is_admin()
        or exists (
          select 1 from public.profiles p
          where p.id = auth.uid() and p.role = 'Helpdesk'
        )
      )
  )
);

-- Tracking (select if ticket visible, insert by support or ticket owner)
drop policy if exists tracking_select_role_based on public.ticket_tracking;
create policy tracking_select_role_based on public.ticket_tracking
for select to authenticated
using (
  exists (
    select 1 from public.tickets t
    where t.id = ticket_id
      and (
        t.user_id = auth.uid()
        or public.is_admin()
        or exists (
          select 1 from public.profiles p
          where p.id = auth.uid() and p.role = 'Helpdesk'
        )
      )
  )
);

drop policy if exists tracking_insert_role_based on public.ticket_tracking;
create policy tracking_insert_role_based on public.ticket_tracking
for insert to authenticated
with check (
  exists (
    select 1 from public.tickets t
    where t.id = ticket_id
      and (
        t.user_id = auth.uid()
        or public.is_admin()
        or exists (
          select 1 from public.profiles p
          where p.id = auth.uid() and p.role = 'Helpdesk'
        )
      )
  )
);

-- Notifications
drop policy if exists notifications_select_role_based on public.ticket_notifications;
create policy notifications_select_role_based on public.ticket_notifications
for select to authenticated
using (
  target_user_id = auth.uid()
  or exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = target_role
  )
);

drop policy if exists notifications_insert_support_or_owner on public.ticket_notifications;
create policy notifications_insert_support_or_owner on public.ticket_notifications
for insert to authenticated
with check (
  exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role in ('User', 'Helpdesk', 'Admin')
  )
);

drop policy if exists notifications_update_read_for_target on public.ticket_notifications;
create policy notifications_update_read_for_target on public.ticket_notifications
for update to authenticated
using (
  target_user_id = auth.uid()
  or exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = target_role
  )
)
with check (
  target_user_id = auth.uid()
  or exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = target_role
  )
);

-- RPC: role assignment by Admin only
create or replace function public.assign_user_role(
  target_user_id uuid,
  new_role text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if new_role not in ('User', 'Helpdesk', 'Admin') then
    raise exception 'Invalid role';
  end if;

  if not public.is_admin() then
    raise exception 'Only admin can assign role';
  end if;

  update public.profiles
  set role = new_role
  where id = target_user_id;
end;
$$;

revoke all on function public.assign_user_role(uuid, text) from public;
grant execute on function public.assign_user_role(uuid, text) to authenticated;

-- Storage bucket for ticket attachments
insert into storage.buckets (id, name, public)
values ('ticket-attachments', 'ticket-attachments', true)
on conflict (id) do nothing;

drop policy if exists ticket_attachments_read on storage.objects;
create policy ticket_attachments_read on storage.objects
for select to authenticated
using (bucket_id = 'ticket-attachments');

drop policy if exists ticket_attachments_insert_own_folder on storage.objects;
create policy ticket_attachments_insert_own_folder on storage.objects
for insert to authenticated
with check (
  bucket_id = 'ticket-attachments'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists ticket_attachments_update_own_folder on storage.objects;
create policy ticket_attachments_update_own_folder on storage.objects
for update to authenticated
using (
  bucket_id = 'ticket-attachments'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'ticket-attachments'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists ticket_attachments_delete_own_folder on storage.objects;
create policy ticket_attachments_delete_own_folder on storage.objects
for delete to authenticated
using (
  bucket_id = 'ticket-attachments'
  and (storage.foldername(name))[1] = auth.uid()::text
);

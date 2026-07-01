-- E-Tacho — Supabase schema for cloud backup / sync of activity events.
-- Run this in the Supabase SQL editor. Row Level Security scopes every row to
-- its owner (auth.uid()).

create table if not exists public.activity_events (
  id          text primary key,
  user_id     uuid not null references auth.users (id) on delete cascade,
  type        text not null,
  start_time  timestamptz not null,
  source      text not null default 'manual',
  inserted_at timestamptz not null default now()
);

create index if not exists activity_events_user_start_idx
  on public.activity_events (user_id, start_time);

alter table public.activity_events enable row level security;

create policy "activity_events owner select"
  on public.activity_events for select
  using (auth.uid() = user_id);

create policy "activity_events owner insert"
  on public.activity_events for insert
  with check (auth.uid() = user_id);

create policy "activity_events owner update"
  on public.activity_events for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "activity_events owner delete"
  on public.activity_events for delete
  using (auth.uid() = user_id);

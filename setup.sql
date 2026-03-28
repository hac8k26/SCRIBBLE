-- ============================================================
-- NAPKIN — Supabase Schema
-- Run this in Supabase SQL Editor
-- ============================================================

-- PROFILES
create table if not exists profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  name       text not null,
  age        int  not null,
  college    text,
  email      text,
  bio        text,
  avatar_url text,
  created_at timestamptz default now()
);

alter table profiles enable row level security;

create policy "Users can read all profiles"
  on profiles for select using (auth.role() = 'authenticated');

create policy "Users can insert own profile"
  on profiles for insert with check (true);

create policy "Users can update own profile"
  on profiles for update using (auth.uid() = id);

create policy "Users can delete own profile"
  on profiles for delete using (auth.uid() = id);


-- MATCHES
create table if not exists matches (
  id           uuid primary key default gen_random_uuid(),
  user1        uuid not null references auth.users(id) on delete cascade,
  user2        uuid not null references auth.users(id) on delete cascade,
  last_message text,
  updated_at   timestamptz default now(),
  created_at   timestamptz default now()
);

alter table matches enable row level security;

create policy "Users can read own matches"
  on matches for select using (auth.uid() = user1 or auth.uid() = user2);

create policy "Users can create matches"
  on matches for insert with check (auth.uid() = user1);

create policy "Users can update own matches"
  on matches for update using (auth.uid() = user1 or auth.uid() = user2);

create policy "Users can delete own matches"
  on matches for delete using (auth.uid() = user1 or auth.uid() = user2);


-- MESSAGES
create table if not exists messages (
  id         uuid primary key default gen_random_uuid(),
  match_id   uuid not null references matches(id) on delete cascade,
  sender_id  uuid not null references auth.users(id) on delete cascade,
  text       text not null,
  created_at timestamptz default now()
);

alter table messages enable row level security;

create policy "Users can read messages in their matches"
  on messages for select using (
    exists (
      select 1 from matches
      where matches.id = messages.match_id
      and (matches.user1 = auth.uid() or matches.user2 = auth.uid())
    )
  );

create policy "Users can send messages in their matches"
  on messages for insert with check (
    auth.uid() = sender_id and
    exists (
      select 1 from matches
      where matches.id = match_id
      and (matches.user1 = auth.uid() or matches.user2 = auth.uid())
    )
  );

create policy "Users can delete messages in their matches"
  on messages for delete using (
    exists (
      select 1 from matches
      where matches.id = messages.match_id
      and (matches.user1 = auth.uid() or matches.user2 = auth.uid())
    )
  );

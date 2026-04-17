-- Task-scoped chat: one thread per inspection task, messages, attachments, read markers.
-- Storage bucket: task-chat-media (private). Path: tasks/<task_id>/<message_id>/<timestamp>_<filename>

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table public.task_chat_threads (
  id uuid primary key default gen_random_uuid (),
  task_id uuid not null unique references public.inspection_tasks (id) on delete cascade,
  created_at timestamptz not null default now()
);

create table public.task_chat_messages (
  id uuid primary key default gen_random_uuid (),
  thread_id uuid not null references public.task_chat_threads (id) on delete cascade,
  sender_user_id uuid not null references auth.users (id) on delete cascade,
  sender_role text not null check (sender_role in ('admin', 'worker')),
  body text not null default '',
  created_at timestamptz not null default now()
);

create index task_chat_messages_thread_created_idx
  on public.task_chat_messages (thread_id, created_at asc);

create table public.task_chat_attachments (
  id uuid primary key default gen_random_uuid (),
  message_id uuid not null references public.task_chat_messages (id) on delete cascade,
  storage_path text not null,
  file_name text not null,
  mime_type text,
  size_bytes bigint,
  created_at timestamptz not null default now()
);

create index task_chat_attachments_message_idx
  on public.task_chat_attachments (message_id);

create table public.task_chat_reads (
  thread_id uuid not null references public.task_chat_threads (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  last_read_at timestamptz not null default now(),
  primary key (thread_id, user_id)
);

-- ---------------------------------------------------------------------------
-- Enforce sender identity (ignore client-supplied sender fields)
-- ---------------------------------------------------------------------------

create or replace function public.task_chat_messages_before_insert ()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  r text;
begin
  new.sender_user_id := auth.uid ();
  select p.role into r
  from public.profiles p
  where p.id = auth.uid ();

  if r is null then
    raise exception 'task_chat_requires_profile';
  end if;

  new.sender_role := r;
  return new;
end;
$$;

create trigger task_chat_messages_bi
  before insert on public.task_chat_messages
  for each row
  execute function public.task_chat_messages_before_insert ();

revoke all on function public.task_chat_messages_before_insert () from public;
grant execute on function public.task_chat_messages_before_insert () to authenticated;

-- ---------------------------------------------------------------------------
-- RLS helpers: can access task via assignment (active) or admin
-- ---------------------------------------------------------------------------

create or replace function public.can_access_task_chat_task (p_task_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_task_admin ()
    or exists (
      select 1
      from public.inspection_task_assignments a
      where a.task_id = p_task_id
        and a.worker_user_id = auth.uid ()
        and a.is_active = true
    );
$$;

revoke all on function public.can_access_task_chat_task (uuid) from public;
grant execute on function public.can_access_task_chat_task (uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------

alter table public.task_chat_threads enable row level security;
alter table public.task_chat_messages enable row level security;
alter table public.task_chat_attachments enable row level security;
alter table public.task_chat_reads enable row level security;

-- threads
create policy "task_chat_threads_select"
  on public.task_chat_threads for select
  using (public.can_access_task_chat_task (task_id));

create policy "task_chat_threads_insert"
  on public.task_chat_threads for insert
  with check (public.can_access_task_chat_task (task_id));

-- messages
create policy "task_chat_messages_select"
  on public.task_chat_messages for select
  using (
    exists (
      select 1
      from public.task_chat_threads t
      where t.id = task_chat_messages.thread_id
        and public.can_access_task_chat_task (t.task_id)
    )
  );

create policy "task_chat_messages_insert"
  on public.task_chat_messages for insert
  with check (
    exists (
      select 1
      from public.task_chat_threads t
      where t.id = task_chat_messages.thread_id
        and public.can_access_task_chat_task (t.task_id)
    )
  );

create policy "task_chat_messages_delete_own_empty"
  on public.task_chat_messages for delete
  using (sender_user_id = auth.uid ());

-- attachments
create policy "task_chat_attachments_select"
  on public.task_chat_attachments for select
  using (
    exists (
      select 1
      from public.task_chat_messages m
      join public.task_chat_threads t on t.id = m.thread_id
      where m.id = task_chat_attachments.message_id
        and public.can_access_task_chat_task (t.task_id)
    )
  );

create policy "task_chat_attachments_insert"
  on public.task_chat_attachments for insert
  with check (
    exists (
      select 1
      from public.task_chat_messages m
      where m.id = task_chat_attachments.message_id
        and m.sender_user_id = auth.uid ()
    )
  );

-- reads
create policy "task_chat_reads_select"
  on public.task_chat_reads for select
  using (user_id = auth.uid () or public.is_task_admin ());

create policy "task_chat_reads_upsert_own"
  on public.task_chat_reads for insert
  with check (user_id = auth.uid ());

create policy "task_chat_reads_update_own"
  on public.task_chat_reads for update
  using (user_id = auth.uid ())
  with check (user_id = auth.uid ());

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------

grant select, insert, delete on table public.task_chat_threads to authenticated;
grant select, insert, delete on table public.task_chat_messages to authenticated;
grant select, insert on table public.task_chat_attachments to authenticated;
grant select, insert, update on table public.task_chat_reads to authenticated;

-- ---------------------------------------------------------------------------
-- Storage bucket (private)
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public)
values ('task-chat-media', 'task-chat-media', false)
on conflict (id) do nothing;

-- Path: tasks/<task_uuid>/...
create policy "task_chat_media_read"
  on storage.objects for select
  using (
    bucket_id = 'task-chat-media'
    and coalesce ((storage.foldername (name))[1], '') = 'tasks'
    and public.can_access_task_chat_task (((storage.foldername (name))[2])::uuid)
  );

create policy "task_chat_media_write"
  on storage.objects for insert
  with check (
    bucket_id = 'task-chat-media'
    and coalesce ((storage.foldername (name))[1], '') = 'tasks'
    and public.can_access_task_chat_task (((storage.foldername (name))[2])::uuid)
  );

create policy "task_chat_media_update"
  on storage.objects for update
  using (
    bucket_id = 'task-chat-media'
    and coalesce ((storage.foldername (name))[1], '') = 'tasks'
    and public.can_access_task_chat_task (((storage.foldername (name))[2])::uuid)
  );

create policy "task_chat_media_delete"
  on storage.objects for delete
  using (
    bucket_id = 'task-chat-media'
    and coalesce ((storage.foldername (name))[1], '') = 'tasks'
    and public.can_access_task_chat_task (((storage.foldername (name))[2])::uuid)
  );

-- ---------------------------------------------------------------------------
-- Realtime (new messages for open thread)
-- ---------------------------------------------------------------------------

alter publication supabase_realtime add table public.task_chat_messages;

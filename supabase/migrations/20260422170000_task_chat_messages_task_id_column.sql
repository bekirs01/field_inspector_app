-- Denormalized task_id on task_chat_messages (required by mobile + web inserts).
-- Fixes Postgres 23502: null value in column "task_id" ... violates not-null constraint
-- when the column exists in production but was not in the original 20260417140000 migration.
--
-- Safe to re-run.

alter table public.task_chat_messages
  add column if not exists task_id uuid references public.inspection_tasks (id) on delete cascade;

update public.task_chat_messages m
set task_id = t.task_id
from public.task_chat_threads t
where m.thread_id = t.id
  and m.task_id is null;

-- Set NOT NULL only when no orphan rows remain (orphans need manual cleanup).
do $$
begin
  if not exists (
    select 1
    from public.task_chat_messages
    where task_id is null
  ) then
    alter table public.task_chat_messages
      alter column task_id set not null;
  end if;
end $$;

create index if not exists task_chat_messages_task_id_idx
  on public.task_chat_messages (task_id);

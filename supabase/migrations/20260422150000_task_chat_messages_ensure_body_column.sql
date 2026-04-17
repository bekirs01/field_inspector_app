-- Align public.task_chat_messages with the mobile app contract (column: body).
-- Fixes PostgREST PGRST204: "Could not find the 'body' column ... in the schema cache"
-- when the table was created manually or from an older naming convention.
--
-- Strategy (idempotent):
-- - If `body` already exists: no-op.
-- - Else if a legacy text column exists: rename it to `body` (preserves data + web reads same name).
-- - Else: add `body text not null default ''`.
--
-- Safe to re-run.

do $$
begin
  if not exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'task_chat_messages'
  ) then
    raise notice 'task_chat_messages: table missing; apply 20260417140000_task_chat.sql first';
    return;
  end if;

  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'task_chat_messages'
      and column_name = 'body'
  ) then
    return;
  end if;

  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'task_chat_messages'
      and column_name = 'content'
  ) then
    alter table public.task_chat_messages rename column content to body;
  elsif exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'task_chat_messages'
      and column_name = 'message'
  ) then
    alter table public.task_chat_messages rename column message to body;
  elsif exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'task_chat_messages'
      and column_name = 'message_text'
  ) then
    alter table public.task_chat_messages rename column message_text to body;
  elsif exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'task_chat_messages'
      and column_name = 'text'
  ) then
    alter table public.task_chat_messages rename column text to body;
  else
    alter table public.task_chat_messages
      add column body text not null default '';
  end if;
end $$;

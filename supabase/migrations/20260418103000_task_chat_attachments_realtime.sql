-- So clients can refresh message bubbles when a row appears in task_chat_attachments
-- shortly after task_chat_messages (photo upload flow).
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'task_chat_attachments'
  ) then
    alter publication supabase_realtime add table public.task_chat_attachments;
  end if;
end $$;

-- Fix 42501 on task_chat_attachments INSERT when the WITH CHECK subquery on
-- task_chat_messages is evaluated under row security and fails to "see" the
-- parent message row (mobile: PostgrestException row-level security).
--
-- Uses a SECURITY DEFINER helper so ownership + task access are verified without
-- depending on RLS-in-subquery visibility quirks.

create or replace function public.task_chat_can_insert_attachment_for_message (
  p_message_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.task_chat_messages m
    inner join public.task_chat_threads t on t.id = m.thread_id
    where m.id = p_message_id
      and m.sender_user_id = auth.uid ()
      and public.can_access_task_chat_task (t.task_id)
  );
$$;

revoke all on function public.task_chat_can_insert_attachment_for_message (uuid)
from public;

grant execute on function public.task_chat_can_insert_attachment_for_message (uuid)
to authenticated;

drop policy if exists "task_chat_attachments_insert"
  on public.task_chat_attachments;

create policy "task_chat_attachments_insert"
  on public.task_chat_attachments for insert
  with check (
    public.task_chat_can_insert_attachment_for_message (message_id)
  );

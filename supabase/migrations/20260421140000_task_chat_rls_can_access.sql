-- Align task chat RLS helper with mobile app expectations.
-- If only 20260417140000_task_chat.sql was applied, can_access_task_chat_task()
-- required inspection_task_assignments.is_active = true, blocking INSERT/SELECT
-- for archived/completed assignments. The app uses task_chat_threads / task_chat_messages
-- with policies that call this function.
--
-- Safe to re-run: replaces function only.

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
    )
    or exists (
      select 1
      from public.task_chat_threads t
      inner join public.task_chat_messages m on m.thread_id = t.id
      where t.task_id = p_task_id
        and m.sender_user_id = auth.uid ()
    );
$$;

revoke all on function public.can_access_task_chat_task (uuid) from public;
grant execute on function public.can_access_task_chat_task (uuid) to authenticated;

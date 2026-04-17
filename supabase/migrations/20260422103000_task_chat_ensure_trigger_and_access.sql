-- Ensure task_chat message BEFORE INSERT trigger and chat access helper match the mobile app.
-- Fixes common production cases: table exists but trigger was never created, or
-- can_access_task_chat_task still requires is_active = true only.
--
-- Safe to re-run.

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

drop trigger if exists task_chat_messages_bi on public.task_chat_messages;
create trigger task_chat_messages_bi
  before insert on public.task_chat_messages
  for each row
  execute function public.task_chat_messages_before_insert ();

revoke all on function public.task_chat_messages_before_insert () from public;
grant execute on function public.task_chat_messages_before_insert () to authenticated;

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

-- Allow workers to read task chat, tasks, and route items for any assignment row
-- (including archived / is_active = false), and when they participated in a thread.

-- ---------------------------------------------------------------------------
-- Chat access: any assignment for this worker on the task, OR sent a message in the thread
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
    )
    or exists (
      select 1
      from public.task_chat_threads t
      inner join public.task_chat_messages m on m.thread_id = t.id
      where t.task_id = p_task_id
        and m.sender_user_id = auth.uid ()
    );
$$;

-- ---------------------------------------------------------------------------
-- Tasks / items: worker can read inspection data if they have any assignment row
-- (not only is_active = true), so archive/history UIs and chat headers work.
-- ---------------------------------------------------------------------------

drop policy if exists "inspection_tasks_select_worker_assigned"
  on public.inspection_tasks;

create policy "inspection_tasks_select_worker_assigned"
  on public.inspection_tasks for select
  using (
    exists (
      select 1
      from public.inspection_task_assignments a
      where a.task_id = inspection_tasks.id
        and a.worker_user_id = auth.uid ()
    )
  );

drop policy if exists "inspection_task_items_select_worker_assigned"
  on public.inspection_task_items;

create policy "inspection_task_items_select_worker_assigned"
  on public.inspection_task_items for select
  using (
    exists (
      select 1
      from public.inspection_task_assignments a
      where a.task_id = inspection_task_items.task_id
        and a.worker_user_id = auth.uid ()
    )
  );

-- Optional: task metadata when the worker posted in chat but assignment was removed
create policy "inspection_tasks_select_worker_chat_participant"
  on public.inspection_tasks for select
  using (
    exists (
      select 1
      from public.task_chat_threads t
      inner join public.task_chat_messages m on m.thread_id = t.id
      where t.task_id = inspection_tasks.id
        and m.sender_user_id = auth.uid ()
    )
  );

create policy "inspection_task_items_select_worker_chat_participant"
  on public.inspection_task_items for select
  using (
    exists (
      select 1
      from public.task_chat_threads t
      inner join public.task_chat_messages m on m.thread_id = t.id
      where t.task_id = inspection_task_items.task_id
        and m.sender_user_id = auth.uid ()
    )
  );

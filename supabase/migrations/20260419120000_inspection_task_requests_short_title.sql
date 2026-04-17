-- Align worker request inserts with mobile contract: `short_title` (not `title`).
-- Idempotent: if `short_title` already exists, no-op; else rename legacy `title`.

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'inspection_task_requests'
      and column_name = 'short_title'
  ) then
    return;
  end if;

  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'inspection_task_requests'
      and column_name = 'title'
  ) then
    alter table public.inspection_task_requests
      rename column title to short_title;
  end if;
end $$;

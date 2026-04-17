-- Worker task requests: explicit request_type and desired_due_at (mobile + admin contract).

do $$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'inspection_task_requests'
      and column_name = 'request_type'
  ) then
    alter table public.inspection_task_requests
      add column request_type text not null default 'inspection'
        constraint inspection_task_requests_request_type_check
        check (
          request_type in ('inspection', 'maintenance', 'defect', 'repair')
        );
  end if;
end $$;

do $$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'inspection_task_requests'
      and column_name = 'desired_due_at'
  ) then
    alter table public.inspection_task_requests
      add column desired_due_at timestamptz;
  end if;
end $$;

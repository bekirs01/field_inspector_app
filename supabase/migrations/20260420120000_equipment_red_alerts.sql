-- Critical equipment / machine red alerts from mobile workers.

create table public.equipment_red_alerts (
  id uuid primary key default gen_random_uuid (),
  equipment_id uuid not null,
  equipment_name text not null,
  site_name text,
  area_name text,
  task_id uuid references public.inspection_tasks (id) on delete set null,
  triggered_by uuid not null references auth.users (id) on delete cascade,
  triggered_by_name text,
  source text not null default 'worker_manual',
  severity text not null default 'critical',
  title text not null,
  description text not null default '',
  status text not null default 'open',
  acknowledged_by uuid references auth.users (id),
  acknowledged_at timestamptz,
  resolved_by uuid references auth.users (id),
  resolved_at timestamptz,
  created_at timestamptz not null default now (),
  updated_at timestamptz not null default now (),
  constraint equipment_red_alerts_severity_chk check (
    severity in ('critical', 'high', 'medium', 'low')
  ),
  constraint equipment_red_alerts_status_chk check (
    status in ('open', 'acknowledged', 'resolved', 'cancelled')
  )
);

create index equipment_red_alerts_triggered_by_created_idx
  on public.equipment_red_alerts (triggered_by, created_at desc);

create index equipment_red_alerts_equipment_id_idx
  on public.equipment_red_alerts (equipment_id);

create index equipment_red_alerts_status_created_idx
  on public.equipment_red_alerts (status, created_at desc);

create or replace function public.equipment_red_alerts_set_updated_at ()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger equipment_red_alerts_updated_at
  before update on public.equipment_red_alerts
  for each row
  execute function public.equipment_red_alerts_set_updated_at ();

alter table public.equipment_red_alerts enable row level security;

create policy "equipment_red_alerts_select_own"
  on public.equipment_red_alerts for select
  using (triggered_by = auth.uid ());

create policy "equipment_red_alerts_select_admin"
  on public.equipment_red_alerts for select
  using (public.is_task_admin ());

create policy "equipment_red_alerts_insert_worker"
  on public.equipment_red_alerts for insert
  with check (
    triggered_by = auth.uid ()
    and exists (
      select 1
      from public.profiles p
      where p.id = auth.uid ()
        and p.role = 'worker'
        and p.is_active = true
    )
  );

create policy "equipment_red_alerts_update_admin"
  on public.equipment_red_alerts for update
  using (public.is_task_admin ())
  with check (public.is_task_admin ());

grant select, insert on table public.equipment_red_alerts to authenticated;

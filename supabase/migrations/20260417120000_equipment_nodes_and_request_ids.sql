-- equipment_nodes: hierarchy for worker task-request picker (aligns with web «Объекты»).
-- inspection_task_requests.equipment_node_ids: structured link to selected nodes (optional but recommended).

-- ---------------------------------------------------------------------------
-- equipment_nodes
-- ---------------------------------------------------------------------------

create table if not exists public.equipment_nodes (
  id uuid primary key default gen_random_uuid (),
  parent_id uuid references public.equipment_nodes (id) on delete set null,
  name text not null,
  node_type text not null check (
    node_type in ('plant', 'site', 'workshop', 'section', 'equipment')
  ),
  is_active boolean not null default true,
  created_at timestamptz not null default now ()
);

create index if not exists equipment_nodes_parent_idx on public.equipment_nodes (parent_id);

create index if not exists equipment_nodes_active_type_idx
  on public.equipment_nodes (is_active, node_type);

-- ---------------------------------------------------------------------------
-- inspection_task_requests: selected equipment (Postgres uuid[])
-- ---------------------------------------------------------------------------

do $$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'inspection_task_requests'
      and column_name = 'equipment_node_ids'
  ) then
    alter table public.inspection_task_requests
      add column equipment_node_ids uuid[];
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- RLS: workers read active nodes only
-- ---------------------------------------------------------------------------

alter table public.equipment_nodes enable row level security;

drop policy if exists "equipment_nodes_select_authenticated" on public.equipment_nodes;

create policy "equipment_nodes_select_authenticated"
  on public.equipment_nodes for select
  to authenticated
  using (is_active = true);

grant select on table public.equipment_nodes to authenticated;

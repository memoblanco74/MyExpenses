create table transactions (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users(id),
  date date not null,
  type text not null,
  category text,
  amount numeric not null,
  notes text,
  method text not null,
  created_at timestamptz not null default now()
);

create table cc_plans (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users(id),
  item_name text not null,
  total_amount numeric not null,
  months integer not null,
  monthly_payment numeric not null,
  start_date date not null,
  status text not null default 'Active'
);

create table fixed_expenses (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users(id),
  category text not null,
  name text not null,
  amount numeric not null
);

create table budgets (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users(id),
  category text not null,
  budget_limit numeric not null,
  is_recurring boolean not null default false,
  unique (user_id, category)
);

create table categories (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users(id),
  name text not null,
  icon text not null default '📦',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  unique (user_id, name)
);

alter table transactions enable row level security;
alter table cc_plans enable row level security;
alter table fixed_expenses enable row level security;
alter table budgets enable row level security;
alter table categories enable row level security;

create policy "owner_all_transactions" on transactions
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "owner_all_cc_plans" on cc_plans
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "owner_all_fixed_expenses" on fixed_expenses
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "owner_all_budgets" on budgets
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "owner_all_categories" on categories
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create index idx_transactions_date on transactions(date);
create index idx_transactions_category on transactions(category);
create index idx_cc_plans_status on cc_plans(status);


alter table budgets add column if not exists is_recurring boolean not null default false;

create table if not exists categories (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users(id),
  name text not null,
  icon text not null default '📦',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  unique (user_id, name)
);

alter table categories enable row level security;

drop policy if exists "owner_all_categories" on categories;
create policy "owner_all_categories" on categories
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ==========================================
-- Migration for existing databases (run once if you already created
-- your tables before these features were added):
-- alter table budgets add column if not exists is_recurring boolean not null default false;
--
-- create table if not exists categories (
--   id bigint generated always as identity primary key,
--   user_id uuid not null default auth.uid() references auth.users(id),
--   name text not null,
--   icon text not null default '📦',
--   sort_order integer not null default 0,
--   created_at timestamptz not null default now(),
--   unique (user_id, name)
-- );
-- alter table categories enable row level security;
-- create policy "owner_all_categories" on categories
--   for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
-- The app auto-fills this table with your existing categories the
-- first time you open it after the migration, so you don't lose them.
-- ==========================================

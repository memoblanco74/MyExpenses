alter table fixed_expenses add column if not exists is_pinned boolean not null default false;

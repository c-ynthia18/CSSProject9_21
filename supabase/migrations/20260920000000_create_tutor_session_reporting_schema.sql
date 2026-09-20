-- Tutor Session Reporting schema
-- This migration intentionally does not enable RLS or create authentication rules.
-- Authentication and production authorization policies will be added separately.

create extension if not exists pgcrypto;

create table public.tutors (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) > 0),
  created_at timestamptz not null default now()
);

create table public.students (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) > 0),
  created_at timestamptz not null default now()
);

-- Assignment records preserve a student's tutor history by year.
create table public.tutor_student_assignments (
  id uuid primary key default gen_random_uuid(),
  tutor_id uuid not null references public.tutors(id) on delete restrict,
  student_id uuid not null references public.students(id) on delete restrict,
  assignment_year integer not null check (assignment_year between 2000 and 2100),
  assigned_at timestamptz not null default now(),
  ended_at timestamptz,
  constraint tutor_student_assignments_dates_check
    check (ended_at is null or ended_at >= assigned_at),
  constraint tutor_student_assignments_unique
    unique (tutor_id, student_id, assignment_year)
);

-- A student may have only one active tutor assignment in a given year.
create unique index tutor_student_assignments_one_active_tutor_per_year
  on public.tutor_student_assignments (student_id, assignment_year)
  where ended_at is null;

create index tutor_student_assignments_tutor_year_idx
  on public.tutor_student_assignments (tutor_id, assignment_year);

create index tutor_student_assignments_student_year_idx
  on public.tutor_student_assignments (student_id, assignment_year);

create table public.sessions (
  id uuid primary key default gen_random_uuid(),
  tutor_id uuid not null references public.tutors(id) on delete restrict,
  student_id uuid not null references public.students(id) on delete restrict,
  session_date date not null,
  start_time time not null,
  end_time time not null,
  created_at timestamptz not null default now(),
  constraint sessions_time_order_check check (end_time > start_time)
);

create index sessions_tutor_date_idx on public.sessions (tutor_id, session_date);
create index sessions_student_date_idx on public.sessions (student_id, session_date);
create index sessions_student_tutor_date_idx
  on public.sessions (student_id, tutor_id, session_date);

-- Ensures every session is recorded against an assignment active for the
-- selected tutor, student, and calendar year on the session date.
create or replace function public.validate_session_assignment()
returns trigger
language plpgsql
as $$
begin
  if not exists (
    select 1
    from public.tutor_student_assignments as assignment
    where assignment.tutor_id = new.tutor_id
      and assignment.student_id = new.student_id
      and assignment.assignment_year = extract(year from new.session_date)::integer
      and assignment.assigned_at::date <= new.session_date
      and (assignment.ended_at is null or assignment.ended_at::date >= new.session_date)
  ) then
    raise exception
      'A session must reference an active tutor/student assignment for its date';
  end if;

  return new;
end;
$$;

create trigger validate_session_assignment_before_write
before insert or update of tutor_id, student_id, session_date
on public.sessions
for each row
execute function public.validate_session_assignment();

create table public.goals (
  id uuid primary key default gen_random_uuid(),
  name text not null unique check (char_length(trim(name)) > 0),
  created_at timestamptz not null default now()
);

create table public.session_goals (
  session_id uuid not null references public.sessions(id) on delete cascade,
  goal_id uuid not null references public.goals(id) on delete restrict,
  other_text text,
  primary key (session_id, goal_id),
  constraint session_goals_other_text_check
    check (other_text is null or char_length(trim(other_text)) > 0)
);

create index session_goals_goal_idx on public.session_goals (goal_id);

-- Stable reference data; this is not application demo data.
insert into public.goals (name) values
  ('Enter Employment'),
  ('Retain Employment'),
  ('Leave Public Assistance'),
  ('Achieve Work-Based Project Learner Goal'),
  ('Enter Occupational Skills Training Program'),
  ('Enter Postsecondary Education'),
  ('Obtain High School Diploma'),
  ('Help More Frequently With School'),
  ('Increase Contact With Children''s Teacher'),
  ('More Involvement in Children''s School Activities'),
  ('Purchase Books or Magazines'),
  ('Read to Children'),
  ('Visit the Library'),
  ('Obtain Citizenship'),
  ('Achieve Civics Skills'),
  ('Increase Involvement in Community Activities'),
  ('Vote or Register to Vote'),
  ('Other')
on conflict (name) do nothing;

-- Duration is always calculated from time fields, never manually entered.
create view public.session_reporting as
select
  s.id,
  s.tutor_id,
  s.student_id,
  s.session_date,
  s.start_time,
  s.end_time,
  s.end_time - s.start_time as duration,
  s.created_at
from public.sessions as s;

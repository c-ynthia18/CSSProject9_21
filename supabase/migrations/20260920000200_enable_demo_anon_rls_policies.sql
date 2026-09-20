-- Temporary public-demo RLS policies.
-- These intentionally permit the anon role to access fictional portfolio data.
-- Remove and replace every policy named demo_anon_* before production use.
-- No Supabase Auth, roles, or authenticated policies are introduced here.

alter table public.tutors enable row level security;
alter table public.students enable row level security;
alter table public.tutor_student_assignments enable row level security;
alter table public.sessions enable row level security;
alter table public.session_goals enable row level security;
alter table public.goals enable row level security;

create policy "demo_anon_tutors_select"
  on public.tutors for select to anon using (true);
create policy "demo_anon_tutors_insert"
  on public.tutors for insert to anon with check (true);

create policy "demo_anon_students_select"
  on public.students for select to anon using (true);
create policy "demo_anon_students_insert"
  on public.students for insert to anon with check (true);

create policy "demo_anon_assignments_select"
  on public.tutor_student_assignments for select to anon using (true);
create policy "demo_anon_assignments_insert"
  on public.tutor_student_assignments for insert to anon with check (true);

create policy "demo_anon_sessions_select"
  on public.sessions for select to anon using (true);
create policy "demo_anon_sessions_insert"
  on public.sessions for insert to anon with check (true);

create policy "demo_anon_session_goals_select"
  on public.session_goals for select to anon using (true);
create policy "demo_anon_session_goals_insert"
  on public.session_goals for insert to anon with check (true);

create policy "demo_anon_goals_select"
  on public.goals for select to anon using (true);

-- public.session_reporting is a view and cannot have an RLS policy of its own.
-- Its existing SELECT grant permits demo reads. Before the demo policies are
-- replaced with private policies, review the view's security behavior as well.
-- Do not add UPDATE or DELETE policies for this demo role.

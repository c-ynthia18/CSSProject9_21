-- Prototype-only browser access for the Supabase publishable/anonymous role.
-- No RLS policies or authentication rules are created in this migration.
-- Replace these broad anonymous permissions with authenticated, role-scoped RLS
-- policies before deploying the application to production.

-- Allows the Supabase Data API to resolve the public schema for anon requests.
grant usage on schema public to anon;

-- Current application workflows read lists/reports and create tutors, students,
-- assignments, sessions, and session-goal records. They do not edit or delete.
grant select, insert on table public.tutors to anon;
grant select, insert on table public.students to anon;
grant select, insert on table public.tutor_student_assignments to anon;
grant select, insert on table public.sessions to anon;
grant select, insert on table public.session_goals to anon;

-- Goal choices and the calculated-duration reporting view are read-only in the app.
grant select on table public.goals to anon;
grant select on table public.session_reporting to anon;

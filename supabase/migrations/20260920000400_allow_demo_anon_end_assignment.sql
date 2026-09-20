-- Temporary public-demo permission for the explicit Admin “No Longer a Student” action.
-- Remove this grant and policy with the other demo_anon_* policies before production.
-- It permits changing only ended_at on an assignment that is currently active.

grant update (ended_at) on table public.tutor_student_assignments to anon;

create policy "demo_anon_assignments_end_only_update"
  on public.tutor_student_assignments
  for update
  to anon
  using (ended_at is null)
  with check (ended_at is not null);

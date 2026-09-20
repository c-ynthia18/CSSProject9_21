-- Historical session migration support.
-- A tutor/student assignment establishes the relationship, but its creation
-- timestamp and assignment year must not prevent importing older sessions.
-- The enrollment end date remains the latest permitted session date.

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
      and (
        assignment.ended_at is null
        or assignment.ended_at::date >= new.session_date
      )
  ) then
    raise exception
      'A session must reference a matching tutor/student assignment and cannot be dated after enrollment ended';
  end if;

  return new;
end;
$$;

-- Persists the existing free-form Tutor Contact Information UI field.
-- Nullable so existing tutor records and tutors without contact details remain valid.
alter table public.tutors
  add column contact text;

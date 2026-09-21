-- Add ExampleStudent4 and their demo activity to the permanent
-- hourly-reset baseline.

create or replace function public.reset_portfolio_demo_data()
returns void
language plpgsql
security definer
set search_path = ''
as $function$
begin
  -- Remove only resettable demo data, from dependents to referenced rows.
  delete from public.session_goals;
  delete from public.sessions;
  delete from public.tutor_student_assignments;
  delete from public.students;
  delete from public.tutors;

  insert into public.tutors (id, name, contact, created_at) values
    ('5e3bc1e9-b25e-4701-870c-3febef5428ab', 'ExampleTutor1', 'exampleEmail@email.com', '2026-09-20T11:57:10.756002-04:00'),
    ('d218054a-b390-4138-b8d0-da1cf584632f', 'ExampleTutor2', 'exampleEmail02@email.com', '2026-09-20T13:34:33.507674-04:00');

  insert into public.students (id, name, created_at) values
    ('0bc5fb1c-5bdb-40db-b9d3-1636f73accea', 'Tutor2_Student01', '2026-09-20T13:35:08.595375-04:00'),
    ('0d499d05-38e4-4f8a-a225-db19c1786d28', 'ExampleStudent2', '2026-09-20T13:33:52.668124-04:00'),
    ('39a7fc4d-6a70-4b0a-a0f7-c64889bf602f', 'Tutor2_Student02', '2026-09-20T13:35:17.736736-04:00'),
    ('9610e14f-ee9c-4acc-888d-d8276e10157e', 'ExampleStudent1', '2026-09-20T11:57:48.986211-04:00'),
    ('bb6c1e03-e7b3-488c-b991-88e21e1bb89e', 'ExampleStudent3', '2026-09-20T13:34:05.362386-04:00'),
    ('ac0c6b6d-2e3d-43e4-b57b-c2b78bcf1673', 'ExampleStudent4', '2026-09-21T15:03:35.749991+00');

  insert into public.tutor_student_assignments
    (id, tutor_id, student_id, assignment_year, assigned_at, ended_at)
  values
    ('018cc474-dd95-491a-b5c8-4b380fbffe04', 'd218054a-b390-4138-b8d0-da1cf584632f', '0bc5fb1c-5bdb-40db-b9d3-1636f73accea', 2026, '2026-09-20T13:35:08.671423-04:00', null),
    ('1c00e8a3-ece6-48e4-b9d8-f69e1eb1edcf', 'd218054a-b390-4138-b8d0-da1cf584632f', '39a7fc4d-6a70-4b0a-a0f7-c64889bf602f', 2026, '2026-09-20T13:35:17.775237-04:00', null),
    ('3410ce33-f2ff-4e6d-a0c7-beb8c13ed1c7', '5e3bc1e9-b25e-4701-870c-3febef5428ab', '0d499d05-38e4-4f8a-a225-db19c1786d28', 2026, '2026-09-20T13:33:52.73882-04:00', '2026-09-20T13:35:55.056-04:00'),
    ('9d864be1-6073-4cef-990f-fb10e66bb0a9', '5e3bc1e9-b25e-4701-870c-3febef5428ab', '9610e14f-ee9c-4acc-888d-d8276e10157e', 2026, '2026-09-20T11:57:49.16613-04:00', null),
    ('df7cc353-f939-4f42-a8a0-0cb78556774e', '5e3bc1e9-b25e-4701-870c-3febef5428ab', 'bb6c1e03-e7b3-488c-b991-88e21e1bb89e', 2026, '2026-09-20T13:34:05.4534-04:00', null),
    ('0054b52f-fcc9-421c-a965-c4ec9d861e0d', '5e3bc1e9-b25e-4701-870c-3febef5428ab', 'ac0c6b6d-2e3d-43e4-b57b-c2b78bcf1673', 2026, '2026-09-21T15:03:35.864066+00', null);

  insert into public.sessions
    (id, tutor_id, student_id, session_date, start_time, end_time, created_at)
  values
    ('3ae265b5-6051-4d18-a526-361317539379', '5e3bc1e9-b25e-4701-870c-3febef5428ab', '9610e14f-ee9c-4acc-888d-d8276e10157e', '2026-09-23', '11:00:00', '13:30:00', '2026-09-20T12:33:48.686667-04:00'),
    ('513cf41d-29f1-4d28-a43d-d40bce77b7b9', '5e3bc1e9-b25e-4701-870c-3febef5428ab', '9610e14f-ee9c-4acc-888d-d8276e10157e', '2026-09-20', '18:30:00', '20:00:00', '2026-09-20T12:09:46.303777-04:00'),
    ('749fbb6a-4de5-4f89-857d-40e3cf20fdba', '5e3bc1e9-b25e-4701-870c-3febef5428ab', 'bb6c1e03-e7b3-488c-b991-88e21e1bb89e', '2026-09-25', '14:20:00', '16:50:00', '2026-09-20T13:46:47.574457-04:00'),
    ('86efe720-6f6e-4984-bdfa-7b3b29a86b88', 'd218054a-b390-4138-b8d0-da1cf584632f', '39a7fc4d-6a70-4b0a-a0f7-c64889bf602f', '2026-09-22', '13:22:00', '17:30:00', '2026-09-20T13:38:39.310345-04:00'),
    ('87b6e9b3-d02c-438e-988f-ba4ccb691439', '5e3bc1e9-b25e-4701-870c-3febef5428ab', '9610e14f-ee9c-4acc-888d-d8276e10157e', '2026-09-21', '12:00:00', '15:00:00', '2026-09-20T12:32:29.490659-04:00'),
    ('8e0fb2bb-33f5-4544-8728-6dcf2bec3b34', 'd218054a-b390-4138-b8d0-da1cf584632f', '0bc5fb1c-5bdb-40db-b9d3-1636f73accea', '2026-09-21', '14:20:00', '16:30:00', '2026-09-20T13:38:09.438443-04:00'),
    ('fc507e09-d7bc-48f7-b71a-b3463a3ab668', '5e3bc1e9-b25e-4701-870c-3febef5428ab', 'bb6c1e03-e7b3-488c-b991-88e21e1bb89e', '2026-09-22', '11:20:00', '12:20:00', '2026-09-20T13:46:12.392356-04:00'),
    ('4bcfd18c-c896-479f-849d-e1a1d77e4588', '5e3bc1e9-b25e-4701-870c-3febef5428ab', 'ac0c6b6d-2e3d-43e4-b57b-c2b78bcf1673', '2024-07-01', '12:00:00', '14:00:00', '2026-09-21T15:04:21.860631+00');

  insert into public.session_goals (session_id, goal_id, other_text) values
    ('513cf41d-29f1-4d28-a43d-d40bce77b7b9', '464c615e-8c2c-45c2-a00a-847ff7eb57f0', null),
    ('749fbb6a-4de5-4f89-857d-40e3cf20fdba', '11d927b7-d45e-46c2-b40c-a73dcde0901f', null),
    ('749fbb6a-4de5-4f89-857d-40e3cf20fdba', '9edd5ebe-262f-4dc1-abd0-6011ad0bd2e8', null),
    ('749fbb6a-4de5-4f89-857d-40e3cf20fdba', 'aeb60f05-e29d-40dc-a0c7-3f4001c0bfb2', null),
    ('86efe720-6f6e-4984-bdfa-7b3b29a86b88', '74148c46-a317-4176-a9aa-457f8c33a7c6', null),
    ('86efe720-6f6e-4984-bdfa-7b3b29a86b88', 'c1280e4b-c79b-41d1-a57b-13381145bccd', null),
    ('87b6e9b3-d02c-438e-988f-ba4ccb691439', '464c615e-8c2c-45c2-a00a-847ff7eb57f0', null),
    ('87b6e9b3-d02c-438e-988f-ba4ccb691439', '9edd5ebe-262f-4dc1-abd0-6011ad0bd2e8', null),
    ('8e0fb2bb-33f5-4544-8728-6dcf2bec3b34', '464c615e-8c2c-45c2-a00a-847ff7eb57f0', null),
    ('4bcfd18c-c896-479f-849d-e1a1d77e4588', '464c615e-8c2c-45c2-a00a-847ff7eb57f0', null);

end;
$function$;

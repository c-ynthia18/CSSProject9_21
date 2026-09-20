(function createSupabaseDataAccess() {
  function getClient() {
    if (!window.supabaseClient) {
      throw new Error("Supabase client is unavailable. Check supabase-config.js and script load order.");
    }

    return window.supabaseClient;
  }

  function requireId(value, helperName) {
    if (typeof value !== "string" || value.trim() === "") {
      throw new TypeError(`${helperName} requires a non-empty Supabase UUID string.`);
    }
  }

  async function read(operation, query) {
    const { data, error } = await query;

    if (error) {
      throw new Error(`Supabase ${operation} failed: ${error.message}`);
    }

    return data ?? [];
  }

  async function getTutors() {
    return read(
      "getTutors",
      getClient()
        .from("tutors")
        .select("id, name, contact, created_at")
        .order("name", { ascending: true })
    );
  }

  async function getGoals() {
    return read(
      "getGoals",
      getClient()
        .from("goals")
        .select("id, name, created_at")
        .order("created_at", { ascending: true })
    );
  }

  async function getAssignmentsForTutor(tutorId) {
    requireId(tutorId, "getAssignmentsForTutor");

    return read(
      "getAssignmentsForTutor",
      getClient()
        .from("tutor_student_assignments")
        .select(`
          id,
          tutor_id,
          student_id,
          assignment_year,
          assigned_at,
          ended_at,
          student:students(id, name, created_at)
        `)
        .eq("tutor_id", tutorId)
        .order("assignment_year", { ascending: false })
        .order("assigned_at", { ascending: false })
    );
  }

  async function getSessionsForStudent(studentId) {
    requireId(studentId, "getSessionsForStudent");

    return read(
      "getSessionsForStudent",
      getClient()
        .from("session_reporting")
        .select("id, tutor_id, student_id, session_date, start_time, end_time, duration, created_at")
        .eq("student_id", studentId)
        .order("session_date", { ascending: false })
        .order("start_time", { ascending: false })
    );
  }

  async function getSessionsForTutor(tutorId) {
    requireId(tutorId, "getSessionsForTutor");

    return read(
      "getSessionsForTutor",
      getClient()
        .from("sessions")
        .select(`
          id,
          tutor_id,
          student_id,
          session_date,
          start_time,
          end_time,
          created_at,
          student:students(id, name)
        `)
        .eq("tutor_id", tutorId)
        .order("session_date", { ascending: false })
        .order("start_time", { ascending: false })
    );
  }

  async function getAllStudentsOverview() {
    const client = getClient();
    const [students, assignments, sessions] = await Promise.all([
      read(
        "getAllStudentsOverview students",
        client.from("students").select("id, name, created_at").order("name", { ascending: true })
      ),
      read(
        "getAllStudentsOverview assignments",
        client
          .from("tutor_student_assignments")
          .select(`
            id,
            tutor_id,
            student_id,
            assignment_year,
            assigned_at,
            ended_at,
            tutor:tutors(id, name)
          `)
          .order("assigned_at", { ascending: false })
      ),
      read(
        "getAllStudentsOverview sessions",
        client.from("sessions").select("student_id, session_date").order("session_date", { ascending: false })
      )
    ]);

    return { students, assignments, sessions };
  }

  // Student reports need selected goals alongside session history. This remains
  // separate from session_reporting because the duration view has no goal join.
  async function getSessionGoalsForStudent(studentId) {
    requireId(studentId, "getSessionGoalsForStudent");

    return read(
      "getSessionGoalsForStudent",
      getClient()
        .from("session_goals")
        .select(`
          session_id,
          goal_id,
          other_text,
          goal:goals(id, name),
          session:sessions!inner(id, student_id, session_date)
        `)
        .eq("sessions.student_id", studentId)
    );
  }

  async function createTutor({ name, contact }) {
    return read(
      "createTutor",
      getClient()
        .from("tutors")
        .insert({ name, contact: contact || null })
        .select("id, name, contact, created_at")
        .single()
    );
  }

  async function createStudent({ name }) {
    return read(
      "createStudent",
      getClient()
        .from("students")
        .insert({ name })
        .select("id, name, created_at")
        .single()
    );
  }

  async function createTutorStudentAssignment({ tutorId, studentId, assignmentYear }) {
    requireId(tutorId, "createTutorStudentAssignment");
    requireId(studentId, "createTutorStudentAssignment");

    if (!Number.isInteger(assignmentYear)) {
      throw new TypeError("createTutorStudentAssignment requires an integer assignment year.");
    }

    return read(
      "createTutorStudentAssignment",
      getClient()
        .from("tutor_student_assignments")
        .insert({
          tutor_id: tutorId,
          student_id: studentId,
          assignment_year: assignmentYear
        })
        .select("id, tutor_id, student_id, assignment_year, assigned_at, ended_at")
        .single()
    );
  }

  function requireDate(value, helperName) {
    if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(value)) {
      throw new TypeError(`${helperName} requires a session date in YYYY-MM-DD format.`);
    }
  }

  function requireTime(value, fieldName, helperName) {
    if (typeof value !== "string" || !/^\d{2}:\d{2}(?::\d{2})?$/.test(value)) {
      throw new TypeError(`${helperName} requires a valid ${fieldName}.`);
    }
  }

  async function createSession({ tutorId, studentId, sessionDate, startTime, endTime }) {
    requireId(tutorId, "createSession");
    requireId(studentId, "createSession");
    requireDate(sessionDate, "createSession");
    requireTime(startTime, "start time", "createSession");
    requireTime(endTime, "end time", "createSession");

    if (endTime <= startTime) {
      throw new RangeError("createSession requires an end time after the start time.");
    }

    return read(
      "createSession",
      getClient()
        .from("sessions")
        .insert({
          tutor_id: tutorId,
          student_id: studentId,
          session_date: sessionDate,
          start_time: startTime,
          end_time: endTime
        })
        .select("id, tutor_id, student_id, session_date, start_time, end_time, created_at")
        .single()
    );
  }

  async function createSessionGoals({ sessionId, goals }) {
    requireId(sessionId, "createSessionGoals");

    if (!Array.isArray(goals) || goals.length === 0) {
      throw new TypeError("createSessionGoals requires at least one selected goal.");
    }

    const goalIds = new Set();
    const rows = goals.map(({ goalId, otherText }) => {
      requireId(goalId, "createSessionGoals");
      if (goalIds.has(goalId)) {
        throw new TypeError("createSessionGoals cannot save the same goal more than once.");
      }
      goalIds.add(goalId);

      const trimmedOtherText = typeof otherText === "string" ? otherText.trim() : "";
      return {
        session_id: sessionId,
        goal_id: goalId,
        other_text: trimmedOtherText || null
      };
    });

    return read(
      "createSessionGoals",
      getClient()
        .from("session_goals")
        .insert(rows)
        .select("session_id, goal_id, other_text")
    );
  }

  async function endTutorStudentAssignment(assignmentId) {
    requireId(assignmentId, "endTutorStudentAssignment");

    return read(
      "endTutorStudentAssignment",
      getClient()
        .from("tutor_student_assignments")
        .update({ ended_at: new Date().toISOString() })
        .eq("id", assignmentId)
        .is("ended_at", null)
        .select("id, tutor_id, student_id, assignment_year, assigned_at, ended_at")
        .single()
    );
  }

  const dataAccess = Object.freeze({
    getTutors,
    getGoals,
    getAssignmentsForTutor,
    getSessionsForStudent,
    getSessionsForTutor,
    getAllStudentsOverview,
    getSessionGoalsForStudent,
    createTutor,
    createStudent,
    createTutorStudentAssignment,
    createSession,
    createSessionGoals,
    endTutorStudentAssignment
  });

  window.supabaseData = dataAccess;
  window.getTutors = getTutors;
  window.getGoals = getGoals;
  window.getAssignmentsForTutor = getAssignmentsForTutor;
  window.getSessionsForStudent = getSessionsForStudent;
  window.getSessionsForTutor = getSessionsForTutor;
  window.getAllStudentsOverview = getAllStudentsOverview;
  window.getSessionGoalsForStudent = getSessionGoalsForStudent;
})();

# Tutor Session Reporting

A web-based tutor session reporting system designed to simplify how tutoring programs track students, record tutoring sessions, and review program activity.

The application replaces a manual reporting workflow with a centralized system where tutors can record their sessions and administrators can manage tutors, students, and reports.

> **Demo Notice:** This website contains fictional demonstration data. Changes made to the demo are temporary, and the database automatically resets to its original demo data every hour.

No account or login is required to explore the demo.

## Main Features

### Tutor Dashboard

From the landing page, select **Tutor** and choose a tutor profile.

Tutors can:

- View their tutoring sessions on a monthly calendar
- Select an assigned student and record a new session
- Enter the session date, start time, and end time
- Select goals achieved during the session
- Add a custom goal using the **Other** option
- View previously recorded sessions
Session duration is automatically calculated from the start and end times.

### Admin Dashboard

Select **Admin** from the landing page to access program management features.

Administrators can:

- View all tutors
- Add new tutors
- View a tutor's current and previous students
- Add and assign new students
- Browse all students in the program
- Mark students as no longer enrolled
- Review individual student session histories
- View yearly tutoring activity and goals achieved
- Identify students who have not had a tutoring session within the past six months

Student and session history is preserved when a student is marked as no longer enrolled.

## Navigation

Start from the landing page and choose either **Tutor** or **Admin**.

**Tutor → Select Tutor → Calendar → Select Date → Record Session**

**Admin → Select Tutor → Current/Previous Students → Student Report**

Administrators can also use **All Students** to view enrollment status across the entire program.

## Technology

The application is built with:

- HTML
- CSS
- JavaScript
- Supabase / PostgreSQL
- Vercel
- Git / GitHub

Supabase provides persistent database storage for tutors, students, assignments, sessions, and session goals. Row Level Security (RLS) and restricted anonymous permissions are used for the public demo environment.

## Demo Data

All names, tutors, students, sessions, and other records included with this project are fictional and exist only for demonstration purposes.

Visitors are welcome to add or modify demo records while exploring the application.

**The demo database automatically resets every hour, any changes made through the website are temporary.**

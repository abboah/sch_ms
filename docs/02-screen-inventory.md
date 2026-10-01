# Screen inventory

Legend: W = web, M = mobile. T1/T2/T3 = rollout term from the spec.

## Shared
| Screen | W | M | Notes |
|---|---|---|---|
| Sign in | ✓ | ✓ | email + password, "forgot password"; SMS/OTP variant for parents |
| Role/school picker | ✓ | ✓ | only shown if an account has more than one role or school |
| Notifications centre | ✓ | ✓ | attendance, fees, homework, announcements |
| Profile and settings | ✓ | ✓ | contact details, notification channels (push/email/SMS), theme |

## Admin (web only, indigo)
| Screen | Term | Content |
|---|---|---|
| Overview | T1 | today's attendance rate, unmarked registers, fees outstanding, recent announcements |
| Students list + profile | T1 | search/filter by grade and section; profile with guardians, enrollment history, invoices |
| Enrollment | T1 | assign student to a class section; bulk import entry point (T3) |
| Class sections | T1 | list, create, assign homeroom teacher, roster |
| Staff | T1 | list and record (payroll T3) |
| Timetable and term calendar | T1 | weekly grid per section; term dates, holidays |
| Attendance reports | T1 | date range, section filter, export CSV/PDF register |
| Fees: structures and invoices | T2 | create fee structure, generate invoices, status filter |
| Payments reconciliation | T2 | payments list, unmatched payments, mark manual payment |
| Announcements and permission slips | T2 | compose, audience picker, responses tally |
| Messages audit | T2 | read-only list of all threads |
| Conference slots | T2 | create slots per teacher on the term calendar |
| Analytics | T3 | attendance and grade trends |
| Audit log | T1 | who read or changed which student record |

## Teacher (web + mobile, forest)
| Screen | W | M | Term |
|---|---|---|---|
| Today (my periods, unmarked registers) | ✓ | ✓ | T1 |
| Take attendance (period roster, P/L/A/E, "mark all present", offline banner) | ✓ | ✓ | T1 |
| Class overview (roster, attendance %, running average) | ✓ | ✓ | T1 |
| Gradebook (columns = assessments, weights, inline entry, running average) | ✓ | lite: one assessment at a time | T1 |
| New assessment | ✓ | ✓ | T1 |
| Report card comments (draft from grade history, edit, approve) | ✓ | | T1 |
| Homework (post, attach files, due date) | ✓ | ✓ | T2 |
| Messages (thread list, thread tied to a student) | ✓ | ✓ | T2 |
| Conference schedule | ✓ | ✓ | T2 |

## Parent (mobile primary, web lighter, brass)
| Screen | W | M | Term |
|---|---|---|---|
| Home (child switcher, today's attendance, homework due, latest grade, balance) | ✓ | ✓ | T1 |
| Attendance history (month calendar, list) | ✓ | ✓ | T1 |
| Grades (per subject, assessments, running grade) | ✓ | ✓ | T1 |
| Report cards | ✓ | ✓ | T1 |
| Homework | ✓ | ✓ | T2 |
| Fees (invoices, pay, receipts) | ✓ | ✓ | T2 |
| Payment flow (amount, method: card / mobile money, success and failure states) | ✓ | ✓ | T2 |
| Messages (thread per child/teacher) | ✓ | ✓ | T2 |
| Announcements | ✓ | ✓ | T2 |
| Book a conference (slot picker, confirmation) | ✓ | ✓ | T2 |

## Required states on every data screen
Loading skeleton, empty, error with retry, offline (teacher attendance and gradebook), and a read-only/locked state after a term closes.

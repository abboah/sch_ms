# Figma Make prompt: WEB

Paste everything below the line into Figma Make. If it is too long, paste Part A first, then send each portal section as a follow-up.

---

## Part A: Product and system

Design the **web app** for **Homeroom**, a school management platform with three role-based portals sharing one data core: **Admin/Registrar (indigo)**, **Teacher (forest green)**, **Parent/Guardian (brass)**. Build it as a **Next.js-friendly React app with Tailwind**, one route per screen, with realistic clickable navigation between screens, working tabs, filters and inline editing using the mock data below. Include a **light and dark theme** toggle.

**Look and feel:** a well-kept school register. Warm paper backgrounds, ink text, restrained colour, serif headings, monospaced data. No gradients, no glass effects, no stock illustrations, no emoji. Calm and dense enough for people scanning tables all day.

**Tokens (light / dark)**
- paper #E9EBE3 / #1A2027; raised surface #F4F5F0 / #212832; ink #1B2430 / #ECEAE0; soft ink #3C4650 / #C7CCC2; slate #5C6B66 / #9AA69E; border #C7CBBE / #3A4149
- Admin indigo #33507A / #8FADDD (tint #E4E9F1 / #262F3E)
- Teacher forest #2F5D50 / #82C0A7 (tint #E1EAE5 / #212C28)
- Parent brass #96692A / #D9A85C (tint #F1E6D2 / #2E2A1E)
- Alert red #8C3B3B / #D98080
- Fonts: **Fraunces** 600 for headings, **Source Sans 3** for UI and body, **IBM Plex Mono** for table headers, numbers, IDs and small uppercase labels (11px, 0.09em tracking)
- 3px corner radius, 1px borders, 3px accent top border on cards, pill shape only for status chips, tiny shadow only.

**App shell:** left sidebar (collapses to icons below 1024px) and a top bar with school name, search, notifications, theme toggle and user menu. The portal's accent colour drives active nav, primary buttons, chips and card top rules. A role switcher appears for accounts that hold more than one role.

**Status chips always carry a letter as well as colour:** P present (forest), L late (brass), A absent (red), E excused (slate).

**Required states on each data screen:** loading skeleton, empty (plain text), error with retry, and locked/read-only after a term closes. Teacher attendance and gradebook also show an offline banner variant.

**Mock data (use consistently):** School: Greenfield Academy, Kumasi. Term 1 2026, 7 Sep to 18 Dec. Currency GH¢. Admin: Esi Mensah. Teachers: Kwame Boateng (6A homeroom, Maths), Abena Owusu (6B homeroom, English), Yaw Darko (Science). Sections 6A (28 students) and 6B (27). Guardians: Akua Asante (children Kofi, 6A, and Ama, 4B), Nana Adjei (Yaa, 6A), Samuel Tetteh (Kojo, 6B), Efua Quaye (Nii, 6B). 6A students: Kofi Asante, Yaa Adjei, Kweku Sarpong, Adwoa Ofori, Kojo Bediako, Afia Nkrumah, Yaw Amoah, Serwaa Gyamfi. 6A Maths assessments: Quiz 1 (10%), Fractions test (25%), Project (20%), Midterm (45%, not yet scored); Kofi 8/10, 72/100, 15/20, running average 74.5%; Yaa 9/10, 88/100, 18/20, running average 89.1%. Invoices: Kofi tuition GH¢1,850, GH¢600 outstanding and overdue since 30 Sep; Ama paid GH¢1,650; Yaa unpaid GH¢1,850 due 15 Oct. Payment methods: Card, MTN MoMo, Telecel Cash. Announcement: mid-term break, closes Fri 23 Oct, reopens Mon 2 Nov. Conference slots: Kwame Boateng, Sat 24 Oct, 09:00 to 12:00, 15-minute slots, 09:15 booked by Akua Asante.

## Part B: Admin screens (indigo)
Sign in; Overview (today's attendance rate, unmarked registers, fees outstanding, recent announcements); Students list with search and grade/section filters; Student profile (guardians, enrollment history, invoices, audit of who viewed the record); Enrollment (assign a student to a section); Class sections (list, create, assign homeroom teacher, roster); Staff list and record; Timetable (weekly grid per section) and term calendar; Attendance reports (date range, section filter, export CSV/PDF); Fee structures and invoices; Payments reconciliation (including an unmatched payment and a pending one); Announcements and permission slips (compose, audience picker, response tally); Messages audit (read-only threads); Conference slot setup; Analytics (attendance and grade trends); Audit log (who read or changed which student record).

## Part C: Teacher screens (forest)
Today (my periods, unmarked registers called out); **Take attendance** (period roster, one-tap P/L/A/E per student, "mark all present", progress count, offline banner, save confirmation, must be completable in under a minute); Class overview (roster, attendance %, running average); **Gradebook** (students as rows, assessments as columns with weights in the header, inline score entry, running-average column, empty future column, keyboard navigation between cells); New assessment; Report card comments (AI-drafted from grade history, editable, approve per student); Homework (post, attach files, due date); Messages (thread list, each thread is tied to one student and shows the student's name and section at the top); Conference schedule.

## Part D: Parent screens (brass, web view)
Home with a **child switcher** at the top (today's attendance, homework due, latest grade, balance owed); Attendance history (month calendar plus list); Grades per subject with running grade; Report cards; Homework; Fees (invoices, receipt history, **Pay** button); Payment flow (amount, method Card / MTN MoMo / Telecel Cash, processing, success with receipt, failure with retry, and "pending confirmation" states); Messages; Announcements (including a permission slip to respond to); Book a conference (slot picker, confirmation).

## Output requirements
- Route per screen, named clearly (for example `/admin/students`, `/teacher/attendance/[sectionId]`, `/parent/fees`).
- Reusable components for: data table, status chip, attendance toggle, gradebook cell, stat tile, child switcher, message thread, invoice row, timetable grid.
- Keep all mock data in one file so it can be replaced with API calls later.
- Responsive down to 360px; the parent portal must be fully usable on a phone-width browser.

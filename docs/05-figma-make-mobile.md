# Figma Make prompt: MOBILE

Keep this as a **separate Figma file** from the web design. Paste everything below the line into Figma Make.

---

Design the **mobile app** for **Homeroom**, a school platform. One app, two roles chosen by account at sign-in: **Parent/Guardian (brass)** and **Teacher (forest green)**. Admin is web only and is not in this app. Phone frame 390×844, iOS and Android safe areas respected, bottom tab bar, thumb-reachable primary actions, 44px minimum touch targets. **Light and dark themes.** Build clickable flows with the mock data below.

**Look and feel:** a well-kept school register. Warm paper backgrounds, ink text, restrained colour, serif headings, monospaced figures. No gradients, no glass effects, no stock illustrations, no emoji.

**Tokens (light / dark)**
- paper #E9EBE3 / #1A2027; raised surface #F4F5F0 / #212832; ink #1B2430 / #ECEAE0; soft ink #3C4650 / #C7CCC2; slate #5C6B66 / #9AA69E; border #C7CBBE / #3A4149
- Teacher forest #2F5D50 / #82C0A7 (tint #E1EAE5 / #212C28)
- Parent brass #96692A / #D9A85C (tint #F1E6D2 / #2E2A1E)
- Alert red #8C3B3B / #D98080
- Fonts: **Fraunces** 600 headings, **Source Sans 3** body/UI, **IBM Plex Mono** for numbers, labels, amounts
- 3px radius on cards and inputs, 1px borders, pill only for status chips. The role's accent colour drives the tab bar's active state, primary buttons and card top rules.
- Status chips carry a letter as well as colour: P present (forest), L late (brass), A absent (red), E excused (slate).

**Mock data:** School: Greenfield Academy, Kumasi. Currency GH¢. Teacher: Kwame Boateng (6A homeroom, Maths). Parent: Akua Asante, children Kofi Asante (6A) and Ama Asante (4B). 6A students: Kofi Asante, Yaa Adjei, Kweku Sarpong, Adwoa Ofori, Kojo Bediako, Afia Nkrumah, Yaw Amoah, Serwaa Gyamfi. Kofi's last five days: P, P, L, P, A (excused, fever note). 6A Maths: Quiz 1 8/10, Fractions test 72/100, Project 15/20, Midterm not yet scored; Kofi running average 74.5%. Invoices: Kofi tuition GH¢1,850 with GH¢600 outstanding and overdue since 30 Sep; Ama paid GH¢1,650. Payment methods: Card, MTN MoMo, Telecel Cash. Announcement: mid-term break, closes Fri 23 Oct, reopens Mon 2 Nov. Permission slip: science museum trip 13 Nov, reply by 6 Nov. Message thread about Kofi between Akua ("Kofi was out Friday with a fever. Note attached.") and Kwame ("Thanks, marked excused. He can catch up on the fractions worksheet."). Conference slots: Kwame Boateng, Sat 24 Oct, 09:00 to 12:00, 15-minute slots, 09:15 booked by Akua.

## Shared
Splash, Sign in (email + password, and phone number + OTP for parents), role picker if an account has both roles, Notifications centre, Profile and settings (contact details, notification channels push / email / SMS, theme).

## Parent app (brass), tabs: Home, Attendance, Grades, Fees, More
- **Home:** child switcher at the top (avatar chips, switch without re-login), today's attendance, homework due, latest grade, balance owed with a Pay button.
- Attendance history: month calendar with status letters, tap a day for detail.
- Grades: per subject, assessments with weights, running grade.
- Report cards.
- Homework list and detail.
- **Fees:** invoices with status, receipt history. **Payment flow:** amount, method (Card / MTN MoMo / Telecel Cash), processing, success with receipt, failure with retry, and a "pending confirmation" state.
- Messages: thread list, thread view (each thread is tied to one child, shown at the top), attachment support.
- Announcements, including a permission slip with Yes / No response.
- Book a conference: slot picker, confirmation, add to calendar.
- Push notification previews for: child marked absent, fee due in 3 days, homework posted, announcement.
- An SMS-fallback explainer screen in Settings: "Get alerts by SMS if you don't have data."

## Teacher app (forest), tabs: Today, Classes, Messages, More
- **Today:** my periods in order, unmarked registers called out with a clear action.
- **Take attendance** (the most important screen): period roster, one-tap cycle or segmented control per student for P/L/A/E, "Mark all present", progress count, sticky Save, **offline banner and "saved on device, will sync" state**, sync-complete confirmation. Completable in under a minute for 28 students.
- Class overview: roster, attendance %, running average.
- **Gradebook lite:** pick an assessment, then enter scores student by student with a number pad; show weight and class average; the full gradebook is web only.
- New assessment.
- Homework: post with due date and attachments.
- Messages: thread list and thread view, each tied to one student.
- Conference schedule for the day.

## Required states
Loading skeleton, empty (plain text), error with retry, offline (teacher attendance and gradebook), and a read-only state after a term closes.

## Output requirements
- Name frames clearly by role and screen (`Parent/Home`, `Teacher/TakeAttendance`) so they map cleanly to code.
- Use Figma components and variables for the colour, type and radius tokens above, in both light and dark modes.
- This will be implemented in **Flutter**, so design for widget mapping: use Auto Layout everywhere (no loose absolutely-positioned layers), consistent 4px spacing, components with variants for states (default, pressed, disabled, selected, error), and text styles and colour variables rather than raw values. Avoid effects that are awkward in Flutter (background blur, complex masks, overlapping blend modes).
- Reusable components: tab bar, child switcher, status chip, attendance toggle row, invoice row, message bubble, stat tile, list row, bottom sheet, toast.

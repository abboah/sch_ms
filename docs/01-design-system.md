# Design system (from the spec)

Mood: a well-kept school register. Warm paper, ink, restrained colour. Serif headings, mono for data and labels. No gradients, no glassmorphism, no stock illustration.

## Colour
| Token | Light | Dark | Use |
|---|---|---|---|
| paper | #E9EBE3 | #1A2027 | page background |
| paper-raised | #F4F5F0 | #212832 | cards, panels |
| ink | #1B2430 | #ECEAE0 | primary text |
| ink-soft | #3C4650 | #C7CCC2 | body text |
| slate | #5C6B66 | #9AA69E | labels, captions |
| rule-line | #C7CBBE | #3A4149 | borders |
| indigo (Admin) | #33507A | #8FADDD | admin accent |
| indigo-soft | #E4E9F1 | #262F3E | admin tint |
| forest (Teacher) | #2F5D50 | #82C0A7 | teacher accent |
| forest-soft | #E1EAE5 | #212C28 | teacher tint |
| brass (Parent) | #96692A | #D9A85C | parent accent |
| brass-soft | #F1E6D2 | #2E2A1E | parent tint |
| rule-red | #8C3B3B | #D98080 | absent, overdue, destructive |

Each portal uses its own accent for the top rule of cards, active nav, primary button and chips. Status colours: present = forest, late = brass, absent = rule-red, excused = slate.

## Type
- Headings: **Fraunces** 600 (opsz), tight tracking, balanced wrapping
- Body/UI: **Source Sans 3** 400/500/600/700, 16px / 1.55
- Labels, numbers, table headers, IDs: **IBM Plex Mono** 400/500/600, tabular figures. Eyebrow labels are 11px uppercase, 0.09em tracking

## Shape and spacing
- Radius 3px on cards and inputs, pill only for status chips
- 1px rule-line borders, 3px accent top border on portal cards, no heavy shadows (`0 1px 0 rgba(27,36,48,.06)`)
- 4px spacing base; content max-width 880px for reading pages, full width for tables and gradebook
- Web breakpoints: 720px (single column), 1024px (sidebar collapses to icons)

## Components
App shell (sidebar + top bar, role switcher), data table (sticky header, mono headers, row hover), status chip, attendance toggle (P / L / A / E), gradebook cell (inline edit, running average column), stat tile, child switcher (parent), message thread, invoice row with Pay button, calendar/timetable grid, announcement card, empty state (plain text, no illustration), toast.

## Accessibility
4.5:1 contrast minimum in both themes, status never by colour alone (letter + colour), 44px minimum touch targets on mobile, light and dark theme required.

export type Status = "P" | "L" | "A" | "E";

export const school = { name: "Greenfield Academy", city: "Kumasi", term: "Term 1, 2026", dates: "8 Sep to 18 Dec" };

export const money = (n: number) => "GH¢ " + n.toLocaleString("en-GH", { minimumFractionDigits: 2, maximumFractionDigits: 2 });

export const staff = [
  { id: "esi", name: "Esi Mensah", role: "Registrar", subjects: "Administration", section: "", email: "e.mensah@greenfield.edu.gh", phone: "024 410 2231" },
  { id: "kwame", name: "Kwame Boateng", role: "Teacher", subjects: "Maths", section: "6A homeroom", email: "k.boateng@greenfield.edu.gh", phone: "020 881 5540" },
  { id: "abena", name: "Abena Owusu", role: "Teacher", subjects: "English", section: "6B homeroom", email: "a.owusu@greenfield.edu.gh", phone: "055 312 7718" },
  { id: "yaw", name: "Yaw Darko", role: "Teacher", subjects: "Science (6A, 6B)", section: "", email: "y.darko@greenfield.edu.gh", phone: "024 903 6612" },
];

export const sections = [
  { id: "6A", grade: "Grade 6", count: 28, homeroom: "Kwame Boateng", room: "Room 12" },
  { id: "6B", grade: "Grade 6", count: 27, homeroom: "Abena Owusu", room: "Room 14" },
  { id: "4B", grade: "Grade 4", count: 30, homeroom: "Unassigned", room: "Room 7" },
];

export type Student = { id: string; name: string; section: string; grade: string; guardians: string[]; att: number; avg?: number; sid: string };
export const students: Student[] = [
  { id: "kofi", name: "Kofi Asante", section: "6A", grade: "Grade 6", guardians: ["Akua Asante"], att: 91, sid: "GA-2019-0142" },
  { id: "yaa", name: "Yaa Adjei", section: "6A", grade: "Grade 6", guardians: ["Nana Adjei", "Efua Adjei"], att: 98, sid: "GA-2019-0147" },
  { id: "kweku", name: "Kweku Sarpong", section: "6A", grade: "Grade 6", guardians: ["Ebo Sarpong"], att: 94, sid: "GA-2019-0151" },
  { id: "adwoa", name: "Adwoa Ofori", section: "6A", grade: "Grade 6", guardians: ["Grace Ofori"], att: 100, sid: "GA-2019-0153" },
  { id: "kojob", name: "Kojo Bediako", section: "6A", grade: "Grade 6", guardians: ["Paul Bediako"], att: 87, sid: "GA-2019-0158" },
  { id: "afia", name: "Afia Nkrumah", section: "6A", grade: "Grade 6", guardians: ["Lydia Nkrumah"], att: 96, sid: "GA-2019-0160" },
  { id: "yawa", name: "Yaw Amoah", section: "6A", grade: "Grade 6", guardians: ["Kojo Amoah"], att: 92, sid: "GA-2019-0163" },
  { id: "serwaa", name: "Serwaa Gyamfi", section: "6A", grade: "Grade 6", guardians: ["Abigail Gyamfi"], att: 97, sid: "GA-2019-0168" },
  { id: "kojot", name: "Kojo Tetteh", section: "6B", grade: "Grade 6", guardians: ["Samuel Tetteh"], att: 93, sid: "GA-2019-0201" },
  { id: "nii", name: "Nii Quaye", section: "6B", grade: "Grade 6", guardians: ["Efua Quaye"], att: 95, sid: "GA-2019-0207" },
  { id: "ama", name: "Ama Asante", section: "4B", grade: "Grade 4", guardians: ["Akua Asante"], att: 100, sid: "GA-2021-0311" },
];
export const roster6A = students.filter((s) => s.section === "6A");
export const roster6B = students.filter((s) => s.section === "6B");

export const assessments = [
  { id: "q1", title: "Quiz 1", weight: 10, max: 10, due: "19 Sep" },
  { id: "frac", title: "Fractions test", weight: 25, max: 100, due: "3 Oct" },
  { id: "proj", title: "Project", weight: 20, max: 20, due: "17 Oct" },
  { id: "mid", title: "Midterm", weight: 45, max: 100, due: "7 Nov" },
];
export const initialScores: Record<string, (number | null)[]> = {
  kofi: [8, 72, 15, null],
  yaa: [9, 88, 18, null],
  kweku: [7, 65, 14, null],
  adwoa: [10, 94, 19, null],
  kojob: [6, 58, 12, null],
  afia: [9, 81, 16, null],
  yawa: [7, 70, 15, null],
  serwaa: [8, 85, 17, null],
};
export const statedAvg: Record<string, number> = { kofi: 76.0, yaa: 88.9 };
export function runningAvg(scores: (number | null)[]) {
  let w = 0, t = 0;
  scores.forEach((s, i) => {
    if (s == null) return;
    w += assessments[i].weight;
    t += (s / assessments[i].max) * assessments[i].weight;
  });
  return w ? (t / w) * 100 : null;
}

export const kofiWeek: { day: string; date: string; s: Status; note?: string }[] = [
  { day: "Mon", date: "22 Sep", s: "P" },
  { day: "Tue", date: "23 Sep", s: "P" },
  { day: "Wed", date: "24 Sep", s: "L", note: "Arrived 08:25" },
  { day: "Thu", date: "25 Sep", s: "P" },
  { day: "Fri", date: "26 Sep", s: "E", note: "Malaria note from Akua Asante" },
];

export const periodsToday = [
  { id: "p1", time: "07:40 to 08:30", label: "Period 1", subject: "Maths", section: "6A", marked: true },
  { id: "p3", time: "09:35 to 10:25", label: "Period 3", subject: "Maths", section: "6B", marked: false },
  { id: "p5", time: "11:40 to 12:30", label: "Period 5", subject: "Maths", section: "6A", marked: false },
  { id: "p7", time: "13:45 to 14:35", label: "Period 7", subject: "Homeroom", section: "6A", marked: false },
];

export const timetable: Record<string, string[][]> = {
  "6A": [
    ["Maths", "English", "Science", "Maths", "Social Studies"],
    ["Maths", "Science", "English", "ICT", "Maths"],
    ["English", "Maths", "Break", "Science", "English"],
    ["Science", "PE", "Maths", "English", "Art"],
    ["Social Studies", "Maths", "Music", "Maths", "Science"],
  ],
  "6B": [
    ["English", "Maths", "Science", "English", "Maths"],
    ["Science", "English", "Maths", "Maths", "ICT"],
    ["Maths", "Science", "Break", "English", "Social Studies"],
    ["English", "Art", "English", "PE", "Science"],
    ["Maths", "Social Studies", "Science", "Music", "English"],
  ],
};
export const periodTimes = ["07:40", "08:35", "09:35", "10:40", "11:40"];

export const invoices = [
  { id: "INV-1042", studentId: "kofi", student: "Kofi Asante", item: "Tuition, Term 1", total: 1850, paid: 1250, due: "30 Sep", status: "Overdue" },
  { id: "INV-1043", studentId: "ama", student: "Ama Asante", item: "Tuition, Term 1", total: 1650, paid: 1650, due: "30 Sep", status: "Paid" },
  { id: "INV-1044", studentId: "yaa", student: "Yaa Adjei", item: "Tuition, Term 1", total: 1850, paid: 0, due: "15 Oct", status: "Unpaid" },
  { id: "INV-1051", studentId: "kojot", student: "Kojo Tetteh", item: "Tuition, Term 1", total: 1850, paid: 1850, due: "30 Sep", status: "Paid" },
  { id: "INV-1052", studentId: "nii", student: "Nii Quaye", item: "Tuition, Term 1", total: 1850, paid: 900, due: "15 Oct", status: "Partial" },
];

export const payments = [
  { id: "PAY-7731", ref: "MTN-88213941", who: "Akua Asante", method: "MTN MoMo", amount: 300, date: "28 Sep, 10:12", state: "Pending", inv: "INV-1042" },
  { id: "PAY-7724", ref: "CARD-4471-20", who: "Samuel Tetteh", method: "Card", amount: 1850, date: "26 Sep, 16:40", state: "Matched", inv: "INV-1051" },
  { id: "PAY-7719", ref: "TCH-55102977", who: "Unknown (024 556 1098)", method: "Telecel Cash", amount: 450, date: "25 Sep, 08:03", state: "Unmatched", inv: "" },
  { id: "PAY-7702", ref: "MTN-88100412", who: "Efua Quaye", method: "MTN MoMo", amount: 900, date: "22 Sep, 12:55", state: "Matched", inv: "INV-1052" },
  { id: "PAY-7688", ref: "CASH-0915", who: "Akua Asante", method: "Manual (bursar)", amount: 950, date: "15 Sep, 09:30", state: "Matched", inv: "INV-1042" },
];

export const announcements = [
  { id: "a1", title: "Mid-term break", body: "School closes Fri 24 Oct and reopens Mon 3 Nov. Boarding students should be collected by 15:00.", date: "27 Sep", audience: "All guardians and staff", slip: false },
  { id: "a2", title: "Science museum trip: permission slip", body: "Grade 6 visits the Museum of Science and Technology on 14 Nov. A signed response is needed by 7 Nov. Cost is covered by the activity fee.", date: "24 Sep", audience: "Grade 6 guardians", slip: true },
  { id: "a3", title: "Term 1 fee deadline", body: "Outstanding Term 1 balances are due on 30 Sep. Pay online from the Fees page or at the bursar's office.", date: "19 Sep", audience: "All guardians", slip: false },
];

export const threads = [
  {
    id: "t1", studentId: "kofi", student: "Kofi Asante", section: "6A", guardian: "Akua Asante", teacher: "Kwame Boateng", last: "Thanks, marked excused.", date: "Fri", unread: true,
    msgs: [
      { from: "Akua Asante", text: "Kofi was out Friday with a fever. Note attached.", time: "Fri 07:12", file: "malaria-note.pdf" },
      { from: "Kwame Boateng", text: "Thanks, marked excused. He can catch up on the fractions worksheet.", time: "Fri 09:48" },
    ],
  },
  {
    id: "t2", studentId: "yaa", student: "Yaa Adjei", section: "6A", guardian: "Nana Adjei", teacher: "Kwame Boateng", last: "Could Yaa take the extension project?", date: "Wed", unread: false,
    msgs: [
      { from: "Nana Adjei", text: "Could Yaa take the extension project? She finished the fractions unit early.", time: "Wed 18:20" },
      { from: "Kwame Boateng", text: "Yes, I will send the brief on Monday.", time: "Wed 19:05" },
    ],
  },
  {
    id: "t3", studentId: "kojot", student: "Kojo Tetteh", section: "6B", guardian: "Samuel Tetteh", teacher: "Abena Owusu", last: "Reading log signed.", date: "Mon", unread: false,
    msgs: [{ from: "Samuel Tetteh", text: "Reading log signed.", time: "Mon 17:40" }],
  },
];

export const audit = [
  { when: "30 Sep, 08:41", who: "Esi Mensah", role: "Registrar", action: "Viewed", target: "Kofi Asante (GA-2019-0142)", detail: "Student profile" },
  { when: "30 Sep, 08:17", who: "Kwame Boateng", role: "Teacher", action: "Changed", target: "Yaa Adjei", detail: "Fractions test: 86 to 88" },
  { when: "29 Sep, 15:02", who: "Esi Mensah", role: "Registrar", action: "Changed", target: "Ama Asante", detail: "Section 4A to 4B" },
  { when: "29 Sep, 11:26", who: "Abena Owusu", role: "Teacher", action: "Viewed", target: "Kojo Tetteh (GA-2019-0201)", detail: "Guardian contacts" },
  { when: "28 Sep, 10:13", who: "System", role: "Payments", action: "Changed", target: "INV-1042", detail: "MoMo payment set to pending" },
  { when: "26 Sep, 09:50", who: "Kwame Boateng", role: "Teacher", action: "Changed", target: "Kofi Asante", detail: "Attendance Fri 26 Sep: A to E" },
];

export const homework = [
  { id: "h1", subject: "Maths", title: "Exercises 4.2 to 4.5", due: "Thu 2 Oct", section: "6A", posted: "Mon", file: "fractions-sheet.pdf" },
  { id: "h2", subject: "English", title: "Read Chapter 3, write 150 words", due: "Fri 3 Oct", section: "6B", posted: "Tue", file: "" },
  { id: "h3", subject: "Science", title: "Label the water cycle diagram", due: "Mon 6 Oct", section: "6A", posted: "Wed", file: "water-cycle.png" },
];

export const slots = ["09:00", "09:15", "09:30", "09:45", "10:00", "10:15", "10:30", "10:45", "11:00", "11:15", "11:30", "11:45"];
export const bookedSlots: Record<string, string> = { "09:15": "Akua Asante", "10:30": "Nana Adjei", "11:00": "Efua Quaye" };

export const children = [
  { id: "kofi", name: "Kofi", full: "Kofi Asante", section: "6A", grade: "Grade 6" },
  { id: "ama", name: "Ama", full: "Ama Asante", section: "4B", grade: "Grade 4" },
];

export const grades: Record<string, { subject: string; running: number; items: { t: string; score: string; w: number }[] }[]> = {
  kofi: [
    { subject: "Maths", running: 76.0, items: [{ t: "Quiz 1", score: "8/10", w: 10 }, { t: "Fractions test", score: "72/100", w: 25 }, { t: "Project", score: "15/20", w: 20 }, { t: "Midterm", score: "Not yet set", w: 45 }] },
    { subject: "English", running: 71.5, items: [{ t: "Book report", score: "34/50", w: 30 }, { t: "Spelling quiz", score: "18/25", w: 20 }] },
    { subject: "Science", running: 82.0, items: [{ t: "Lab write-up", score: "41/50", w: 40 }, { t: "Quiz 1", score: "8/10", w: 10 }] },
  ],
  ama: [
    { subject: "Maths", running: 84.0, items: [{ t: "Times tables", score: "21/25", w: 30 }] },
    { subject: "English", running: 90.0, items: [{ t: "Story writing", score: "45/50", w: 40 }] },
    { subject: "Science", running: 79.0, items: [{ t: "Plants poster", score: "16/20", w: 30 }, { t: "Quiz 1", score: "8/10", w: 10 }] },
  ],
};

export const notifications = [
  { id: "n1", kind: "Attendance", text: "Kofi was marked Late on Wed 24 Sep.", time: "Wed 08:31" },
  { id: "n2", kind: "Fees", text: "Kofi's tuition balance of GH¢ 600.00 is overdue.", time: "Tue 07:00" },
  { id: "n3", kind: "Homework", text: "Maths: exercises 4.2 to 4.5 due Thu.", time: "Mon 15:10" },
  { id: "n4", kind: "Announcements", text: "New: Science museum trip permission slip.", time: "24 Sep" },
];

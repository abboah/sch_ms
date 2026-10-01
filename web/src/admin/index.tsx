import { Announcements, Conferences, MessagesAudit } from "./communication";
import { Fees, Payments } from "./finance";
import { Overview } from "./overview";
import { Analytics, AttendanceReports, AuditLog } from "./reports";
import { Enrollment, StudentProfile, Students } from "./students";
import { Sections, Staff, Timetable } from "./structure";

/** The administrator portal: one module per area (people, structure, money, communication, reports). */
export default function AdminPages({ path }: { path: string }) {
  const p = path.split("/").filter(Boolean);
  switch (p[1]) {
    case undefined: return <Overview />;
    case "students": return p[2] ? <StudentProfile id={p[2]} /> : <Students />;
    case "enrollment": return <Enrollment />;
    case "sections": return <Sections />;
    case "staff": return <Staff />;
    case "timetable": return <Timetable />;
    case "attendance": return <AttendanceReports />;
    case "fees": return <Fees />;
    case "payments": return <Payments />;
    case "announcements": return <Announcements />;
    case "messages": return <MessagesAudit />;
    case "conferences": return <Conferences />;
    case "analytics": return <Analytics />;
    case "audit": return <AuditLog />;
    default: return <Overview />;
  }
}

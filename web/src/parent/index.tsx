import { Announcements, Conference, Messages } from "./communication";
import { Fees, Pay } from "./fees";
import { Home } from "./home";
import { Attendance, Grades, Homework, Reports } from "./records";

/** The parent portal. Everything is about the child chosen in the switcher at the top of each page. */
export default function ParentPages({ path }: { path: string }) {
  const p = path.split("/").filter(Boolean);
  switch (p[1]) {
    case "attendance": return <Attendance />;
    case "grades": return <Grades />;
    case "reports": return <Reports />;
    case "homework": return <Homework />;
    case "fees": return p[2] === "pay" && p[3] ? <Pay id={p[3]} /> : <Fees />;
    case "messages": return <Messages />;
    case "announcements": return <Announcements />;
    case "conference": return <Conference />;
    default: return <Home />;
  }
}

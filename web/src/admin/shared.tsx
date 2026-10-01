import { $api } from "../api/client";
import type { components } from "../api/schema";
import { useMe } from "../auth/auth";
import { Btn } from "../ui";

type Invoice = components["schemas"]["Invoice"];

export const cap = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);

/** The label the design uses for an invoice, folding the derived "overdue" into the status. */
export const invoiceLabel = (i: Pick<Invoice, "status" | "overdue">) => (i.overdue ? "Overdue" : cap(i.status));

/** A "load more" footer for cursor-paged lists. */
export function LoadMore({ q }: { q: { hasNextPage: boolean; isFetchingNextPage: boolean; fetchNextPage: () => unknown } }) {
  if (!q.hasNextPage) return null;
  return (
    <div className="border-t border-rule p-3 text-center">
      <Btn variant="ghost" disabled={q.isFetchingNextPage} onClick={() => void q.fetchNextPage()}>
        {q.isFetchingNextPage ? "Loading…" : "Load more"}
      </Btn>
    </div>
  );
}

/** Sections of the current term, for the many screens that pick one. */
export function useSections() {
  const me = useMe();
  const q = $api.useQuery("get", "/class_sections", { params: { query: me.school.term ? { term_id: me.school.term.id } : {} } });
  return { q, sections: q.data?.items ?? [] };
}

export const POSITIVE_MONEY = /^\d+(\.\d{1,2})?$/;

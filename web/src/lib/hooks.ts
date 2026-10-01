import { useEffect, useState } from "react";

/** A value that only follows its source after it has been still for `ms`. For search-as-you-type. */
export function useDebounced<T>(value: T, ms = 300): T {
  const [v, setV] = useState(value);
  useEffect(() => {
    const t = setTimeout(() => setV(value), ms);
    return () => clearTimeout(t);
  }, [value, ms]);
  return v;
}

/**
 * Options that make an API list a "load more" list: the server returns `next_cursor`, which goes back
 * as `cursor` until it is null. Spread into $api.useInfiniteQuery(...).
 */
export const cursorPaging = {
  // An empty cursor means "from the start". (undefined would make the client send cursor=0, which is not a cursor.)
  initialPageParam: "",
  pageParamName: "cursor" as const,
  getNextPageParam: (last: { next_cursor?: string | null }): string | undefined => last.next_cursor ?? undefined,
};

/** Flatten `data.pages[].items` of an infinite query. */
export function allItems<T>(data: { pages: { items?: T[] }[] } | undefined): T[] {
  return data?.pages.flatMap((p) => p.items ?? []) ?? [];
}

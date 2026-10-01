import { useMe } from "../auth/auth";
import { useApp } from "../ui";

/** The child the parent is currently looking at (the first one until they choose). */
export function useChild() {
  const { child } = useApp();
  const kids = useMe().children ?? [];
  const current = kids.find((c) => c.id === child) ?? kids[0];
  return current;
}

/** Tabs to switch between one's children without signing in again. Hidden for a single child. */
export function ChildSwitcher() {
  const { child, setChild } = useApp();
  const kids = useMe().children ?? [];
  if (kids.length < 2) return null;
  const selected = child || kids[0]?.id;
  return (
    <div role="tablist" aria-label="Child" className="mb-5 flex gap-2">
      {kids.map((c) => (
        <button
          key={c.id}
          role="tab"
          aria-selected={selected === c.id}
          onClick={() => setChild(c.id)}
          className={`flex min-h-12 flex-1 flex-col rounded-reg border px-3 py-1.5 text-left sm:max-w-56 ${selected === c.id ? "border-accent border-t-[3px] bg-accent-soft" : "border-rule bg-raised hover:bg-accent-soft"}`}
        >
          <span className="font-serif text-base font-semibold leading-tight">{c.full_name}</span>
          <span className="mono text-xs text-mute">{c.class_section?.name ?? "Not placed"}</span>
        </button>
      ))}
    </div>
  );
}

/** Shown when a guardian has no child linked yet. */
export const NoChildren = () => (
  <p className="rounded-reg border border-dashed border-rule p-8 text-center text-mute">
    No child is linked to your account yet. Ask the school office to link your child, and they will appear here.
  </p>
);

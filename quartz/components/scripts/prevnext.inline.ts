// ←/→ walk to the previous/next note (mirrors the old study-mode shortcuts).
const handler = (e: KeyboardEvent) => {
  const t = e.target as HTMLElement | null
  if (
    t &&
    (t.tagName === "INPUT" ||
      t.tagName === "TEXTAREA" ||
      t.tagName === "SELECT" ||
      t.isContentEditable)
  )
    return
  if (e.metaKey || e.ctrlKey || e.altKey) return
  if (e.key === "ArrowLeft") {
    ;(document.querySelector(".prev-next .pn-prev") as HTMLAnchorElement | null)?.click()
  } else if (e.key === "ArrowRight") {
    ;(document.querySelector(".prev-next .pn-next") as HTMLAnchorElement | null)?.click()
  }
}

document.addEventListener("keydown", handler)
;(window as any).addCleanup?.(() => document.removeEventListener("keydown", handler))

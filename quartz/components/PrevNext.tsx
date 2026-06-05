import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"
import style from "./styles/prevnext.scss"
import { resolveRelative } from "../util/path"
import { classNames } from "../util/lang"
// @ts-ignore
import script from "./scripts/prevnext.inline"

function lastSegment(slug: string): string {
  const parts = slug.split("/")
  return parts[parts.length - 1] ?? slug
}

function titleOf(f: QuartzComponentProps["allFiles"][number]): string {
  return (f.frontmatter?.title as string) ?? lastSegment(f.slug!)
}

// Sequential "previous / next note" pager within the current folder (block),
// in natural order (01, 02, … 58). Replaces the old hand-rolled study pager.
const PrevNext: QuartzComponent = ({ fileData, allFiles, displayClass }: QuartzComponentProps) => {
  const slug = fileData.slug!
  // only on real notes inside a folder — skip index / folder / tag pages
  if (slug === "index" || slug.endsWith("/index") || slug.startsWith("tags/")) return null
  const folder = slug.split("/").slice(0, -1).join("/")
  if (!folder) return null

  const siblings = allFiles
    .filter((f) => {
      const s = f.slug!
      if (s === "index" || s.endsWith("/index")) return false
      return s.split("/").slice(0, -1).join("/") === folder
    })
    .sort((a, b) =>
      lastSegment(a.slug!).localeCompare(lastSegment(b.slug!), undefined, {
        numeric: true,
        sensitivity: "base",
      }),
    )

  const idx = siblings.findIndex((f) => f.slug === slug)
  if (idx === -1) return null
  const prev = idx > 0 ? siblings[idx - 1] : null
  const next = idx < siblings.length - 1 ? siblings[idx + 1] : null
  if (!prev && !next) return null

  return (
    <nav class={classNames(displayClass, "prev-next")} aria-label="Соседние заметки">
      {prev ? (
        <a class="pn-prev internal" href={resolveRelative(slug, prev.slug!)}>
          <span class="pn-label">← Предыдущая</span>
          <span class="pn-title">{titleOf(prev)}</span>
        </a>
      ) : (
        <span class="pn-spacer" />
      )}
      {next ? (
        <a class="pn-next internal" href={resolveRelative(slug, next.slug!)}>
          <span class="pn-label">Следующая →</span>
          <span class="pn-title">{titleOf(next)}</span>
        </a>
      ) : (
        <span class="pn-spacer" />
      )}
    </nav>
  )
}

PrevNext.css = style
PrevNext.afterDOMLoaded = script

export default (() => PrevNext) satisfies QuartzComponentConstructor

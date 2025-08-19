#!/usr/bin/env bash

# Simple, robust PDF generator for Markdown notes
# Usage:
#   ./advanced_pdf.sh all
#   ./advanced_pdf.sh block "Блок 1. «Физика атмосферы»"
#   ./advanced_pdf.sh single "Notes/Блок 1. …/1.1. … .md"

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOTES_DIR="$SCRIPT_DIR/Notes"
OUTPUT_DIR="$SCRIPT_DIR/pdf_output"

mkdir -p "$OUTPUT_DIR"

die() { echo "❌ $*" >&2; exit 1; }

require() { command -v "$1" >/dev/null 2>&1 || die "Не найдено: $1. Установите и повторите попытку."; }

choose_engine() {
    if command -v lualatex >/dev/null 2>&1; then echo "lualatex"; return; fi
    if command -v xelatex >/dev/null 2>&1; then echo "xelatex"; return; fi
    if command -v pdflatex >/dev/null 2>&1; then echo "pdflatex"; return; fi
    die "Не найден ни один LaTeX движок (lualatex/xelatex/pdflatex). Установите TeX Live."
}

sanitize() { echo -n "$1" | tr ' /' '_' | tr -d '«»' ; }

# Remove leading numeric prefixes like "1.", "1.3.17 ", "02-" from titles
strip_leading_numbers() {
    local s="$1"
    echo -n "$s" | sed -E 's/^[0-9]+([._-][0-9]+)*[.)]?[[:space:]]+//'
}

# Append a file to target, demoting markdown heading levels by `shift` while preserving code fences
append_demoted() {
    local shift="$1" src="$2" target="$3"
    [[ -s "$src" ]] || return 0
    awk -v sh="$shift" '
        BEGIN { inCode=0 }
        /^```/ { inCode = !inCode; print; next }
        {
            if (!inCode && $0 ~ /^#{1,6}[[:space:]]/) {
                n = 0
                while (substr($0, n+1, 1) == "#") n++
                newn = n + sh
                if (newn > 6) newn = 6
                rest = substr($0, n+1)
                hd = ""
                for (i=0; i<newn; i++) hd = hd "#"
                print hd rest
            } else {
                print
            }
        }
    ' "$src" >> "$target"
}

# Build a single temporary combined markdown with structure-based headings
make_structured_md_all() {
    local tmp_md="$OUTPUT_DIR/tmp_combined.md"
    : > "$tmp_md"

    # List blocks
    mapfile -d '' -t blocks < <(find "$NOTES_DIR" -maxdepth 1 -mindepth 1 -type d -name 'Блок*' -print0 | sort -z -V)
    local first_block=1
    for block_dir in "${blocks[@]}"; do
        local block_name; block_name="$(basename "$block_dir")"
        if [[ $first_block -eq 0 ]]; then printf "\n\n\\newpage\n\n" >> "$tmp_md"; else first_block=0; fi
        printf "# %s\n\n" "$block_name" >> "$tmp_md"

        # Themes inside block
        mapfile -d '' -t themes < <(find "$block_dir" -maxdepth 1 -mindepth 1 -type d -print0 | sort -z -V)
        for theme_dir in "${themes[@]}"; do
            local theme_name; theme_name="$(basename "$theme_dir")"
            printf "## %s\n\n" "$theme_name" >> "$tmp_md"
            # Theme intro is a sibling .md with same name
            local theme_intro="$block_dir/$theme_name.md"
            if [[ -s "$theme_intro" ]]; then
                append_demoted 2 "$theme_intro" "$tmp_md"
                printf "\n\n" >> "$tmp_md"
            fi
            # Notes inside theme
            mapfile -d '' -t notes < <(find "$theme_dir" -type f -name '*.md' -size +0 -print0 | sort -z -V)
            for note in "${notes[@]}"; do
                local base title
                base="$(basename "$note" .md)"
                title="$(strip_leading_numbers "$base")"
                printf "\n\n\\newpage\n\n### %s\n\n" "$title" >> "$tmp_md"
                append_demoted 3 "$note" "$tmp_md"
                printf "\n" >> "$tmp_md"
            done
        done
    done
    echo "$tmp_md"
}

# Build a temporary combined markdown for a single block folder
make_structured_md_block() {
    local block_dir="$1"; local tmp_md="$OUTPUT_DIR/tmp_combined.md"
    : > "$tmp_md"
    local block_name; block_name="$(basename "$block_dir")"
    printf "# %s\n\n" "$block_name" >> "$tmp_md"

    mapfile -d '' -t themes < <(find "$block_dir" -maxdepth 1 -mindepth 1 -type d -print0 | sort -z -V)
    for theme_dir in "${themes[@]}"; do
        local theme_name; theme_name="$(basename "$theme_dir")"
        printf "## %s\n\n" "$theme_name" >> "$tmp_md"
        local theme_intro="$block_dir/$theme_name.md"
        if [[ -s "$theme_intro" ]]; then
            append_demoted 2 "$theme_intro" "$tmp_md"
            printf "\n\n" >> "$tmp_md"
        fi
        mapfile -d '' -t notes < <(find "$theme_dir" -type f -name '*.md' -size +0 -print0 | sort -z -V)
        for note in "${notes[@]}"; do
            local base title
            base="$(basename "$note" .md)"
            title="$(strip_leading_numbers "$base")"
            printf "\n\n\\newpage\n\n### %s\n\n" "$title" >> "$tmp_md"
            append_demoted 3 "$note" "$tmp_md"
            printf "\n" >> "$tmp_md"
        done
    done
    echo "$tmp_md"
}

make_combined_md() {
    # Reads null-separated file list from stdin, writes combined markdown path to stdout
    # Adds structure-driven headings:
    #   H1 = Block dir, H2 = Theme dir (or file title if directly under block), H3 = Note file title (when inside theme)
    # Also demotes in-note headings so content starts at H4 (or H3 for top-level block files).
    local tmp_md="$OUTPUT_DIR/tmp_combined.md"
    : > "$tmp_md"
    local first=1
    local current_block="" current_theme=""
    while IFS= read -r -d '' f; do
        [[ -s "$f" ]] || continue

        # Compute path components relative to NOTES_DIR
        local rel=${f#"$NOTES_DIR/"}
        local block=${rel%%/*}
        local rest=${rel#*/}
        local parent_dir
        if [[ "$rest" == "$rel" ]]; then
            parent_dir="" # file directly under Notes (unlikely)
        else
            parent_dir=${rest%/*}
        fi
        local theme=""
        if [[ -n "$parent_dir" ]]; then
            # Theme is first directory under block in the relative path to file
            theme=${parent_dir%%/*}
            # If there was no further '/', theme may equal filename dir when nested deeper is absent
        fi
        local note_title; note_title=$(basename "$f" .md)

        # Insert page break between notes
        if [[ $first -eq 0 ]]; then
            printf "\n\n\\newpage\n\n" >> "$tmp_md"
        else
            first=0
        fi

        # Emit H1 when block changes
        if [[ "$block" != "$current_block" ]]; then
            printf "# %s\n\n" "$block" >> "$tmp_md"
            current_block="$block"
            current_theme="" # reset theme when block changes
        fi

        # Determine headings and shift based on whether we have a theme directory
        local shift
        if [[ -n "$theme" && "$theme" != "$rel" && "$theme" != "$block" ]]; then
            # Inside a theme directory
            if [[ "$theme" != "$current_theme" ]]; then
                printf "## %s\n\n" "$theme" >> "$tmp_md"
                current_theme="$theme"
            fi
            printf "### %s\n\n" "$note_title" >> "$tmp_md"
            shift=3
        else
            # File directly under block: treat file title as Theme (H2), no H3
            if [[ "$note_title" != "$current_theme" ]]; then
                printf "## %s\n\n" "$note_title" >> "$tmp_md"
                current_theme="$note_title"
            fi
            shift=2
        fi

        # Demote in-note headings by $shift (cap at 6), skip code blocks
        awk -v shift="$shift" '
            BEGIN { inCode=0 }
            /^```/ { inCode = !inCode; print; next }
            {
                if (!inCode && $0 ~ /^#{1,6}[[:space:]]/) {
                    match($0, /^#+/);
                    hashes = RLENGTH;
                    rest = substr($0, hashes+1);
                    newHashes = hashes + shift;
                    if (newHashes > 6) newHashes = 6;
                    printf "%s%s\n", substr("######",1,newHashes), rest;
                } else {
                    print
                }
            }
        ' "$f" >> "$tmp_md"
    done
    echo "$tmp_md"
}

build_pdf() {
    local input_md="$1"; shift
    local out_pdf="$1"; shift
    local engine
    engine=$(choose_engine)

    # Preprocess: unescape dollar signs to enable inline math (e.g., \$\frac{}{} -> $\frac{}{})
    local sanitized_md
    sanitized_md="${input_md%.md}.sanitized.md"
    cp "$input_md" "$sanitized_md"
    # Unescape any number of backslashes before a dollar: \\$ -> $
    sed -i -E 's/\\+\$/$/g' "$sanitized_md"

        # Fix common inline-math issues: remove space after opening $, and close unbalanced $
        local fixed_md
        fixed_md="${input_md%.md}.fixed.md"
    awk '
            BEGIN { inCode=0 }
            /^```/ { inCode = !inCode; print; next }
            {
                line = $0
                if (!inCode) {
            # Also unescape any remaining backslashes before dollar (belt and suspenders)
            gsub(/\\+\$/, "$", line)
                    # Normalize spaces around inline math delimiters so Pandoc recognizes math
                    # e.g., "$ \\frac{...} {..} $" -> "$\\frac{...}{..}$"
                    gsub(/\$[[:space:]]+/, "$", line)     # remove spaces right after $
                    gsub(/[[:space:]]+\$/, "$", line)     # remove spaces right before $
                    # Compact patterns like "$ \\frac" -> "$\\frac" (kept for redundancy)
                    gsub(/\$[[:space:]]+\\/, "$\\", line)
                    # If odd number of $ on line and contains TeX macros, add a closing $
                    tmp=line; gsub(/[^$]/, "", tmp); n=length(tmp)
                    if ((n % 2) == 1 && line ~ /\\(frac|partial|rho|nabla|vec|gamma|theta|phi|alpha|beta|Delta|sum|int|approx|geq|leq|cdot|mu|nu|xi)/) {
                        line = line "$"
                    }
                }
                print line
            }
        ' "$sanitized_md" > "$fixed_md"

        pandoc "$fixed_md" \
        --pdf-engine="$engine" \
        -f markdown+tex_math_dollars+raw_tex \
        -V lang=ru \
        -V mainfont="DejaVu Serif" \
        -V sansfont="DejaVu Sans" \
        -V monofont="DejaVu Sans Mono" \
        -V papersize=a4 \
        -V geometry:margin=2cm \
        -V fontsize=11pt \
        -V linestretch=1.15 \
        --toc --toc-depth=4 \
        --number-sections \
        -o "$out_pdf"
}

list_block_dirs() {
    find "$NOTES_DIR" -maxdepth 1 -type d -name "Блок*" -printf '%f\n' | sort -V || true
}

cmd_single() {
    local src="$1"; [[ -n "${src:-}" ]] || die "Использование: $0 single <файл.md>"
    [[ -f "$src" ]] || die "Файл не найден: $src"
    local base; base=$(basename "$src" .md)
    local out="$OUTPUT_DIR/$(sanitize "$base")_single.pdf"
    echo "📄 Генерация PDF из одного файла: $src"
    local engine; engine=$(choose_engine)
    pandoc "$src" \
        --pdf-engine="$engine" \
        -f markdown+tex_math_dollars+raw_tex \
        -V lang=ru -V mainfont="DejaVu Serif" -V sansfont="DejaVu Sans" -V monofont="DejaVu Sans Mono" \
        -V papersize=a4 -V geometry:margin=2cm -V fontsize=11pt -V linestretch=1.15 \
        --toc --toc-depth=3 --number-sections \
        -o "$out"
    echo "✅ Создан: $out"
}

cmd_block() {
    local block_name="$1"; [[ -n "${block_name:-}" ]] || die "Использование: $0 block \"<название_блока>\""
    local block_dir="$NOTES_DIR/$block_name"
    [[ -d "$block_dir" ]] || die "Каталог блока не найден: $block_dir"
    echo "📚 Генерация PDF для блока: $block_name"
    local tmp_md
    tmp_md=$(make_structured_md_block "$block_dir")
    local out="$OUTPUT_DIR/block_$(sanitize "$block_name").pdf"
    build_pdf "$tmp_md" "$out"
    echo "✅ Создан: $out"
}

cmd_all() {
    echo "� Генерация общего PDF для всех заметок..."
    local tmp_md
    tmp_md=$(make_structured_md_all)
    local out="$OUTPUT_DIR/all_notes_$(date +%Y%m%d).pdf"
    build_pdf "$tmp_md" "$out"
    echo "✅ Создан: $out"
}

main() {
    require pandoc
    case "${1:-help}" in
        single) shift; cmd_single "${1:-}" ;;
        block)
            shift
            if [[ -z "${1:-}" ]]; then
                echo "❓ Использование: $0 block \"<название_блока>\""
                echo "\nДоступные блоки:"
                list_block_dirs | sed 's/^/  - /'
                exit 1
            fi
            cmd_block "$1" ;;
        all) cmd_all ;;
        *)
            cat <<USAGE
🔧 Использование: $0 [опция] [аргумент]

Опции:
    single <файл>      Преобразовать один .md файл в PDF
    block "<блок>"      Преобразовать все .md файла в каталоге блока
    all                Преобразовать все заметки в один PDF

Пример:
    $0 single "Notes/Блок 1. «Физика атмосферы»/1.1. … .md"
    $0 block "Блок 1. «Физика атмосферы»"
    $0 all
USAGE
            ;;
    esac
}

main "$@"

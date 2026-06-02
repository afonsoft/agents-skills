#!/usr/bin/env bash
# Base session-start logic — sourced by per-IDE hooks.
# Builds skills catalog from installed SKILL.md files.

set -euo pipefail

HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Procurar diretorio de skills instaladas
SKILLS_DIR=""
for candidate in \
    "${HOME}/.agents/skills" \
    "${HOOKS_DIR}/../skills" \
    "${HOOKS_DIR}/../../skills"; do
    if [ -d "$candidate" ]; then
        SKILLS_DIR="$candidate"
        break
    fi
done

# Build skills list from SKILL.md frontmatter (name field)
SKILLS_LIST=""
if [ -n "$SKILLS_DIR" ]; then
    for skill_dir in "$SKILLS_DIR"/*/; do
        [ -d "$skill_dir" ] || continue
        slug=$(basename "$skill_dir")
        skill_file="${skill_dir}SKILL.md"
        if [ -f "$skill_file" ]; then
            # Extrair name do frontmatter YAML
            name=$(grep -m1 '^name:' "$skill_file" 2>/dev/null | sed 's/^name:[[:space:]]*//' | tr -d '"' || echo "$slug")
            [ -z "$name" ] && name="$slug"
            SKILLS_LIST+="- ${name}\n"
        fi
    done
fi

# JSON escape helper
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

SKILLS_ESCAPED=$(escape_for_json "$SKILLS_LIST")
SESSION_CONTEXT="<skills-catalog>\nSkills available in this catalog:\n\n${SKILLS_ESCAPED}\n\nUse the appropriate skill for each context. See each skill's SKILL.md for detailed instructions.\n</skills-catalog>"

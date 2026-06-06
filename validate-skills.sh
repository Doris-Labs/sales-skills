#!/usr/bin/env bash
# Validates every skills/*/SKILL.md against the sales-skills anatomy.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$ROOT/skills"
fail=0

REQUIRED_HEADINGS=(
  "## Purpose"
  "## Inputs"
  "## Method"
  "## Tool binding"
  "### With Doris"
  "### With a CRM"
  "### With nothing connected"
  "## Works without Doris"
  "## Common mistakes"
)

if [ ! -d "$SKILLS_DIR" ]; then
  echo "ERROR: no skills/ directory"; exit 1
fi

shopt -s nullglob
count=0
for dir in "$SKILLS_DIR"/*/; do
  name="$(basename "$dir")"
  file="$dir/SKILL.md"
  count=$((count+1))

  if [ ! -f "$file" ]; then
    echo "FAIL [$name]: missing SKILL.md"; fail=1; continue
  fi

  # Frontmatter must start at line 1
  if [ "$(head -1 "$file")" != "---" ]; then
    echo "FAIL [$name]: file must start with YAML frontmatter (---)"; fail=1
  fi

  # name: must equal folder name
  fm_name="$(grep -m1 '^name:' "$file" | sed 's/^name:[[:space:]]*//')"
  if [ "$fm_name" != "$name" ]; then
    echo "FAIL [$name]: frontmatter name '$fm_name' != folder '$name'"; fail=1
  fi

  # description: present and contains a trigger phrase
  if ! grep -q '^description:' "$file"; then
    echo "FAIL [$name]: missing description in frontmatter"; fail=1
  fi
  if ! grep -qi 'Triggers on:' "$file"; then
    echo "FAIL [$name]: description must include 'Triggers on:'"; fail=1
  fi

  # description value must be double-quoted (it contains ': ' which breaks bare YAML)
  if ! grep -qE '^description:[[:space:]]*"' "$file"; then
    echo "FAIL [$name]: description value must be wrapped in double quotes (YAML-safe)"; fail=1
  fi

  # Required headings
  for h in "${REQUIRED_HEADINGS[@]}"; do
    if ! grep -qF "$h" "$file"; then
      echo "FAIL [$name]: missing section '$h'"; fail=1
    fi
  done

  # Deprecated ontology key must never appear
  if grep -qE '"insights"|expand=\[[^]]*insights' "$file"; then
    echo "FAIL [$name]: uses deprecated expand key 'insights' (deal type)"; fail=1
  fi
done

if [ "$count" -eq 0 ]; then
  echo "ERROR: no skills found in $SKILLS_DIR"; exit 1
fi

if [ "$fail" -eq 0 ]; then
  echo "OK: $count skill(s) valid"
else
  echo "VALIDATION FAILED"
fi
exit $fail

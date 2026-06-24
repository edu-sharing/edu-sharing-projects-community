#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-../../../target/chart}"
OUT="${2:-../../../target/chart/GLOBAL-README.md}"

if ! command -v yq >/dev/null 2>&1; then
  echo "Fehler: yq wird benötigt"
  exit 0
fi

if [ ! -f "$ROOT/Chart.yaml" ]; then
  echo "Fehler: Kein Chart.yaml gefunden in $ROOT"
  exit 0
fi

#
# Liefert das Parent-Chart.yaml eines Subcharts
#
get_parent_chart_yaml() {
  local chart_dir="$1"

  local parent_dir
  parent_dir="$(dirname "$chart_dir")"

  if [ "$(basename "$parent_dir")" = "charts" ]; then
    parent_dir="$(dirname "$parent_dir")"

    if [ -f "$parent_dir/Chart.yaml" ]; then
      echo "$parent_dir/Chart.yaml"
      return 0
    fi
  fi

  return 1
}

#
# Liefert Alias oder Namen aus dem Parent-Chart
#
get_alias_from_parent() {
  local chart_dir="$1"
  local chart_name="$2"

  local parent_chart
  parent_chart="$(get_parent_chart_yaml "$chart_dir" || true)"

  if [ -z "$parent_chart" ]; then
    return 0
  fi

  yq -r "
    .dependencies[]?
    | select(.name == \"$chart_name\")
    | .alias // .name
  " "$parent_chart" | head -n 1
}

#
# Ermittelt den vollständigen Wertepfad
#
get_values_path() {
  local chart_dir="$1"

  if [ "$chart_dir" = "$ROOT" ]; then
    echo ""
    return 0
  fi

  local current_dir="$chart_dir"
  local path=""

  while [ "$current_dir" != "$ROOT" ]; do

    local chart_name
    chart_name="$(yq -r '.name' "$current_dir/Chart.yaml")"

    local alias
    alias="$(get_alias_from_parent "$current_dir" "$chart_name")"

    if [ -z "$alias" ] || [ "$alias" = "null" ]; then
      alias="$chart_name"
    fi

    if [ -z "$path" ]; then
      path="$alias"
    else
      path="$alias.$path"
    fi

    local parent_chart
    parent_chart="$(get_parent_chart_yaml "$current_dir" || true)"

    if [ -z "$parent_chart" ]; then
      break
    fi

    current_dir="$(dirname "$parent_chart")"
  done

  echo "$path"
}

#
# README erzeugen
#
{
  echo "# Helm Chart Dokumentation"
  echo
  echo "Automatisch generiert aus dem Hauptchart und allen lokalen Subcharts."
  echo

  find "$ROOT" \
    -path "*/charts/*.tgz" -prune -o \
    -name Chart.yaml -print |
  sort |
  while read -r chart_yaml; do

    chart_dir="$(dirname "$chart_yaml")"
    readme="$chart_dir/README.md"

    [ -f "$readme" ] || continue

    name="$(yq -r '.name // ""' "$chart_yaml")"
    version="$(yq -r '.version // ""' "$chart_yaml")"

    rel="${chart_dir#"$ROOT"/}"
    [ "$rel" = "$chart_dir" ] && rel="."

    values_path="$(get_values_path "$chart_dir")"

    echo "## $name"
    echo
    echo "- Pfad: \`$rel\`"
    echo "- Version: \`$version\`"

    if [ -n "$values_path" ]; then
      echo "- Wertepfad: \`$values_path.*\`"
    else
      echo "- Wertepfad: Root"
    fi

    echo
    echo "---"
    echo

    # H1 entfernen, damit nicht mehrere Top-Level Überschriften entstehen
    awk '
      BEGIN { first_h1_removed=0 }
      /^# / {
        if (!first_h1_removed) {
          first_h1_removed=1
          next
        }
      }
      { print }
    ' "$readme"

    echo
    echo
  done

} > "$OUT"

echo "README generiert: $OUT"
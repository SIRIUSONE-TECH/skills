#!/usr/bin/env bash
# Print snyk-agent-scan JSON findings as: severity, code, title, risk score,
# description, location. Also emits GitHub annotations and a job summary.
# Usage: snyk-report.sh <report.json>
set -euo pipefail

report=$1
root=${GITHUB_WORKSPACE:-$PWD}

# One TSV row per issue: severity, code, skill, title, score, description, location
rows=$(jq -r --arg root "$root/" '
  to_entries[] | .value as $r | ($r.issues // [])[] |
  (if .reference[0] != null then $r.servers[.reference[0]] else null end) as $s |
  (.extra_data // {}) as $x |
  ($x.extra_metadata.affected_files[0] // null) as $f |
  ($s.server.path // "" | ltrimstr($root)) as $dir |
  [ ($x.severity // (if (.code | startswith("E")) then "error" else "unknown" end)),
    .code,
    ($s.name // "-"),
    ($x.title // .message),
    (if $x.risk_score != null then ($x.risk_score * 100 | round / 100 | tostring) else "-" end),
    ($x.reason // .message | gsub("\\s+"; " ")),
    (if $f then "\($dir)/\($f.start.path):\($f.start.line)-\($f.end.line)" else $dir end)
  ] | @tsv' "$report")

count=0
[ -n "$rows" ] && count=$(wc -l <<<"$rows" | tr -d ' ')

summary=${GITHUB_STEP_SUMMARY:-/dev/null}
{
  echo "## Snyk Agent Scan: $count finding(s)"
  if [ "$count" -gt 0 ]; then
    echo
    echo "| Severity | Code | Skill | Issue | Risk | Description | Location |"
    echo "|---|---|---|---|---|---|---|"
  fi
} >>"$summary"

echo "Snyk Agent Scan: $count finding(s)"
[ "$count" -eq 0 ] && exit 0

while IFS=$'\t' read -r sev code skill title score desc loc; do
  SEV=$(tr '[:lower:]' '[:upper:]' <<<"$sev")
  printf '\n%-8s %s  %s  %s (risk %s)\n' "$SEV" "$code" "$skill" "$title" "$score"
  printf '         %s\n' "$desc"
  [ -n "$loc" ] && printf '         at %s\n' "$loc"

  case $sev in
    critical | high | error) level=error ;;
    *) level=warning ;;
  esac
  file=${loc%%:*}
  line=${loc#*:}; line=${line%%-*}
  if [[ "$loc" == *:* ]]; then
    echo "::$level file=$file,line=$line,title=$code $SEV: $title::$desc"
  else
    echo "::$level title=$code $SEV: $title::$desc"
  fi

  echo "| $SEV | $code | $skill | $title | $score | ${desc//|/\\|} | \`$loc\` |" >>"$summary"
done <<<"$rows"

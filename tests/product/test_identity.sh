#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
prepare_script=${PREPARE_SCRIPT:-"${repo_root}/prepare_vscode.sh"}
tmp_dir=$(mktemp -d)
trap 'rm -rf "${tmp_dir}"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

extract_setters() {
  sed -n 's/^[[:space:]]*setpath "product" "\([^"]*\)" "\([^"]*\)"[[:space:]]*$/\1|\2/p'
}

assert_exact_setters() {
  local description=$1
  local actual=$2
  local expected=$3

  if ! diff -u "${expected}" "${actual}"; then
    fail "${description} setters differ from the identity contract"
  fi
}

# Match the literal shell conditions in prepare_vscode.sh. Each extracted block
# is compared as a complete ordered list, so a duplicate or later override
# cannot satisfy the contract merely because the expected setter also exists.
# shellcheck disable=SC2016
awk '
  $0 == "if [[ \"${VSCODE_QUALITY}\" == \"insider\" ]]; then" { occurrence++; active = (occurrence == 2) }
  active && $0 == "else" { exit }
  active { print }
' "${prepare_script}" | extract_setters >"${tmp_dir}/insider.actual"
cat >"${tmp_dir}/insider.expected" <<'EOF'
nameShort|VSCodium - Insiders
nameLong|VSCodium - Insiders
applicationName|codium-insiders
dataFolderName|.vscodium-insiders
linuxIconName|vscodium-insiders
quality|insider
urlProtocol|vscodium-insiders
serverApplicationName|codium-server-insiders
serverDataFolderName|.vscodium-server-insiders
darwinBundleIdentifier|com.vscodium.VSCodiumInsiders
win32AppUserModelId|VSCodium.VSCodiumInsiders
win32DirName|VSCodium Insiders
win32MutexName|vscodiuminsiders
win32NameVersion|VSCodium Insiders
win32RegValueName|VSCodiumInsiders
win32ShellNameShort|VSCodium Insiders
win32AppId|{{EF35BB36-FA7E-4BB9-B7DA-D1E09F2DA9C9}
win32x64AppId|{{B2E0DDB2-120E-4D34-9F7E-8C688FF839A2}
win32arm64AppId|{{44721278-64C6-4513-BC45-D48E07830599}
win32UserAppId|{{ED2E5618-3E7E-4888-BF3C-A6CCC84F586F}
win32x64UserAppId|{{20F79D0D-A9AC-4220-9A81-CE675FFB6B41}
win32arm64UserAppId|{{2E362F92-14EA-455A-9ABD-3E656BBBFE71}
tunnelApplicationName|codium-insiders-tunnel
win32TunnelServiceMutex|vscodiuminsiders-tunnelservice
win32TunnelMutex|vscodiuminsiders-tunnel
win32ContextMenu.x64.clsid|90AAD229-85FD-43A3-B82D-8598A88829CF
win32ContextMenu.arm64.clsid|7544C31C-BDBF-4DDF-B15E-F73A46D6723D
EOF
assert_exact_setters 'Insider identity' "${tmp_dir}/insider.actual" "${tmp_dir}/insider.expected"

# shellcheck disable=SC2016
sed -n '/if \[\[ "${OS_NAME}" == "osx" \]\]; then # AI-Codium stable macOS identity/,/^  else$/p' \
  "${prepare_script}" | extract_setters >"${tmp_dir}/macos.actual"
cat >"${tmp_dir}/macos.expected" <<'EOF'
nameShort|AI-Codium
nameLong|AI-Codium
applicationName|ai-codium
dataFolderName|.ai-codium
urlProtocol|ai-codium
serverApplicationName|ai-codium-server
serverDataFolderName|.ai-codium-server
darwinBundleIdentifier|io.github.mandosanti06.aicodium
reportIssueUrl|https://github.com/mandosanti06/AI-codium/issues/new/choose
licenseUrl|https://github.com/mandosanti06/AI-codium/blob/master/LICENSE
EOF
assert_exact_setters 'stable macOS identity' "${tmp_dir}/macos.actual" "${tmp_dir}/macos.expected"

# Stable Windows setters are common to every stable OS. Filter the stable
# quality branch to ensure every upstream Windows identity value remains exact.
# shellcheck disable=SC2016
awk '
  $0 == "if [[ \"${VSCODE_QUALITY}\" == \"insider\" ]]; then" { occurrence++; quality = (occurrence == 2) }
  quality && $0 == "else" { stable = 1; next }
  stable && /^setpath_json "product" "tunnelApplicationConfig"/ { exit }
  stable { print }
' "${prepare_script}" >"${tmp_dir}/stable-branch.sh"

extract_setters <"${tmp_dir}/stable-branch.sh" |
  awk -F '|' '$1 ~ /^win32/ || $1 == "tunnelApplicationName"' >"${tmp_dir}/windows.actual"
cat >"${tmp_dir}/windows.expected" <<'EOF'
win32AppUserModelId|VSCodium.VSCodium
win32DirName|VSCodium
win32MutexName|vscodium
win32NameVersion|VSCodium
win32RegValueName|VSCodium
win32ShellNameShort|VSCodium
win32AppId|{{763CBF88-25C6-4B10-952F-326AE657F16B}
win32x64AppId|{{88DA3577-054F-4CA1-8122-7D820494CFFB}
win32arm64AppId|{{67DEE444-3D04-4258-B92A-BC1F0FF2CAE4}
win32UserAppId|{{0FD05EB4-651E-4E78-A062-515204B47A3A}
win32x64UserAppId|{{2E1F05D1-C245-4562-81EE-28188DB6FD17}
win32arm64UserAppId|{{57FD70A5-1B8D-4875-9F40-C5553F094828}
tunnelApplicationName|codium-tunnel
win32TunnelServiceMutex|vscodium-tunnelservice
win32TunnelMutex|vscodium-tunnel
win32ContextMenu.x64.clsid|D910D5E6-B277-4F4A-BDC5-759A34EEE25D
win32ContextMenu.arm64.clsid|4852FC55-4A84-4EA1-9C86-D53BE3DF83C0
EOF
assert_exact_setters 'stable Windows identity' "${tmp_dir}/windows.actual" "${tmp_dir}/windows.expected"

# Once the macOS/non-macOS conditional closes, none of the macOS identity keys
# may be set again in the stable branch. This rejects a valid-looking setter
# followed by an override outside the extracted macOS block.
awk '
  $0 == "  fi" { after_os_identity = 1; next }
  after_os_identity { print }
' "${tmp_dir}/stable-branch.sh" | extract_setters |
  awk -F '|' '
    $1 == "nameShort" || $1 == "nameLong" || $1 == "applicationName" ||
    $1 == "dataFolderName" || $1 == "urlProtocol" ||
    $1 == "serverApplicationName" || $1 == "serverDataFolderName" ||
    $1 == "darwinBundleIdentifier" || $1 == "reportIssueUrl" ||
    $1 == "licenseUrl" { print }
  ' >"${tmp_dir}/macos-overrides.actual"
[[ ! -s "${tmp_dir}/macos-overrides.actual" ]] ||
  fail 'stable macOS identity is overridden after its platform block'

for workflow in ci-build-linux.yml ci-build-macos.yml ci-build-windows.yml; do
  grep -Eq '^  DISABLE_UPDATE: (yes|"yes")$' "${repo_root}/.github/workflows/${workflow}" ||
    fail "development workflow ${workflow} must disable updates"
done

printf 'PASS: stable macOS AI-Codium identity contract\n'

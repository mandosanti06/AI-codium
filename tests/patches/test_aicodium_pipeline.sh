#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2329 # literals inspect scripts; mocks are invoked after sourcing

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
prepare_script=${PREPARE_SCRIPT:-"${repo_root}/prepare_vscode.sh"}
tmp_dir=$(mktemp -d)
trap 'rm -rf "${tmp_dir}"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

grep -Fq 'AICODIUM_PIPELINE_BEGIN' "${prepare_script}" ||
  fail 'categorized AI-Codium pipeline is missing'
grep -Fq 'AICODIUM_SOURCE_COPY_BEGIN' "${prepare_script}" ||
  fail 'AI-Codium source-copy boundary is missing'

line_of() {
  local script=$1
  local literal=$2
  local line

  line=$(grep -nFx -- "${literal}" "${script}" | cut -d: -f1)
  [[ "${line}" =~ ^[0-9]+$ ]] || return 1
  printf '%s\n' "${line}"
}

prepare_integration_is_valid() {
  local script=$1
  local top_actions top_patches insider_stage os_stage user_stage
  local aicodium_patches aicodium_sources dependencies

  top_actions=$(line_of "${script}" 'for file in ../patches/*.json; do') || return 1
  top_patches=$(line_of "${script}" 'for file in ../patches/*.patch; do') || return 1
  insider_stage=$(line_of "${script}" '  for file in ../patches/insider/*.patch; do') || return 1
  os_stage=$(line_of "${script}" 'if [[ -d "../patches/${OS_NAME}/" ]]; then') || return 1
  user_stage=$(line_of "${script}" 'for file in ../patches/user/*.patch; do') || return 1
  aicodium_patches=$(line_of "${script}" 'apply_aicodium_patches') || return 1
  aicodium_sources=$(line_of "${script}" 'copy_aicodium_sources') || return 1
  dependencies=$(line_of "${script}" '# {{{ install dependencies') || return 1

  (( top_actions < top_patches &&
    top_patches < insider_stage &&
    insider_stage < os_stage &&
    os_stage < user_stage &&
    user_stage < aicodium_patches &&
    aicodium_patches < aicodium_sources &&
    aicodium_sources < dependencies ))
}

prepare_integration_is_valid "${prepare_script}" ||
  fail 'production preparation does not invoke AI-Codium after all upstream patch stages and before dependencies'

# Mutation checks prove this contract observes the production call sites, not
# merely the helper definitions or boundary comments.
deleted_patch_call=${tmp_dir}/prepare-without-patch-call.sh
sed '/^apply_aicodium_patches$/d' "${prepare_script}" >"${deleted_patch_call}"
if prepare_integration_is_valid "${deleted_patch_call}"; then
  fail 'integration contract accepted deletion of apply_aicodium_patches'
fi

deleted_copy_call=${tmp_dir}/prepare-without-copy-call.sh
sed '/^copy_aicodium_sources$/d' "${prepare_script}" >"${deleted_copy_call}"
if prepare_integration_is_valid "${deleted_copy_call}"; then
  fail 'integration contract accepted deletion of copy_aicodium_sources'
fi

reordered_calls=${tmp_dir}/prepare-with-reordered-calls.sh
reordered_calls_intermediate=${tmp_dir}/prepare-with-reordered-calls.intermediate
sed \
  -e '/^apply_aicodium_patches$/c\__AICODIUM_PATCH_CALL__' \
  -e '/^copy_aicodium_sources$/c\apply_aicodium_patches' \
  "${prepare_script}" >"${reordered_calls_intermediate}"
sed '/^__AICODIUM_PATCH_CALL__$/c\copy_aicodium_sources' \
  "${reordered_calls_intermediate}" >"${reordered_calls}"
if prepare_integration_is_valid "${reordered_calls}"; then
  fail 'integration contract accepted source copy before AI-Codium patches'
fi

# Load only the production pipeline functions. The mocks record the observable
# action/patch order without preparing or downloading Code OSS.
sed -n '/^# AICODIUM_PIPELINE_FUNCTIONS_BEGIN$/,/^# AICODIUM_PIPELINE_FUNCTIONS_END$/p' \
  "${prepare_script}" >"${tmp_dir}/pipeline-functions.sh"
# shellcheck source=/dev/null
source "${tmp_dir}/pipeline-functions.sh"

fixture=${tmp_dir}/fixture
mkdir -p "${fixture}/vscode/src/vs/platform" "${fixture}/vscode/extensions"
mkdir -p "${fixture}/patches/aicodium/product" \
  "${fixture}/patches/aicodium/platform" \
  "${fixture}/patches/aicodium/workbench"
mkdir -p "${fixture}/src/aicodium-runtime/vscode" \
  "${fixture}/src/aicodium-extension/vscode"

for file in \
  product/20-last.json product/10-first.json product/30-last.patch product/05-first.patch \
  platform/20-last.json platform/10-first.patch \
  workbench/10-first.json workbench/20-last.patch; do
  : >"${fixture}/patches/aicodium/${file}"
done
printf 'runtime payload\n' >"${fixture}/src/aicodium-runtime/vscode/runtime.txt"
printf 'extension payload\n' >"${fixture}/src/aicodium-extension/vscode/extension.txt"

log=${tmp_dir}/order.log
apply_actions() { printf 'action:%s\n' "${1#../patches/aicodium/}" >>"${log}"; }
apply_patch() { printf 'patch:%s\n' "${1#../patches/aicodium/}" >>"${log}"; }

(
  cd "${fixture}/vscode"
  apply_aicodium_patches
  copy_aicodium_sources
)

cat >"${tmp_dir}/expected-order" <<'EOF'
action:product/10-first.json
action:product/20-last.json
patch:product/05-first.patch
patch:product/30-last.patch
action:platform/20-last.json
patch:platform/10-first.patch
action:workbench/10-first.json
patch:workbench/20-last.patch
EOF
diff -u "${tmp_dir}/expected-order" "${log}" ||
  fail 'categories or files are not applied in deterministic order'

[[ -f "${fixture}/vscode/src/vs/platform/aicodiumRuntime/runtime.txt" ]] ||
  fail 'runtime payload was not copied to its documented destination'
[[ -f "${fixture}/vscode/extensions/aicodium/extension.txt" ]] ||
  fail 'extension payload was not copied to its documented destination'

# README files document the repository boundary and are not product payloads.
printf 'documentation only\n' >"${fixture}/src/aicodium-runtime/README.md"
(
  cd "${fixture}/vscode"
  copy_aicodium_sources
)
[[ ! -e "${fixture}/vscode/src/vs/platform/aicodiumRuntime/README.md" ]] ||
  fail 'repository README leaked into product runtime source'

# Optional absent categories and payload directories must be harmless.
mkdir -p "${tmp_dir}/optional/vscode/src/vs/platform" "${tmp_dir}/optional/vscode/extensions"
mkdir -p "${tmp_dir}/optional/patches/aicodium"
mkdir -p "${tmp_dir}/optional/src"
(
  cd "${tmp_dir}/optional/vscode"
  apply_aicodium_patches
  copy_aicodium_sources
)

# A failed patch must terminate the pipeline before later categories run.
failure_log=${tmp_dir}/failure.log
apply_actions() { printf 'action:%s\n' "$1" >>"${failure_log}"; }
apply_patch() {
  printf 'patch:%s\n' "$1" >>"${failure_log}"
  [[ "$1" != *product/05-first.patch ]]
}
if (
  cd "${fixture}/vscode"
  apply_aicodium_patches
); then
  fail 'failed AI-Codium patch did not stop preparation'
fi
grep -Fq 'product/05-first.patch' "${failure_log}" ||
  fail 'failure fixture did not reach the intended patch'
if grep -Eq 'platform|workbench' "${failure_log}"; then
  fail 'pipeline continued after a failed patch'
fi

# A destination that resolves outside prepared vscode must be rejected before
# any source bytes are copied.
escape=${tmp_dir}/escape
mkdir -p "${escape}"
mv "${fixture}/vscode/src/vs/platform/aicodiumRuntime" \
  "${fixture}/vscode/src/vs/platform/aicodiumRuntime.saved"
ln -s "${escape}" "${fixture}/vscode/src/vs/platform/aicodiumRuntime"
if (
  cd "${fixture}/vscode"
  copy_aicodium_sources
); then
  fail 'source copy accepted a destination outside prepared vscode'
fi
[[ ! -e "${escape}/runtime.txt" ]] ||
  fail 'source bytes were copied before destination containment was proven'

if grep -Eq '(find|globstar|\*\*)[^\n]*patches/aicodium' "${prepare_script}"; then
  fail 'AI-Codium patches use an unconstrained recursive traversal'
fi

printf 'PASS: deterministic AI-Codium patch and source pipeline\n'

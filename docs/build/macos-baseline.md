# Reproducible macOS baseline

This procedure establishes the unmodified VSCodium-derived macOS baseline before
AI-Codium product patches. It builds the stable macOS package separately for `arm64`
and `x64`; it does not publish a release.

## Pinned inputs

| Input | Recorded value | Source of truth |
| --- | --- | --- |
| VSCodium revision | `37774bd84647d5910edfdb815ac98829e16e411e` | Baseline fork commit for issue #11 |
| Code OSS revision | `7e7950df89d055b5a378379db9ee14290772148a` (`1.126.0`) | `upstream/stable.json` |
| Node.js | `24.15.0` | `.nvmrc` |

Before reproducing a historical baseline, verify the checked-out fork commit and the
Code OSS pin rather than trusting this document alone:

```bash
git rev-parse HEAD
jq -r '.tag, .commit' upstream/stable.json
cat .nvmrc
```

## Prerequisites

Run each architecture on a matching macOS host: Apple Silicon for `arm64` and an Intel
macOS runner for `x64`. Install Xcode Command Line Tools, Git, `jq`, Python 3.11,
Rustup, and the Node.js version in `.nvmrc`. For example, after installing `nvm`:

```bash
xcode-select --install
nvm install "$(cat .nvmrc)"
nvm use "$(cat .nvmrc)"
node --version
python3 --version
jq --version
rustc --version
```

The build downloads the pinned Code OSS commit and npm dependencies. Ensure the host
can reach GitHub, the VS Code update endpoint, and the npm registry.

## Local reproduction

Run the following function once on an Apple Silicon macOS host with `arm64`, and once
on an Intel macOS host with `x64`. It removes only generated directories in this
repository before each architecture so the output is not reused.

```bash
build_macos_baseline() {
  local arch="$1"

  rm -rf vscode VSCode-darwin-arm64 VSCode-darwin-x64 vscode-cli assets
  export APP_NAME=VSCodium
  export BINARY_NAME=codium
  export CI_BUILD=no
  export GH_REPO_PATH=VSCodium/vscodium
  export ORG_NAME=VSCodium
  export OS_NAME=osx
  export SHOULD_BUILD=yes
  export VSCODE_ARCH="$arch"
  export VSCODE_QUALITY=stable

  . ./get_repo.sh
  ./build.sh
  ./prepare_assets.sh
}

build_macos_baseline arm64
mkdir -p baseline-artifacts
mv assets baseline-artifacts/arm64

build_macos_baseline x64
mv assets baseline-artifacts/x64
```

The focused build command is `./build.sh`. `get_repo.sh` must be sourced first because
it resolves and exports the pinned Code OSS revision and release version used by the
build. Do not use `./dev/build.sh` as the packaging baseline.

## Expected artifacts

With no signing credentials, `prepare_assets.sh` produces unsigned ZIP archives and
checksums. The exact `${RELEASE_VERSION}` is computed by `get_repo.sh`; confirm it in
the command output. Expected files include:

```text
baseline-artifacts/arm64/VSCodium-darwin-arm64-${RELEASE_VERSION}.zip
baseline-artifacts/x64/VSCodium-darwin-x64-${RELEASE_VERSION}.zip
baseline-artifacts/<architecture>/*.sha256
baseline-artifacts/<architecture>/*.sha1
```

DMGs and notarization are intentionally absent without macOS signing credentials.
Their absence does not invalidate this unsigned upstream build baseline.

## GitHub Actions reproduction

`.github/workflows/ci-build-macos.yml` is the stable baseline workflow. Its matrix
uses `macos-14` for `arm64` and `macos-15-intel` for `x64`, reads Node from `.nvmrc`,
and runs `./build.sh` for each architecture.

For a branch that changes a build script, patch, `product.json`, runtime source, or
bundled extension source, opening a pull request runs both matrix jobs automatically.
Each successful PR job uploads a three-day artifact named `bin-arm64` or `bin-x64`.
The workflow has `permissions: {}` and no release step, so pull requests cannot publish
releases.

To run the same workflow manually with artifacts enabled:

```bash
gh workflow run ci-build-macos.yml --ref issue/11-macos-baseline -f generate_assets=true
```

Use the Actions run URL to record links to both successful matrix jobs and their
`bin-arm64` and `bin-x64` artifacts. GitHub macOS runners are the required evidence
for actual macOS artifacts; a non-macOS host can validate only the static contract.

## Failure recovery

| Failure | Architecture and failed step | Recovery action |
| --- | --- | --- |
| A patch no longer applies after Code OSS changes | The affected matrix architecture; `Clone Code OSS source` or `Build macOS <arch> baseline` | Confirm `upstream/stable.json` still records the intended tag and commit. Re-run from a clean generated tree; if the pin must change, update it in a dedicated upstream-sync change and refresh the baseline evidence. |
| Signing or notarization credentials are unavailable | Either architecture; `Prepare unsigned macOS <arch> baseline artifacts` | Do not add credentials to a PR. Keep the unsigned ZIP baseline and use the publishing workflow only after authorized release signing configuration exists. |
| Code OSS or npm dependency download fails | The affected architecture; `Clone Code OSS source` or `Build macOS <arch> baseline` | Check network access and retry the same pinned commit. Preserve the failing log, then inspect the source endpoint or registry outage before changing pins. |
| A job fails on only one architecture | `macOS arm64 baseline` or `macOS x64 baseline`; the named failed step | Follow the matching row above, rerun only the failing matrix job, and compare its runner/tool versions with the successful architecture. |

Every CI failure is labelled by the matrix architecture and step name; include both in
the issue or pull-request recovery record.

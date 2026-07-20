# AI-Codium Product Identity

AI-Codium's stable macOS build uses a distinct identity so it can coexist with
VSCodium without sharing application data, server data, URL handlers, or the
macOS bundle identifier. The stable identity contract is enforced by
`tests/product/test_identity.sh`.

| Product field | Stable macOS value |
| --- | --- |
| `nameShort`, `nameLong` | `AI-Codium` |
| `applicationName` | `ai-codium` |
| `dataFolderName` | `.ai-codium` |
| `urlProtocol` | `ai-codium` |
| `serverApplicationName` | `ai-codium-server` |
| `serverDataFolderName` | `.ai-codium-server` |
| `darwinBundleIdentifier` | `io.github.mandosanti06.aicodium` |
| `reportIssueUrl` | `https://github.com/mandosanti06/AI-codium/issues/new/choose` |
| `licenseUrl` | `https://github.com/mandosanti06/AI-codium/blob/master/LICENSE` |

Windows identifiers and the VSCodium Insider identity are intentionally
unchanged. Other platform renaming belongs in a later platform-specific issue.

## Updates

AI-Codium has no approved release-metadata service yet. Development workflows
therefore build with `DISABLE_UPDATE=yes`; development builds do not read or
install updates from VSCodium's update metadata. Until an AI-Codium update
design is approved, update manually by downloading and installing a trusted
AI-Codium artifact from this repository's GitHub Actions or releases page.

Do not configure VSCodium's update URL as a fallback: AI-Codium artifacts and
VSCodium release metadata have different product identities and provenance.

## Attribution and license

AI-Codium remains derived from VSCodium and Microsoft Code OSS. The repository
retains the upstream MIT `LICENSE`; the product license link points to that
preserved license in the AI-Codium repository. Product renaming does not remove
or replace upstream copyright, license, or source attribution.

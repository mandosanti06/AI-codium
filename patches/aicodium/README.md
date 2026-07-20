# AI-Codium patch ownership

AI-Codium owns the patches below this directory. They modify the pinned Code
OSS source after the existing top-level, quality, platform, and user VSCodium
patches have applied.

## Categories and order

Preparation processes only these explicit categories, in this order:

1. `product` — product defaults, names, menus, commands, and feature flags.
2. `platform` — provider-neutral services, IPC, storage bridges, and lifecycle.
3. `workbench` — native chat UI, settings, approvals, and session integration.

Within each category, `*.json` action files are applied lexically first, then
`*.patch` files lexically. Missing categories are optional. Nested directories
are not traversed implicitly; adding another category or depth requires an
intentional preparation-pipeline change and test update.

## Required ownership header

Every patch must begin with comments recording:

- `Owner: AI-Codium`
- `Issue: #<number>`
- `Code OSS: <version and commit>`
- `Purpose: <single focused change>`
- `Regenerate: <exact command>`
- `Verify: <focused command>`

Generate a patch from the prepared `vscode` Git worktree with, for example:

```bash
git -C vscode diff --binary -- src/vs/platform/example.ts > patches/aicodium/platform/10-example.patch
```

Record the Code OSS version and commit from `package.json` and the prepared
source `HEAD`; do not infer them from the current date. Run the focused test in
the header plus `bash tests/patches/test_aicodium_pipeline.sh`.

## Conflict recovery

When a patch fails, preparation stops. Record the first conflicting patch and
the pinned Code OSS revision, reproduce against a clean prepared tree, and
refresh only that owned patch. Review the refreshed diff for upstream behavior
that has moved or become redundant, rerun its focused verification and both
macOS baseline builds, then preserve the evidence in the issue and draft PR.
Never skip, reorder, or force-apply a conflicting patch to make a build pass.

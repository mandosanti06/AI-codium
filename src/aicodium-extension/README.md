# AI-Codium bundled extension source

**Owner:** AI-Codium extension maintainers
**Boundary:** first-party extension-host integration only

Production files placed in this directory's `vscode/` payload are copied to
`vscode/extensions/aicodium/` after every patch succeeds. This README is
repository documentation and is deliberately not bundled into the editor.

Each change must link its issue, record the compatible Code OSS and extension
API versions, document regeneration for generated files, and name focused
extension tests. Do not add proprietary extensions, provider credentials, or
undocumented prebuilt assets.

If an upstream extension layout or API change conflicts with this boundary,
stop preparation, record the pinned Code OSS commit and failing path, update
the relevant contract or ADR when required, regenerate affected files, and run
the pipeline and extension tests before resuming the build.

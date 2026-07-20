# AI-Codium isolated runtime source

**Owner:** AI-Codium runtime maintainers
**Boundary:** provider, routing, tool, and agent runtime code only

Production files placed in this directory's `vscode/` payload are copied to
`vscode/src/vs/platform/aicodiumRuntime/` after every patch succeeds. This
README is repository documentation and is deliberately not copied.

Each change must record its issue, compatible Code OSS version and IPC contract
version, regeneration steps for generated files, and focused tests. Generated
artifacts must be reproducible and must not contain credentials or provider
payloads.

If upstream changes conflict with the destination, stop preparation, identify
the pinned Code OSS commit and first conflicting path, update the owning ADR or
contract when required, regenerate affected files, and rerun the pipeline test
and relevant runtime tests before resuming the build.

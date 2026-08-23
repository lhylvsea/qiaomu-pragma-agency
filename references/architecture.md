# Architecture and Install Contract

## What is bundled

`assets/bundles/agency-agents-all.pragma` is a Pragma v1 Bundle generated from the pinned `jnMetaCode/agency-agents-zh` checkout. It contains 275 `Expert` resources, 275 `Capability` resources backed by `pragma.desktop.capability@v1`, one `RuntimeProfile`, one `ExpertTeam`, and the embedded Skill files. The optional manufacturing Bundle contains the curated 11-expert team.

The Bundle is intentionally embedded in this Skill. A Windows user does not need to download or execute the 275 Markdown files. The installer still clones `pqpo/pragma` because this Skill does not redistribute Pragma source code; it applies only the small compatibility change needed by the current importer.

## Runtime sequence

```text
agent installs lvsea-zhuanjia
        |
        v
check Windows / Node 22+ / Git / Corepack
        |
        v
clone or reuse pqpo/pragma  -----> backup %USERPROFILE%\.pragma
        |                                  |
        +--> patch imported capability binding | (id only)
                                           v
                 headless Bundle inspect + startImport
                                           |
                                           v
                 275 Expert + 275 Skill Capability + ready installation
                                           |
                                           v
                 verify pending refs / create shortcut / start Pragma
```

## Portable resource shape

Each source Markdown file becomes:

1. a `Capability` with adapter `pragma.capability.skill@v1`;
2. a `Skill` payload with `descriptor.json` and `files/SKILL.md`;
3. an `Expert` that references that Capability;
4. a member of the `All Agency Experts` root team, except the orchestrator, which is the coordinator.

The project copy of each Markdown file is also retained inside the Bundle so that the imported project remains inspectable and its artifact hashes can be checked by Pragma.

## Compatibility patch

The desktop host binding contract accepts its local capability lookup key. Portable Skill config in an imported Bundle also contains `source` and `entry` fields. The patch makes the host binding use `{ key: binding.id }`, preserving the portable fields in the Bundle while satisfying the desktop adapter. It is applied idempotently and is backed up in the source tree before modification.

## Data and credential boundary

- Bundle assets are public-source-derived and contain no user credentials.
- User data lives in `%USERPROFILE%\.pragma`; the installer creates a timestamped backup before mutating it.
- The Codex Local Runtime is referenced by the Bundle but is not supplied by this package. Pragma must discover the user's local Codex CLI/runtime; model authentication remains local.
- The scripts never write secrets to `manifest.json`, reports, the Skill package, or the GitHub repository.

## Idempotency and rollback

- A ready installation with the same source fingerprint is verified and not imported a second time.
- If resource references conflict, import uses `copy` semantics so existing resources remain intact.
- On failure, the backup path is printed and `scripts/rollback_pragma_agency.ps1 -BackupPath <path>` can restore only that explicit backup into `%USERPROFILE%\.pragma` after Pragma is stopped.

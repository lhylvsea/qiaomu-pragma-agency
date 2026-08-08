# Upstream Provenance

## Primary inputs

- [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) — MIT, AgentLand Contributors; source Markdown expert Skills.
- [pqpo/pragma](https://github.com/pqpo/pragma) — Pragma Source Available License 1.0; desktop host, project model, Bundle importer, local capability store and runtime integration.

Pinned local source commits used for the current build:

- `agency-agents`: `ebe9c99acb5c96f9468de368d8bead775387d1a7`
- `pragma`: `16151d1fcddc24a1b0b96aa05d2d34f523dc5289`

The package redistributes the generated Pragma Bundle asset, not a copy of the Pragma source tree. The Pragma license and branding remain with the upstream source checkout. The generated Bundle retains upstream Skill content and should be treated as MIT-derived content with source attribution.

## Prior-art mechanisms used

- `agent-import`: inspect a manifest and summarize contents before applying a migration; adapted to Bundle inspection and post-write verification.
- `computer-use`: capture/verify after a state-changing action; adapted to filesystem, process, port and Pragma-state verification rather than GUI automation.
- Qiaomu meta workflow: feature-branch publication, versioned release, clean install and evidence-bound claims.

# Troubleshooting

| Symptom | Evidence to collect | Safe action |
|---|---|---|
| `This imported Expert, Team, or Flow still has unresolved local dependencies` | `verify_pragma_agency.ps1` and `installations.json` | Stop Pragma, back up `.pragma`, run the installer/repair path so included Skill payloads are materialized and bound to local capability IDs. |
| Pragma shows fewer than 275 experts | Bundle file hash, project resource count, capability count | Re-run `verify_pragma_agency.ps1`; if the fingerprint is absent, import `agency-agents-all.pragma` again with `copy` conflict policy. |
| Bundle is `needs_setup` because Runtime is unavailable | `node`/Codex CLI version and Pragma runtime discovery | Install/authenticate the local Codex Runtime on the same Windows account, then re-run verification. Do not put a token in the Skill. |
| Shortcut opens and closes immediately | Shortcut target/arguments and PowerShell error output | Run `scripts/start_pragma.ps1` in a visible terminal; fix Node/pnpm/source path, then recreate the shortcut. |
| `pnpm install` fails | `node --version`, `corepack --version`, network error | Use Node.js >=22 and a reachable npm registry; keep `pnpm-lock.yaml` unchanged. No source or user-data deletion is required. |
| Existing resources must be preserved | Backup directory and project revision | Do not use a destructive reset. Use the printed backup and `copy` conflict policy; rollback only the explicit backup if needed. |

## Minimal diagnostics

```powershell
node --version
git --version
corepack pnpm@10.12.1 --version
& .\scripts\verify_pragma_agency.ps1 -Json
```

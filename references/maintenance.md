# Maintenance Contract

- Owner: `lhylvsea` / package maintainer for the GitHub repository.
- Review cadence: quarterly, and whenever `agency-agents-zh` or Pragma changes its Bundle/runtime contract.
- Update rule: rebuild the embedded Bundle from a reviewed source checkout; record the source commit and Bundle fingerprint; bump `manifest.json`; rerun static, Bundle, runtime, PR, Release, discovery, and clean-install gates.
- Rollback boundary: only the timestamped `.pragma` backup created by this package. Do not reset a user's whole home directory or rewrite unrelated Pragma projects.
- Supported target: Windows desktop with Node.js >=22, Git, Corepack/pnpm and a locally available/authenticated Codex runtime. Other platforms are explicitly out of scope for the automation scripts.
- Evidence boundary: the package verifies structure, importability, counts, readiness and pending references; it does not claim provider-backed quality scores or human blind-review results for the expert prompts.

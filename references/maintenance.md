# Maintenance Contract

- Owner: Qiaomu / package maintainer who publishes the GitHub repository.
- Review cadence: quarterly, and whenever either upstream repository changes its Bundle/runtime contract.
- Update rule: rebuild the embedded Bundle from a reviewed source checkout; bump `manifest.json`; rerun local, trigger, runtime, PR, Release, discovery, and clean-install gates.
- Rollback boundary: only the timestamped `.pragma` backup created by this package. Do not reset a user's whole home directory or rewrite unrelated Pragma projects.
- Supported target: Windows desktop with Node.js >=22, Git, Corepack/pnpm and a locally available/authenticated Codex runtime. Other platforms are explicitly out of scope for the automation scripts.
- Missing evidence: this package has local static validation and a real local Pragma verification; it does not claim provider-backed quality scores for the 270 upstream expert prompts or human blind-review results.

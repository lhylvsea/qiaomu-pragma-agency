# Upstream Provenance

## Primary inputs

- [jnMetaCode/agency-agents-zh](https://github.com/jnMetaCode/agency-agents-zh) — MIT；本次 Bundle 的直接来源，当前快照包含 275 个带 `name` frontmatter 的专家 Markdown。
- [pqpo/pragma](https://github.com/pqpo/pragma) — Pragma Source Available License 1.0；提供 DSL、Bundle 导出/导入、桌面能力注册和 Runtime 集成。
- [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) — jnMetaCode 项目的历史来源之一，仅作为内容谱系参考，不是本次发布包的直接输入。

## Current build pins

- `agency-agents-zh`: `83248ab15a78f9ddad897369c8d0be873653574a`（已运行上游 `scripts/check-counts.mjs`，结果为 275）。
- `pragma`: `c7ccba962c8420e3c7b033d081b4907e293f8c3d`（用于导出和重新加载 Bundle 的 Pragma 解释器）。
- 主 Bundle 指纹：`5f5c7ad386c3632f3d616adf923b213b65b7f88b5a68a53e07e5e593191a37b9`。

本仓库发布生成后的 Pragma Bundle，不复制 Pragma 源码。Bundle 中的专家 Markdown 保留直接上游内容和许可归属；Pragma 源码在用户安装时从上游获取，使用前应自行复核其许可边界。

## Integration decisions

- 保留 `assets/bundles/agency-agents-all.pragma` 文件名与 `PRAGMA_AGENCY_*` 环境变量，以兼容既有安装参数。
- 将主 Bundle 从旧的 270 个英文来源快照替换为 275 个 `agency-agents-zh` 专家，并把每个角色编译为一对 `Expert` / `Capability`。
- 以 `All Agency Experts` 作为唯一默认根团队；可选的 11 人制造运营团队继续独立保留。
- 安装器仍只写用户 Pragma 目录、备份目录和桌面快捷方式，不把 Runtime 凭据写入仓库。

## Prior-art mechanisms used

- Bundle 导入流程：先 inspect，再以 `copy` 冲突策略 startImport，最后验证 `ready` 和 pending 引用。
- 本机状态验证：复用 Pragma 的项目、Capability、Bundle Installation 和 Runtime 状态，而不是只统计压缩包文件。
- Skill 制作与发布流程：按 `lvsea-zao-skill` 完成来源核验、整合、验证、分支、PR、Release 和干净安装检查。

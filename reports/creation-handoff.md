# Creation handoff

## Result

- Skill：`lvsea-zhuanjia` `0.3.0`
- 目标：把 `jnMetaCode/agency-agents-zh` 的 275 个专家整合为可导入 Pragma 的 Windows Bundle，同时保留安装、修复、启动、验证和回滚闭环。
- 上游快照：`83248ab15a78f9ddad897369c8d0be873653574a`
- 主 Bundle：`assets/bundles/agency-agents-all.pragma`

## Integration decisions

- 保留既有 Bundle 文件名、PowerShell 文件名和 `PRAGMA_AGENCY_*` 环境变量，降低升级成本。
- 将旧的 270 个来源快照替换为 275 个 `agency-agents-zh` 专家；每个角色包含一个 `Expert`、一个 `Capability` 和一个 Skill payload。
- 使用唯一的 `All Agency Experts` 根团队；`specialized/agents-orchestrator.md` 作为协调专家，其余专家作为成员。
- 继续保留可选的 11 人制造运营团队。
- 公开身份统一为 `lvsea-zhuanjia`；旧的备份 kind 仍被回滚脚本接受。

## Evidence recorded

- 上游 `scripts/check-counts.mjs`：275 个角色。
- Pragma 导出/重新加载：`275 Capability + 275 Expert + 1 RuntimeProfile + 1 ExpertTeam`。
- Bundle requirements：276（275 个 Skill binding + 1 个 Runtime）。
- 生成 Bundle 指纹：`5f5c7ad386c3632f3d616adf923b213b65b7f88b5a68a53e07e5e593191a37b9`。
- Python 包测试、GitHub PR/Release、远端发现和干净安装：由发布前门禁继续确认，未通过前不应宣称发布完成。

## Limits

- 没有 provider-backed 质量评分、人工盲评或 275 个专家提示的专业正确率证据。
- Runtime 是否可用取决于用户本机 Codex CLI、Pragma 版本和模型认证状态。
- Pragma 上游许可证对托管服务和商业嵌入有额外边界，发布者需自行复核。

# Pragma Agency Agents

把 [agency-agents](https://github.com/msitarzewski/agency-agents) 的 270 个专家提示与 Skill 文件预装成 [Pragma](https://github.com/pqpo/pragma) 的可用 `Expert`、`ExpertTeam` 和 `Capability`。在 Windows 上安装这个 Skill 后，智能体可以自动准备 Pragma、导入专家包、修复 `unresolved local dependencies`、创建桌面快捷方式并验证 Mission 前置依赖。

## 安装

发布后，在 Windows 上执行：

```powershell
npx skills add lhylvsea/qiaomu-pragma-agency
```

把 `OWNER` 换成实际 GitHub 用户名。也可以在支持 Agent Skills 的智能体中直接说：

> 安装 Pragma Agency Agents，让 270 个专家开箱可用，创建桌面快捷方式并验证能新建 Mission。

你可以直接这样说：“修复 Pragma 的 unresolved local dependencies，保留我的 `.pragma` 数据，最后告诉我 270 个专家是否 ready。”

## 使用

Skill 默认导入 `assets/bundles/agency-agents-all.pragma`，包含：

- 270 个 `Expert`
- 270 个内嵌 `Skill` 能力
- 一个 `All Agency Experts` 总入口团队
- Codex Local Runtime 配置（凭据仍由本机 Pragma/Codex 管理）

可选地要求导入制造运营精选团队：

```powershell
& .\scripts\install_pragma_agency.ps1 -IncludeManufacturingTeam
```

常用复核与启动：

```powershell
& .\scripts\verify_pragma_agency.ps1
& .\scripts\start_pragma.ps1
```

安装脚本默认使用 `%USERPROFILE%\Pragma\pragma` 作为 Pragma 源码目录、`%USERPROFILE%\.pragma` 作为数据目录；会先创建带时间戳的备份，再执行导入。若同一 Bundle 已经是 `ready`，重复执行只验证，不重复写入资源。

## 运行要求

- Windows 10/11
- Node.js 22+
- Git、Corepack/pnpm 10.12.1
- 本机已可调用并完成认证的 Codex CLI/Local Runtime

不需要把 API key、Cookie、密码或 Mission 数据写进 Skill，也不需要把它们上传到 GitHub。Pragma 源码由安装脚本从上游仓库获取，Skill 只携带生成后的 Bundle 资产与适配脚本。

## 验证与回滚

安装完成必须看到 `270` 个 Agency Expert、`270` 个 Skill 能力、安装状态 `ready`，且目标 Team 的 `isRefPending` 为 `false`。失败时保留脚本输出的备份路径，可在停止 Pragma 后执行：

```powershell
& .\scripts\rollback_pragma_agency.ps1 -BackupPath <backup-path>
```

验证细节、Runtime 约束、信任边界和上游版本见 `references/` 与 `reports/`。

本包的静态门禁命令为：

```powershell
python scripts/validate_skill.py .
python scripts/trigger_eval.py . --cases evals/trigger_cases.json
python scripts/export_skill_ir.py . --output reports/skill-ir.json
```

## Troubleshooting

If a Windows `predev` script reports that `pnpm` is not recognized, the bundled PowerShell scripts create a user-local `pnpm@10.12.1` shim under `%LOCALAPPDATA%\qiaomu-pragma-agency\bin`; no global package-manager configuration is required.

如果 Bundle 显示 `needs_setup`，先执行 `scripts/verify_pragma_agency.ps1` 查看 Runtime、Skill health 和 pending 引用；确认 Codex CLI 在同一 Windows 账户的 PATH 中，再重试安装。不要把 token 写进命令、报告或 Bundle。

## Upstream credit

本包的主要来源是 [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) 与 [pqpo/pragma](https://github.com/pqpo/pragma)，固定提交、许可证和派生关系见 `references/upstream.md`。

## 许可与来源

- 上游 Agency Agents：MIT，保留 AgentLand Contributors 的归属。
- 上游 Pragma：Pragma Source Available License 1.0；该许可对托管服务和商业嵌入有额外限制。本文档不授予超出上游许可的 Pragma 权利。
- 本 Skill 的集成脚本与文档采用 MIT；嵌入 Bundle 中的上游内容仍按各自上游许可处理。

当前构建来源提交、先例研究和限制记录在 `references/upstream.md`、`reports/prior-art-research.md` 与 `reports/creation-handoff.md`。

上游灵感与审查入口：`https://github.com/msitarzewski/agency-agents; https://github.com/pqpo/pragma; https://github.com/NousResearch/hermes-agent/tree/main/skills/autonomous-ai-agents/computer-use; https://github.com/Starchild-ai-agent/official-skills/tree/main/agent-import`

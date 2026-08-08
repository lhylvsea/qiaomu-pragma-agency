# Creation handoff

## 1. Result

- Skill：`qiaomu-pragma-agency` `0.1.1`
- 目标：在 Windows 上把 Agency Agents 的 270 个专家和 Skill 能力装入 Pragma，修复 Bundle 本地依赖，建立快捷方式并验证可用。
- 本地路径：`work/skills/qiaomu-pragma-agency`
- 发布状态：已发布到 `https://github.com/lhylvsea/qiaomu-pragma-agency`；PR #1 已合并，`v0.1.0` 已发布，远端发现与干净目录安装已通过。本次 `v0.1.1` 用于同步本报告和 README 的最终状态。

## 2. Reference skills studied

- `hermes-agent/computer-use`：学习状态变化后的可观察验证；对应 `scripts/verify_pragma_agency.ps1`、启动进程/端口检查和 post-install health 契约。遥测信号是 skills.sh installs `163`、SkillsMP repo stars `227004`，不表示质量评分。
- `official-skills/agent-import`：学习导入前读取 Manifest、按显式决策执行、导入后核对和清理；对应 Bundle inspect、备份 Manifest、幂等安装与回滚脚本。遥测信号是 skills.sh installs `173`，不表示质量评分。

## 3. Absorbed and rejected

- 保留：Manifest/Bundle 预检、写入前备份、写入后状态验证、显式失败边界。
- 适配：从通用 Agent 导入改为 Pragma `startImport`、`RuntimeProfile`、Capability payload 和 Windows PowerShell；把 GUI 观察改为项目 revision、安装记录和 pending 引用检查。
- 舍弃：远程内联执行、RDP/桌面控制、自动上传用户凭据；这些都不属于本次本地 Pragma 安装闭环。
- 原创：将 270 个上游 Markdown Skill 打包为单一 `All Agency Experts` 根团队，并把 Pragma 当前 `codex/openai/gpt-5.6-luna` Runtime 适配、绑定兼容补丁、快捷方式和回滚串成一个 Skill。

## 4. Advantages and highlights

| 类型 | 证据与说明 |
|---|---|
| design advantage | 单一 Bundle 根入口一次安装 270 个 Expert/270 个 Skill；可选制造运营精选团队，降低初次选择成本。 |
| design advantage | 运行脚本把 `.pragma` 备份、Bundle 导入、快捷方式、验证和回滚放在同一 Windows 工作流内。 |
| validated advantage | 空白 Pragma Home 实测导入后 `resourceCount=542`、`agencyExpertCount=270`、`agencySkillCount=270`、`readySkillCount=270`、安装 `ready`、`pending=false`。 |
| validated advantage | 同一隔离 Home 的第二次验证通过，未重复导入，证明相同 Bundle 指纹的幂等路径可用。 |
| hypothesis | 对未来不同 Codex 模型/Pragma 版本，运行时解析与可选环境覆盖预期能降低人工 setup；尚未在多个版本和多个模型上做兼容矩阵。 |

## 5. Verification and limits

- 已完成：上游来源检查、Bundle exporter 自校验（curated 24 resources、full 559、all-experts 542）、空白 Home runtime install、重复 verify、qiaomu `validate_skill.py`、IR、trigger eval、release check、GitHub Feature Branch/PR/Release、远端发现和干净目录通过 `npx skills add` 安装。
- 当前版本变更：将 Windows `pnpm` shim、最终 GitHub 安装命令和已发布证据写入交接材料；不改变 Bundle 内容和 Pragma 数据格式。
- 缺失证据：没有 provider-backed 质量评分、盲评或 270 个专家提示的人工质量对照；不把上游目录数量当作专业结论正确率。
- 排除权限：不打包或上传 API key、Cookie、密码、Mission 数据；不删除用户 `.pragma`，不推送默认分支，不执行未审查上游安装钩子。

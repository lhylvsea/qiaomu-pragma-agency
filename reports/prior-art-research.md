# Prior-art research

研究日期：2026-08-09。研究工具：qiaomu-meta-skill 的 `research_prior_art.py --strict --summary`。

## 查询与结果

| 查询 | skills.sh | SkillsMP | 合并候选族 |
|---|---:|---:|---:|
| Windows local desktop app agent bundle installation shortcut | 15 | 9 | 24 |
| Pragma agent expert bundle import local capability skill | 12 | 10 | 21 |

去重后得到 45 个候选族；两个目录均返回 `ok`，没有缺失证据。`skills.sh` 的 installs 是生态安装遥测，不是评分或正确性；SkillsMP 的 stars 是 GitHub 仓库星标，不是安装量、评分或单个 Skill 质量。本次没有把两个指标合并成一个分数。

## 实际打开并采用机制的候选

### `nousresearch/hermes-agent:computer-use`

- 来源：[GitHub SKILL.md](https://raw.githubusercontent.com/NousResearch/hermes-agent/main/skills/autonomous-ai-agents/computer-use/SKILL.md)
- 研究结果中的信号：skills.sh installs `163`、SkillsMP repo stars `227004`（均只按上述遥测语义记录；研究数据日期为 2026-08-09）。
- 实际采用：状态变化后截图/读取状态、验证窗口/进程/端口和失败边界。
- 落点：`scripts/verify_pragma_agency.ps1`、`scripts/start_pragma.ps1`、安装后的 `270/270/ready/isRefPending=false` 契约。

### `starchild-ai-agent/official-skills:agent-import`

- 来源：[GitHub SKILL.md](https://raw.githubusercontent.com/Starchild-ai-agent/official-skills/main/agent-import/SKILL.md)
- 研究结果中的信号：skills.sh installs `173`；未使用无关的星标或评分推断质量。
- 实际采用：应用迁移前先读取 Manifest/Bundle 内容，应用后执行清理与完整性复核。
- 落点：Bundle `inspect` → 显式 `startImport` → 备份 Manifest → post-install count/health/pending 验证。

## 只作为候选、未采用

`agent-rdp`、`desktop-app`、`winui-packaging`、`cli-serve` 等候选与 Windows/桌面主题相关，但没有为 Pragma Bundle 导入提供可直接复用的本地状态契约；没有把搜索结果中的描述当作实现依据。

## 研究结论

保留“先检查、再写入、写后验证”的共同机制；把 GUI 自动化改成 Pragma 原生 Bundle API、文件状态和进程检查，使安装过程可复现并可回滚。完整机器输出保存在 `prior-art-candidates.json`。

# Prior-art research

研究日期：2026-08-23。研究对象：`jnMetaCode/agency-agents-zh`、`lhylvsea/lvsea-pragma-agency` 和 `pqpo/pragma` 的公开源码与发布结构。

## 关键发现

| 对象 | 已确认事实 | 对整合的影响 |
|---|---|---|
| `agency-agents-zh` | MIT；当前提交实际有 275 个带 `name` frontmatter 的专家，仓库自带计数脚本可复核 | 不能继续沿用目标包中的 270 阈值；必须重建主 Bundle |
| `lvsea-pragma-agency` | Windows PowerShell 安装器、Pragma 补丁、Bundle 导入和回滚链路已存在 | 采用增量整合，保留脚本文件名和环境变量兼容 |
| `pqpo/pragma` | 当前解释器提供 `loadPragmaProject` 和 `exportBundle`，绑定载荷可携带 `descriptor.json` 与 Skill 文件 | 用官方导出机制生成新 Bundle，避免手工伪造 ZIP 指纹 |

## 采用的机制

- 先读取并核对两个仓库的 README、根 Skill、许可证、计数脚本、Bundle 结构和安装脚本。
- 将每个专家 Markdown 转为 `Capability` + `Expert`，再挂到一个 `ExpertTeam` 根入口。
- 导出后重新加载 Bundle，核对资源种类、数量、依赖要求和结构性文件。
- 安装器写入前备份、冲突使用 `copy`、写入后验证 `ready` 与 pending 引用。

## 不采用的方案

- 不把上游仓库整体复制到目标仓库：会带入无关平台集成和重复安装脚本，也不会自动成为 Pragma Capability。
- 不在运行时执行上游仓库的安装脚本：主包只携带已审查的 Bundle，Pragma 源码按自身安装流程获取。
- 不删除旧 Bundle 路径或旧回滚 kind：这会破坏已有环境的升级和回滚。

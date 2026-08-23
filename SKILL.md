---
name: lvsea-zhuanjia
description: |
  在 Windows 上把 jnMetaCode/agency-agents-zh 的 275 个中文优先专家目录预装进 pqpo/pragma，自动准备可直接使用的 Pragma Expert、Expert Team 和 Skill 能力，并创建桌面启动快捷方式。触发词包括“安装 Pragma 专家团”“把 agency-agents-zh 导入 Pragma”“把专家导入 Pragma”“Pragma 有 unresolved local dependencies”“修复 Pragma Bundle”“创建 Pragma 桌面快捷方式”。适用于四类场景：首次安装 275 个专家、修复导入包仍需 setup 的依赖错误、从桌面快捷方式启动 Pragma、升级或复核本地专家包。执行前检查 Windows、Node.js >=22、Git、Codex Local Runtime 和现有 .pragma 数据；写入前备份，写入后验证专家/能力/Bundle 状态。不会打包或索取 API key、Cookie、密码，也不会把用户凭据上传到 GitHub。
  来源材料是 [agency-agents-zh](https://github.com/jnMetaCode/agency-agents-zh) 的 MIT Markdown Skill 与 [Pragma](https://github.com/pqpo/pragma) Bundle 机制；适合安装、迁移、升级、修复和发布前复核这类流程化任务，不负责替用户提供模型凭据。
---

# Pragma 中文专家团 for Windows

把 agency-agents-zh 的 Markdown Skills 作为 Pragma Desktop Bundle 的内置能力使用。主 Bundle 已固定到提交 `83248ab15a78f9ddad897369c8d0be873653574a`，运行时不需要执行上游仓库脚本；Pragma 源码和本机 Runtime 仍由安装流程单独准备。优先执行本 Skill 的确定性脚本；脚本不可用时，按下述顺序完成同样的检查与回滚边界。

## 核心流程

1. 先读取 `references/architecture.md` 与 `references/troubleshooting.md`，确认本次是首次安装、修复、启动还是升级。
2. 仅在 Windows 上继续；检查 `node --version`、`git --version`、`corepack --version`，Node 必须满足 Pragma 当前仓库的 `engines.node`。
3. 调用 `scripts/install_pragma_agency.ps1`。它会按需克隆 `pqpo/pragma`、安装锁定依赖、应用最小的导入适配补丁、从包内 Bundle 导入专家与 Skill、创建快捷方式，并打印验证结果。
4. 若 Pragma 已存在，不覆盖用户数据：脚本先创建带时间戳的 `.pragma` 备份；同一 Bundle 已是 `ready` 时只做校验，未完成时才继续修复。
5. 导入后必须核对：275 个 Agency 专家资源、275 个内置 Skill 能力、Bundle 安装记录为 `ready`、目标 Team 的 `isRefPending` 为 `false`，并确认 Mission 创建前置依赖检查通过。
6. 需要启动时调用 `scripts/start_pragma.ps1`；需要单独创建快捷方式时调用 `scripts/create_pragma_shortcut.ps1`。快捷方式指向启动脚本而不是临时工作目录。

## 真实应用场景

- **首次安装**：用户说“在这台 Windows 电脑上装好 Pragma 和 275 个中文专家，装完直接能用”。
- **故障修复**：用户看到 `This imported Expert, Team, or Flow still has unresolved local dependencies`，要求修复后可以创建 Mission。
- **桌面启动**：用户关闭了 Pragma，要求从桌面双击重新启动开发版/本地版。
- **升级复核**：用户更新 Skill 或 Pragma 后，要求保留现有数据、重新导入 Bundle，并报告专家、能力和安装状态。

## 输出契约

完成时报告实际路径和证据：

- Pragma 源码目录、Pragma 数据目录、备份目录；
- Bundle 名称、资源数量、Skill 能力数量和安装状态；
- 桌面 `.lnk` 路径及其目标脚本；
- 执行过的验证命令和结果；
- 若 Codex CLI/Runtime 未就绪，明确标记为阻塞条件，不伪装成已完成。

## 边界与权限

- 默认只写入 `C:\Users\<user>\Pragma\`、`%USERPROFILE%\.pragma` 和用户桌面；写入前备份现有 `.pragma`。
- 默认只联网读取两个上游仓库和安装依赖；不执行上游仓库中未经审查的安装钩子。
- 不复制用户的模型密钥、Runtime 凭据、插件密钥或 Mission 数据到包内；Codex Local Runtime 仍由用户本机提供并认证。
- 不删除原始 Pragma 数据。回滚使用 `scripts/rollback_pragma_agency.ps1`，目标必须是本 Skill 创建的备份目录。
- 如果现有项目存在同名自定义资源，使用 `copy` 语义保留用户资源；不使用不可逆覆盖。

## 直接调用示例

```powershell
& .\scripts\install_pragma_agency.ps1 -IncludeManufacturingTeam
& .\scripts\verify_pragma_agency.ps1
& .\scripts\start_pragma.ps1
```

用户自然语言示例：

> “安装并配置 Pragma 中文专家团，默认导入 275 个专家，创建桌面快捷方式，最后验证能不能新建 Mission。”

> “Pragma 导入专家后提示 unresolved local dependencies，请先备份再修复，不要删我的现有数据。”

> “给我把当前 Pragma 的启动脚本放到桌面，双击能启动，并验证窗口和 5174 端口。”

> “升级这套专家 Skill，保留本地项目，报告有多少专家、能力和 ready Bundle。”

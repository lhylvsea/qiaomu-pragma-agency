# lvsea-zhuanjia

把 [agency-agents-zh](https://github.com/jnMetaCode/agency-agents-zh) 当前提交中的中文优先专家目录，整合成可被 [Pragma](https://github.com/pqpo/pragma) 导入的 Windows Bundle。安装后可直接使用 275 个 `Expert`、275 个 `Capability` 和一个 `All Agency Experts` 总入口团队。

这是一个适配层：专家 Markdown 内容来自上游 MIT 仓库，Pragma 源码仍由安装脚本按需获取；本仓库只发布生成后的 `.pragma` Bundle、Windows 安装/修复脚本和验证说明。

## 安装

在 Windows 上执行：

```powershell
npx skills add lhylvsea/lvsea-zhuanjia
```

也可以直接告诉智能体：

> 安装 Pragma 中文专家团，让 275 个专家开箱可用，创建桌面快捷方式并验证能新建 Mission。

修复既有安装时可以说：

> 修复 Pragma 的 unresolved local dependencies，保留我的 `.pragma` 数据，最后告诉我 275 个专家是否 ready。

## 使用

主 Bundle 是 `assets/bundles/agency-agents-all.pragma`，为兼容已有脚本和环境变量保留原文件名，内容已经更新为 `agency-agents-zh` 的 275 个专家：

- 275 个 `Expert`
- 275 个内嵌 `Skill` 能力
- 一个 `All Agency Experts` 专家团队
- Codex Local Runtime 配置；凭据仍由本机 Pragma/Codex 管理

可选导入 11 人制造运营精选团队：

```powershell
& .\scripts\install_pragma_agency.ps1 -IncludeManufacturingTeam
```

常用复核与启动：

```powershell
& .\scripts\verify_pragma_agency.ps1
& .\scripts\start_pragma.ps1
```

安装脚本默认使用 `%USERPROFILE%\Pragma\pragma` 作为 Pragma 源码目录、`%USERPROFILE%\.pragma` 作为数据目录；修改前创建带时间戳备份。同一 Bundle 已经是 `ready` 时，重复执行会优先复核，不重复创建相同安装。

## 四类真实场景

1. 首次安装 Pragma，并一次导入 275 个中文专家。
2. Pragma 提示 `unresolved local dependencies`，先备份再修复绑定。
3. 将 Pragma 启动脚本创建为桌面快捷方式并启动本地开发版。
4. 升级 Bundle 后保留已有项目，复核专家、能力、`ready` 状态和 pending 引用。

## 运行要求与边界

- Windows 10/11
- Node.js 22+
- Git、Corepack/pnpm 10.12.1
- 同一 Windows 账户下可发现并完成认证的 Codex CLI/Local Runtime

安装会联网读取指定的 GitHub 仓库并访问 npm registry；不会把 API key、Cookie、密码、插件密钥或 Mission 数据写入 Skill，也不会上传到 GitHub。Pragma 源码使用其上游许可，商业托管或嵌入前应自行复核许可边界。

## 验证与回滚

安装完成应看到 `275` 个 Agency Expert、`275` 个 Skill 能力、安装状态 `ready`，且目标 Team 的 `isRefPending` 为 `false`。失败时保留脚本输出的备份路径，停止 Pragma 后执行：

```powershell
& .\scripts\rollback_pragma_agency.ps1 -BackupPath <backup-path>
```

本仓库的静态门禁：

```powershell
python -m unittest discover -s tests -p "test_*.py" -v
python -m json.tool manifest.json > $null
python -m json.tool evals/trigger_cases.json > $null
```

Bundle 生成与来源固定信息见 [`references/upstream.md`](references/upstream.md)、[`references/architecture.md`](references/architecture.md) 和 [`references/bundle-build.md`](references/bundle-build.md)。

## 许可与来源

- [agency-agents-zh](https://github.com/jnMetaCode/agency-agents-zh)：MIT；本 Bundle 中的专家 Markdown 保留上游内容和归属。
- [Pragma](https://github.com/pqpo/pragma)：Pragma Source Available License 1.0；本仓库不重新发布 Pragma 源码。
- 本仓库新增的集成脚本、文档和适配代码：MIT，见 [`LICENSE`](LICENSE)。

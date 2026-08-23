# Bundle Build Record

主 Bundle 的生成不是运行时下载上游 Markdown，而是一次可审计的 Pragma 导出：

1. 从 `jnMetaCode/agency-agents-zh` 的固定提交读取带 `name` frontmatter 的 Markdown；
2. 对每个文件创建一个 `Capability` 和一个 `Expert`，并把专家挂到 `All Agency Experts`；
3. 使用 Pragma `loadPragmaProject(...).exportBundle({ roots, host })` 生成 `pragma.bundle/v1`；
4. 对导出的字节再次 `loadPragmaProject({ kind: "bundle" })`，核对资源数量和错误诊断；
5. 将生成结果写入 `assets/bundles/agency-agents-all.pragma`，并由 Python ZIP 检查和 Windows 安装器继续验收。

本次构建输入：

- agency-agents-zh commit: `83248ab15a78f9ddad897369c8d0be873653574a`
- pragma commit: `c7ccba962c8420e3c7b033d081b4907e293f8c3d`
- source agents: `275`
- exported resources: `275 Capability + 275 Expert + 1 RuntimeProfile + 1 ExpertTeam`
- exported requirements: `276`（275 Skill binding + 1 Runtime）
- bundle fingerprint: `5f5c7ad386c3632f3d616adf923b213b65b7f88b5a68a53e07e5e593191a37b9`

更新 Bundle 时必须重新记录这些值，并重新运行静态测试、Bundle 导入检查和目标 Windows 环境验证。不要在生成环节提交 Runtime 凭据或用户 `.pragma` 数据。

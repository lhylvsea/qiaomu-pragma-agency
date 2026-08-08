# Trust and rollback boundary

## Trusted inputs

- `agency-agents` 与 `pragma` 的固定上游仓库地址和本次记录的源提交。
- Skill 包内已生成并经过 Pragma exporter 自校验的 `.pragma` Bundle。
- Windows 本机的 Node.js、Git、Corepack 和 Codex CLI；只读取其版本/可用性，不读取凭据内容。

## Writes and network

- 网络：克隆/读取 `msitarzewski/agency-agents` 与 `pqpo/pragma`，以及安装 Pragma 依赖时访问 npm registry。
- 文件写入：Pragma 源码目录、`%USERPROFILE%\.pragma`、时间戳备份目录和 Desktop `.lnk`。
- 不写入：API keys、Cookie、密码、Codex token、Mission 内容或 GitHub secrets。

## Failure and rollback

- 导入前备份整个 `.pragma`，用 `backup-manifest.json` 标记归属。
- 资源冲突默认 `copy`，避免覆盖用户已有资源。
- 回滚脚本只接受本 Skill 创建且 Manifest 匹配的备份路径；不会对任意目录执行递归删除或恢复。
- Pragma 运行中不做回滚；先停止进程，再显式指定备份目录。

## Known limits

- 运行时凭据仍由用户本机 Pragma/Codex 管理；没有 Codex CLI 或模型不可用时，安装必须保持阻塞而不假报 ready。
- 当前包默认绑定本次已验证的 `codex / openai / gpt-5.6-luna`；不同 Pragma 版本或模型需要重新运行验证。
- Pragma 上游使用 Pragma Source Available License 1.0；公开发布本 Skill 不等于取得 Pragma 的托管服务或商业嵌入授权。

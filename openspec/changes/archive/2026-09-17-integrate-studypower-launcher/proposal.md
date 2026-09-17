## Why

StudyPower 已具备可运行的 Next.js 工作台，但目前只能从项目目录手动启动，无法纳入 OneStart 的统一 PowerShell 入口。将它接入现有启动器后，可以用同一套命令启动、查看状态并停止 StudyPower。

## What Changes

- 在 OneStart 中注册 StudyPower 项目路径、生产端口和本地访问地址。
- 增加 StudyPower 的运行检测、启动等待、浏览器打开和停止能力。
- 支持 `start studypower`、`studypower`、`stop studypower` 命令及交互菜单入口。
- 将 StudyPower 使用方式补充到启动器文档。
- 不修改 StudyPower 源码，不新增项目副本，不改变现有 `start all` 行为。

## Capabilities

### New Capabilities

- `studypower-launcher`: 通过 OneStart PowerShell 统一管理 StudyPower 本地 Web 工作台。

### Modified Capabilities

## Impact

- 代码：`System/Workflow-Launcher.ps1` 的配置、状态、菜单和命令分发逻辑。
- 文档：根目录 `README.md` 与 `System/README.md` 的命令清单。
- 外部依赖：调用现有 `F:\APP Location\StudyPower\package.json` 中的 `npm run start -- -p 3100`，不增加 npm 依赖。
- 运行时：OneStart 启动一个 StudyPower Next.js 生产进程并使用现有本地端口 `3100`。

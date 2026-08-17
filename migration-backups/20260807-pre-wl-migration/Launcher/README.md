# Workflow Launcher

管理本机 n8n 和 Dify 两个 AI 平台的启动、停止、状态查询和日志查看。

## 安装位置

```
E:\MorenAnzhuangLujing\Huangjingdajian\Launcher\
├── Workflow-Launcher.ps1   # 主脚本（PowerShell）
├── Workflow-Launcher.bat   # 双击启动入口
├── logs\                   # 运行日志
├── assets\                 # 资源文件
└── README.md               # 本说明
```

## 运行方式

### 方式一：双击 BAT 文件（推荐）

双击 `Workflow-Launcher.bat` 即可打开交互菜单。

### 方式二：命令行参数

```powershell
# 交互菜单
.\Workflow-Launcher.ps1

# 直接启动
.\Workflow-Launcher.ps1 start n8n
.\Workflow-Launcher.ps1 start dify
.\Workflow-Launcher.ps1 start all

# 直接停止
.\Workflow-Launcher.ps1 stop n8n
.\Workflow-Launcher.ps1 stop dify
.\Workflow-Launcher.ps1 stop all

# 查看状态
.\Workflow-Launcher.ps1 status

# 查看日志
.\Workflow-Launcher.ps1 logs n8n
.\Workflow-Launcher.ps1 logs dify
```

> 如果 PowerShell 提示执行策略限制，需先运行：
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

## 菜单功能

| 编号 | 功能 | 说明 |
|------|------|------|
| 1 | 启动 n8n | 启动 n8n 及其 PostgreSQL、Task Runner 服务 |
| 2 | 启动 Dify | 启动 Dify 全套服务（API、Web、Worker、DB、Redis 等） |
| 3 | 同时启动 | 依次启动 n8n 和 Dify |
| 4 | 查看状态 | 显示所有 Compose 服务的运行状态 |
| 5 | 停止 n8n | 安全停止 n8n（保留数据） |
| 6 | 停止 Dify | 安全停止 Dify（保留数据） |
| 7 | 停止全部 | 安全停止所有平台 |
| 8 | 打开 n8n 网页 | 在浏览器中打开 http://127.0.0.1:5678 |
| 9 | 打开 Dify 网页 | 在浏览器中打开 http://localhost |
| 0 | 退出 | 关闭启动器 |

## 平台访问地址

| 平台 | 地址 |
|------|------|
| n8n | http://127.0.0.1:5678 |
| Dify | http://localhost |

## 启动器行为

- **Docker 检查**：每次启动平台前自动检测 Docker Engine 是否可用。不可用时自动启动 Docker Desktop 并等待就绪。
- **端口检查**：启动前检查相关端口是否被占用。占用时显示进程名和 PID，不会强制关闭。
- **去重检查**：平台已在运行时不会重复启动。
- **健康检查**：启动后分别检查 n8n 和 Dify 的核心服务健康状态，显示未就绪的服务及最近日志。
- **安全停止**：所有停止操作使用 `docker compose down`，不使用 `-v` 参数，不删除数据卷。
- **日志记录**：所有操作写入 `logs/launcher.log`，包含时间、操作、命令、结果和错误信息。

## 平台目录结构

```
E:\MorenAnzhuangLujing\Huangjingdajian\
├── n8n\                          # n8n 根目录
│   ├── docker-compose.yml        # n8n Compose 配置
│   ├── .env                      # n8n 环境变量
│   ├── start.ps1                 # n8n 独立启动脚本（保留）
│   ├── stop.ps1                  # n8n 独立停止脚本（保留）
│   ├── data/                     # 数据卷（n8n + PostgreSQL）
│   └── files/                    # n8n 文件目录
│
├── Dify\docker\                  # Dify 根目录
│   ├── docker-compose.yaml       # Dify Compose 配置
│   ├── .env                      # Dify 环境变量
│   └── volumes/                  # 数据卷（DB、Redis、Weaviate 等）
│
└── Launcher\                     # 本启动器
    ├── Workflow-Launcher.ps1
    ├── Workflow-Launcher.bat
    ├── logs/
    └── assets/
```

## 常见错误及处理

### Docker Desktop 未启动

**现象**：启动器提示 "Docker Engine 不可用" 并尝试启动 Docker Desktop。

**处理**：启动器会自动启动 Docker Desktop 并等待（最长 120 秒）。如果超时，请手动启动 Docker Desktop 后重试。

### 端口被占用

**现象**：提示 "端口 XX 被其他程序占用"。

**处理**：
1. 启动器会显示占用端口的进程名和 PID。
2. 手动关闭占用端口的程序，或修改对应平台的 `.env` 文件更改端口。
3. 常见冲突：端口 80 可能被 IIS、Apache 等占用。

### PowerShell 执行策略限制

**现象**：提示 "无法加载文件，因为在此系统上禁止运行脚本"。

**处理**：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### n8n 或 Dify 服务未就绪

**现象**：启动后提示某些服务未运行。

**处理**：
1. 启动器会自动显示未就绪服务的最近日志。
2. 根据日志信息排查原因。
3. 常见原因：首次启动需拉取镜像（需联网）、磁盘空间不足、配置文件错误。

### Docker Compose 版本不兼容

**现象**：提示 docker compose 命令错误。

**处理**：确保安装了 Docker Desktop 4.x 及以上版本（内置 Docker Compose v2）。

## 数据安全说明

- **不删除数据**：启动器的所有停止操作使用 `docker compose down`，不会删除 Docker 卷、容器、镜像或业务数据。
- **不修改配置**：启动器不会修改 n8n 或 Dify 的 `docker-compose.yml`、`.env` 等配置文件。
- **数据持久化**：n8n 数据存储在 `n8n/data/`，Dify 数据存储在 `Dify/docker/volumes/`，均在本地磁盘。
- **备份建议**：定期备份 `n8n/data/` 和 `Dify/docker/volumes/` 目录以防数据丢失。

## 相关链接

- n8n 文档：https://docs.n8n.io
- Dify 文档：https://docs.dify.ai
- Docker Desktop：https://www.docker.com/products/docker-desktop

# devdocker

本项目提供一份面向本地开发的 Docker Compose 基础服务模板。

目标是在每次启动新项目时，都可以快速复用一套常见的数据库、缓存、消息队列、对象存储、搜索、监控、网关和开发辅助服务，减少重复搭建本地依赖环境的时间。

## 适用场景

- **本地开发环境**：为业务项目快速启动 MySQL、Redis 等基础依赖。
- **项目初始化模板**：新项目可以直接复制 `docker-compose/docker-compose.yaml` 使用。
- **技术选型验证**：按需开启 PostgreSQL、MongoDB、RabbitMQ、Kafka、MinIO、Elasticsearch 等服务。
- **第三方依赖模拟**：使用 LocalStack、WireMock、MailHog 等服务模拟云服务、外部 API 和邮件发送。

## 快速开始

进入 `docker-compose` 目录后启动：

```bash
docker compose up -d
```

停止服务但保留数据：

```bash
docker compose down
```

停止服务并删除数据卷：

```bash
docker compose down -v
```

查看服务状态：

```bash
docker compose ps
```

查看服务日志：

```bash
docker compose logs -f
```

## 当前默认启用服务

默认启用了最常用的本地开发基础服务：

| 服务 | 地址 | 账号 | 密码 | 说明 |
| --- | --- | --- | --- | --- |
| MySQL 8 | `localhost:3306` | `root` / `dev` | `root123` / `dev123` | 默认数据库 `dev_db` |
| Redis 7 | `localhost:6379` | - | `redis123` | 开启 AOF 持久化，限制内存 256MB |

## 可选服务模板

`docker-compose/docker-compose.yaml` 中已经预置了多类常见开发服务，大部分默认处于注释状态。

需要使用时，取消对应服务块的注释即可。如果服务依赖持久化卷，也要同步打开文件顶部 `volumes` 中对应的数据卷。

### 数据库

| 服务 | 默认端口 | 用途 |
| --- | --- | --- |
| PostgreSQL 16 | `5432` | 关系型数据库，适合复杂查询和 JSON 场景 |
| MariaDB 11 | `3307` | MySQL 兼容数据库，可与 MySQL 二选一 |
| MongoDB 7 | `27017` | 文档型 NoSQL 数据库 |

### 消息队列 / 事件流

| 服务 | 默认端口 | 用途 |
| --- | --- | --- |
| RabbitMQ | `5672` / `15672` | 任务队列，带 Management UI |
| Kafka | `9092` | 高吞吐事件流，本地使用 KRaft 模式 |
| Zookeeper | `2181` | 旧版 Kafka 依赖 |
| NATS | `4222` / `8222` | 轻量消息系统，支持 JetStream |

### 对象存储 / 文件存储

| 服务 | 默认端口 | 用途 |
| --- | --- | --- |
| MinIO | `9000` / `9001` | S3 兼容对象存储 |
| SeaweedFS | `9333` / `8080` / `18888` | 分布式文件存储，兼容 S3 API |

### 搜索引擎

| 服务 | 默认端口 | 用途 |
| --- | --- | --- |
| Elasticsearch | `9200` / `9300` | 全文检索与数据分析 |
| Kibana | `5601` | Elasticsearch 可视化 |
| Meilisearch | `7700` | 轻量全文搜索 |

### 监控与可观测性

| 服务 | 默认端口 | 用途 |
| --- | --- | --- |
| Prometheus | `9090` | 指标采集与存储 |
| Grafana | `3000` | 指标可视化仪表盘 |
| Jaeger | `16686` / `4317` / `4318` | 分布式链路追踪 |
| Zipkin | `9411` | 轻量链路追踪 |

### 网关与代理

| 服务 | 默认端口 | 用途 |
| --- | --- | --- |
| Nginx | `80` / `443` | 反向代理、静态文件、SSL 终止 |
| Traefik | `80` / `8080` | 自动感知 Docker 容器的网关 |
| Kong Gateway | `8000` / `8443` / `8001` | API 网关 |
| Envoy Proxy | `10000` / `9901` | 高性能 L7 代理 |

### 开发工具与辅助服务

| 服务 | 默认端口 | 用途 |
| --- | --- | --- |
| MailHog | `1025` / `8025` | 本地邮件调试 |
| phpMyAdmin | `8088` | MySQL Web 管理界面 |
| RedisInsight | `8001` | Redis Web 管理界面 |
| Keycloak | `8180` | OAuth2 / OIDC 身份认证 |
| Vault | `8200` | 密钥与秘密管理 |
| Consul | `8500` / `8600` | 服务注册发现与配置中心 |
| LocalStack | `4566` | 本地模拟 AWS 服务 |
| WireMock | `9090` | API Mock / Stub |

## 如何按项目复用

推荐在新项目中复制整个 `docker-compose` 目录，作为项目本地开发环境的一部分：

```text
your-project/
├── docker-compose/
│   └── docker-compose.yaml
├── docker/
│   ├── mysql/
│   ├── redis/
│   └── ...
└── README.md
```

使用建议：

- **只启用需要的服务**：默认保留 MySQL 和 Redis，其他服务按项目需求取消注释。
- **同步启用数据卷**：服务使用了命名卷时，需要同时取消顶部 `volumes` 对应项的注释。
- **避免端口冲突**：如果本机已经运行同类服务，修改左侧宿主机端口，例如 `"3307:3306"`。
- **不要用于生产环境**：当前账号、密码和配置都面向本地开发，不适合直接部署生产。
- **按项目维护配置**：如果某个业务项目有特殊初始化 SQL、网关配置或 Mock 数据，建议放在项目自己的 `docker/` 目录中。

## 常用连接信息

### MySQL

```text
Host: localhost
Port: 3306
Database: dev_db
Username: dev
Password: dev123
Root Password: root123
```

### Redis

```text
Host: localhost
Port: 6379
Password: redis123
```

## 目录说明

```text
.
├── README.md
└── docker-compose/
    └── docker-compose.yaml
```

其中 `docker-compose/docker-compose.yaml` 是本地基础服务模板的核心文件。

## 注意事项

- **首次启动会拉取镜像**：需要本机可以访问 Docker 镜像仓库。
- **数据默认持久化**：MySQL、Redis 等服务使用 Docker 命名卷保存数据。
- **删除数据需谨慎**：执行 `docker compose down -v` 会删除已创建的数据卷。
- **安全配置仅限本地**：文件中的默认密码是为了开发便利，提交业务项目时请按需调整。
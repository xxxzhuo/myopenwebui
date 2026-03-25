# Open Web UI 定制版部署报告

_部署时间：2026-03-18 11:40 AM_
_部署地点：macOS (本地)_
_部署方式：Docker Compose + 本地构建前端_

---

## ✅ 部署状态

| 服务 | 状态 | 端口 | 镜像 |
|------|------|------|------|
| **Open Web UI** | ✅ 运行中 | `:3000` | `ghcr.io/open-webui/open-webui:main` |
| **Ollama** | ✅ 运行中 | `:11434` | `ollama/ollama:latest` |

**前端来源：** 本地构建 (`npm run build`)
**前端挂载：** `./build:/app/backend/static:ro`

---

## 🌐 访问地址

**主界面：** http://localhost:3000

---

## 📋 部署配置

### docker-compose.yaml

```yaml
version: '3.8'

services:
  ollama:
    volumes:
      - ollama:/root/.ollama
    container_name: ollama
    image: ollama/ollama:latest
    ports:
      - "11434:11434"
    networks:
      - open-webui-network

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    volumes:
      - open-webui:/app/backend/data
      - ./build:/app/backend/static:ro  # ⭐ 挂载你的前端
    depends_on:
      - ollama
    ports:
      - "3000:8080"
    environment:
      - OLLAMA_BASE_URL=http://ollama:11434
    networks:
      - open-webui-network

networks:
  open-webui-network:
    driver: bridge
```

---

## 🚀 部署流程

### 1. 停止旧服务
```bash
docker-compose down
```

### 2. 本地构建前端
```bash
source .venv311/bin/activate
npm run build
```

构建输出：
- ✅ SvelteKit SSR 构建完成 (1m 27s)
- ✅ 生产构建完成 (2m 34s)
- ✅ 输出目录：`build/`

### 3. 启动 Docker 服务
```bash
docker-compose up -d
```

### 4. 验证部署
```bash
# 检查服务状态
docker-compose ps

# 检查前端挂载
docker exec open-webui ls -la /app/backend/static/

# 健康检查
curl http://localhost:3000/health
```

---

## 📦 前端构建产物

```
build/
├── _app/                    # SvelteKit 应用代码
├── assets/                  # 静态资源
├── audio/                   # 音频文件
├── pyodide/                 # Pyodide (Python in Browser)
├── static/                  # 静态文件
├── themes/                  # 主题文件
├── favicon.png
├── index.html               # 主页面
└── manifest.json
```

---

## 🔄 更新流程

### 更新前端代码后

```bash
# 1. 重新构建前端
npm run build

# 2. 重启容器（自动挂载新构建）
docker-compose restart open-webui

# 3. 验证
curl http://localhost:3000/health
```

### 更新后端配置

```bash
# 1. 修改 docker-compose.yaml

# 2. 重启服务
docker-compose down
docker-compose up -d
```

---

## 📊 资源使用

| 项目 | 大小 |
|------|------|
| Docker 镜像 | 6.6GB |
| 前端构建产物 | ~500MB |
| Ollama 模型 | 按需下载 |

---

## 🐛 故障排查

### 前端未更新

```bash
# 1. 确认构建成功
ls -la build/

# 2. 检查挂载
docker exec open-webui ls -la /app/backend/static/

# 3. 强制重启
docker-compose restart open-webui
```

### 后端连接失败

```bash
# 检查 Ollama 连接
docker exec open-webui curl http://ollama:11434/api/tags

# 查看后端日志
docker-compose logs -f open-webui
```

---

## ✅ 部署完成清单

- [x] 本地前端构建
- [x] Docker 镜像拉取
- [x] 前端挂载配置
- [x] 容器启动
- [x] 健康检查通过
- [x] 前端资源验证

---

## 📝 关键特性

1. **使用官方后端镜像** - 稳定可靠
2. **本地构建前端** - 支持二次开发
3. **卷挂载方式** - 无需重新构建镜像
4. **快速迭代** - 修改前端后只需 `npm run build && docker-compose restart`

---

_部署完成时间：2026-03-18 11:40 AM_
_访问地址：http://localhost:3000_

#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo "Open WebUI 上传文件依赖一键修复脚本"
echo "========================================"

# 1) 定位项目根目录
if [ -d "./backend" ]; then
  PROJECT_ROOT="$(pwd)"
elif [ -d "../backend" ]; then
  PROJECT_ROOT="$(cd .. && pwd)"
else
  echo "未找到 backend 目录。"
  echo "请把脚本放在 open-webui 项目根目录执行，或进入项目目录后再执行。"
  exit 1
fi

BACKEND_DIR="$PROJECT_ROOT/backend"
VENV_DIR="$BACKEND_DIR/venv"

echo "项目目录: $PROJECT_ROOT"
echo "后端目录: $BACKEND_DIR"

# 2) 检查 Python
if ! command -v python3 >/dev/null 2>&1; then
  echo "未检测到 python3，请先安装 Python 3。"
  exit 1
fi

# 3) 创建虚拟环境（如果不存在）
if [ ! -d "$VENV_DIR" ]; then
  echo "未检测到 venv，正在创建虚拟环境..."
  cd "$BACKEND_DIR"
  python3 -m venv venv
else
  echo "检测到已有 venv，跳过创建。"
fi

# 4) 激活虚拟环境
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

echo "当前 Python: $(which python)"
python --version
pip --version

# 5) 升级基础工具
echo "升级 pip / setuptools / wheel ..."
pip install -U pip setuptools wheel

# 6) 安装 Open WebUI 后端基础依赖
if [ -f "$BACKEND_DIR/requirements.txt" ]; then
  echo "安装 backend/requirements.txt ..."
  pip install -r "$BACKEND_DIR/requirements.txt" -U
else
  echo "警告：未找到 $BACKEND_DIR/requirements.txt，跳过基础依赖安装。"
fi

# 7) 安装文件上传解析常用依赖
echo "安装文件解析依赖 ..."
pip install -U \
  "unstructured[all-docs]" \
  msoffcrypto-tool \
  python-docx \
  openpyxl \
  pypdf \
  pymupdf

# 8) 做导入自检
echo "执行依赖导入检查 ..."
python - <<'PY'
modules = [
    "unstructured",
    "msoffcrypto",
    "docx",
    "openpyxl",
    "pypdf",
    "fitz",
]
failed = []

for m in modules:
    try:
        __import__(m)
        print(f"[OK] {m}")
    except Exception as e:
        failed.append((m, str(e)))
        print(f"[FAIL] {m}: {e}")

if failed:
    print("\n以下模块导入失败：")
    for m, e in failed:
        print(f" - {m}: {e}")
    raise SystemExit(1)

print("\n所有关键依赖导入成功。")
PY

echo ""
echo "========================================"
echo "修复完成"
echo "========================================"
echo "下一步请这样启动后端："
echo "cd \"$BACKEND_DIR\""
echo "source venv/bin/activate"
echo "sh dev.sh"
echo ""
echo "如果前端也在本地开发模式运行，请保持前后端都启动后再测试上传。"
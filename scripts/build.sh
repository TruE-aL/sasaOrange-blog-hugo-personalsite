#!/usr/bin/env bash
# 构建站点并生成 Pagefind 搜索索引。
#
# 顺序很重要：Pagefind 索引的是构建后的 HTML，必须跑在 hugo 之后、部署之前。
# 部署时要把整个 public/ 推上去，包括 public/pagefind/。
#
# 用法：
#   ./scripts/build.sh            # 生产构建
#   HUGO_BASEURL=https://x/ ./scripts/build.sh   # 临时换 baseURL
set -euo pipefail

cd "$(dirname "$0")/.."

HUGO="${HUGO_BIN:-hugo}"
PAGEFIND_VERSION="1.4.0"

if [ ! -d themes/ruri ]; then
  echo "✗ themes/ruri 不存在。先运行：git submodule update --init --recursive" >&2
  exit 1
fi

echo "→ hugo $($HUGO version | awk '{print $2}')"
ARGS=(--gc --minify --logLevel info)
if [ -n "${HUGO_BASEURL:-}" ]; then
  ARGS+=(--baseURL "$HUGO_BASEURL")
fi
"$HUGO" "${ARGS[@]}"

echo "→ pagefind ${PAGEFIND_VERSION}"
npx -y "pagefind@${PAGEFIND_VERSION}" --site public --glob '**/*.html'

echo "✓ 构建完成：$(find public -name '*.html' | wc -l | tr -d ' ') 个 HTML，pagefind 索引 $(du -sh public/pagefind 2>/dev/null | cut -f1)"

#!/usr/bin/env bash
# 全 .md の Markdown インラインリンク [text](target) の相対パス実在を検証する。
# 使い方: tools/check-links.sh [dir]   (省略時: カレントディレクトリ)
# 終了コード: 0=全リンク有効 / 1=壊れリンクあり
# スキップ: http(s)リンク、#アンカーのみのリンク。リンク先の #以降 は無視して判定。
# 既知の制限: コードスパン/コードブロック内のリンク記法も検証対象になる。
set -u

ROOT="${1:-.}"
broken=0

while IFS=: read -r file link; do
  if [ -z "${link:-}" ]; then
    echo "BROKEN: $file -> (空リンク)"
    broken=1
    continue
  fi
  case "$link" in
    http://*|https://*|\#*) continue ;;
  esac
  target="${link%%#*}"
  [ -z "$target" ] && continue
  dir=$(dirname "$file")
  if [ ! -e "$dir/$target" ]; then
    echo "BROKEN: $file -> $link"
    broken=1
  fi
done < <(grep -roE '\[[^]]*\]\([^)]*\)' --include='*.md' --exclude-dir='.git' "$ROOT" \
         | sed -E 's/\[[^]]*\]\(([^)]*)\)$/\1/')

if [ $broken -eq 0 ]; then
  echo "ALL LINKS OK"
  exit 0
fi
exit 1

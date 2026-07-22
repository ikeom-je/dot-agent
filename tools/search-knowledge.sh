#!/usr/bin/env bash
# 知見の3層(insights.md / git log の Why / issue・PR)を横断検索する。
# 使い方: tools/search-knowledge.sh <キーワード>
#   gh が無い、または SEARCH_KNOWLEDGE_NO_GH=1 のときは issue/PR 検索をスキップする。
#   キーワードは正規表現ではなくリテラル文字列として扱う(grep -F / git log -F)。
set -u

KEYWORD="${1:-}"

if [ -z "$KEYWORD" ]; then
  echo "Usage: tools/search-knowledge.sh <キーワード>" >&2
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || REPO_ROOT="."
INSIGHTS="$REPO_ROOT/docs/knowledge/insights.md"

echo "=== insights.md ==="
if [ -f "$INSIGHTS" ]; then
  grep -n -i -F -- "$KEYWORD" "$INSIGHTS" || echo "(一致なし)"
else
  echo "(一致なし: insights.md が見つかりません)"
fi
echo

echo "=== git log (Why) ==="
GIT_LOG_OUT=$(git log --all --fixed-strings --grep="$KEYWORD" -i --oneline 2>/dev/null)
if [ -n "$GIT_LOG_OUT" ]; then
  printf '%s\n' "$GIT_LOG_OUT"
else
  echo "(一致なし)"
fi
echo

echo "=== issue/PR ==="
if [ -z "${SEARCH_KNOWLEDGE_NO_GH:-}" ] && command -v gh >/dev/null 2>&1; then
  ISSUE_OUT=$(gh issue list --search "$KEYWORD" --state all 2>/dev/null)
  PR_OUT=$(gh pr list --search "$KEYWORD" --state all 2>/dev/null)
  echo "-- issue --"
  [ -n "$ISSUE_OUT" ] && printf '%s\n' "$ISSUE_OUT" || echo "(一致なし)"
  echo "-- PR --"
  [ -n "$PR_OUT" ] && printf '%s\n' "$PR_OUT" || echo "(一致なし)"
else
  echo "(gh が利用できないためスキップ)"
fi

exit 0

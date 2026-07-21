#!/usr/bin/env bash
# bolt 開始手順(worktree作成・work dir・intent.mdひな形)を1コマンド化する。
# 使い方: tools/new-bolt.sh <topic> [issue番号]
#   issue番号を省略し gh が使え、標準入力が端末なら issue 作成の下書きを表示して
#   番号入力を促す。非対話・gh 無し・NEW_BOLT_NO_GH=1 のいずれかならローカル命名
#   bolt/<topic> にフォールバックする。
#   NEW_BOLT_ISSUE=<番号> で issue番号を非対話に指定できる(テスト・自動化用)。
set -u

TOPIC="${1:-}"
ISSUE="${2:-${NEW_BOLT_ISSUE:-}}"

if [ -z "$TOPIC" ]; then
  echo "Usage: tools/new-bolt.sh <topic> [issue番号]" >&2
  exit 1
fi

case "$TOPIC" in
  *[!A-Za-z0-9-]*)
    echo "エラー: topic は英数字とハイフンのみで指定してください: '$TOPIC'" >&2
    exit 1
    ;;
esac

if [ -z "$ISSUE" ] && [ -z "${NEW_BOLT_NO_GH:-}" ] && [ -t 0 ] && command -v gh >/dev/null 2>&1; then
  echo "--- issue 下書き ---"
  echo "## 課題"
  echo "(この bolt で解きたい課題)"
  echo "## やること"
  echo "(スコープ)"
  echo "## 完了の定義"
  echo "--------------------"
  printf "issue 番号を入力(Enter でスキップしローカル命名): " >&2
  read -r ISSUE
fi

if [ -n "$ISSUE" ]; then
  case "$ISSUE" in
    *[!0-9]*)
      echo "エラー: issue番号は数字で指定してください: '$ISSUE'" >&2
      exit 1
      ;;
  esac
  BRANCH="bolt/${ISSUE}-${TOPIC}"
else
  BRANCH="bolt/${TOPIC}"
fi

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "エラー: git リポジトリ内で実行してください" >&2; exit 1; }

if [ -n "$ISSUE" ]; then
  WORKTREE="${REPO_ROOT}-wt-issue-${ISSUE}"
else
  WORKTREE="${REPO_ROOT}-wt-${TOPIC}"
fi

git worktree add "$WORKTREE" -b "$BRANCH" || { echo "エラー: worktree の作成に失敗しました" >&2; exit 1; }

WORK_DIR="$WORKTREE/docs/work/$TOPIC"
mkdir -p "$WORK_DIR" || { echo "エラー: work ディレクトリの作成に失敗しました: $WORK_DIR" >&2; exit 1; }

{
  echo "# intent: $TOPIC"
  echo
  echo "プロファイル: standard(docs/process/workflows.md から選ぶ)"
  if [ -n "$ISSUE" ]; then
    echo "Issue: #$ISSUE"
  fi
  echo
  echo "- 解きたい課題:(1〜3行。誰が何に困っているか)"
  echo "- この bolt でやること:(スコープ。1トピックに絞る)"
  echo "- やらないこと:"
  echo "- 完了の定義:(何ができたらこの bolt を閉じるか)"
} > "$WORK_DIR/intent.md" || { echo "エラー: intent.md の作成に失敗しました" >&2; exit 1; }

echo "worktree を作成しました: $WORKTREE"
echo "ブランチ: $BRANCH"
echo "次: cd $WORKTREE && \$EDITOR docs/work/$TOPIC/intent.md"

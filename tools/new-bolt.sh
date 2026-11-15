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

# worktree の中から実行しても .worktree を入れ子にしないよう、メインの作業ツリーを基準にする。
# --show-toplevel は実行中の worktree を返し、git-common-dir の親は --separate-git-dir や
# submodule で作業ツリーと一致しないため、worktree 一覧の先頭(メイン)を使う。
WT_LIST=$(git worktree list --porcelain 2>/dev/null) || { echo "エラー: git リポジトリ内で実行してください" >&2; exit 1; }
REPO_ROOT=$(printf '%s\n' "$WT_LIST" | sed -n '1s/^worktree //p')
if printf '%s\n' "$WT_LIST" | sed -n '2,/^$/p' | grep -qx 'bare'; then
  echo "エラー: bare リポジトリには対応していません(作業ツリーのあるリポジトリで実行してください)" >&2
  exit 1
fi
COMMON_DIR=$(cd "$REPO_ROOT" && cd "$(git rev-parse --git-common-dir)" && pwd) || { echo "エラー: git ディレクトリを特定できません" >&2; exit 1; }

# 置き場所はリポジトリ内の .worktree/<ブランチ名から bolt/ を除いたもの>。リポジトリ外に置くと、
# 各 CLI のサンドボックス・権限設定で作業ディレクトリ外への読み書きになるため。
WORKTREE="${REPO_ROOT}/.worktree/${BRANCH#bolt/}"

# .gitignore に無いプロジェクトでも worktree がコミットに混ざらないよう、ローカルの exclude に足す
# (既に行があれば足さない: .gitignore の否定規則で無視されない場合に毎回増えるのを防ぐ)
EXCLUDE="$COMMON_DIR/info/exclude"
if ! git -C "$REPO_ROOT" check-ignore -q .worktree/ && ! grep -qxF '.worktree/' "$EXCLUDE" 2>/dev/null; then
  mkdir -p "$COMMON_DIR/info"
  # 末尾に改行の無い exclude に足すと既存の行と連結されるため、先に改行を補う
  if [ -s "$EXCLUDE" ] && [ -n "$(tail -c 1 "$EXCLUDE")" ]; then
    echo >> "$EXCLUDE"
  fi
  echo ".worktree/" >> "$EXCLUDE"
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

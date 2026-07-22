#!/usr/bin/env bash
# tools/search-knowledge.sh のテスト。フィクスチャの git リポジトリ上で実行し、
# gh は PATH 上のスタブに差し替えて実際の GitHub 通信をしない。
set -u

SCRIPT="$(cd "$(dirname "$0")" && pwd)/search-knowledge.sh"
FAILED=0

assert() {
  local desc="$1" expected="$2" actual="$3" output="$4" substr="${5:-}"
  if [ "$actual" != "$expected" ]; then
    echo "FAIL: $desc (exit: expected=$expected actual=$actual)"; echo "--- output ---"; echo "$output"
    FAILED=1; return
  fi
  if [ -n "$substr" ] && ! printf '%s' "$output" | grep -qF "$substr"; then
    echo "FAIL: $desc (output missing: $substr)"; echo "--- output ---"; echo "$output"
    FAILED=1; return
  fi
  echo "PASS: $desc"
}

make_fixture_repo() {
  local d="$1"
  mkdir -p "$d/docs/knowledge"
  git -C "$d" init -q -b main 2>/dev/null || (mkdir -p "$d" && git -C "$d" init -q -b main)
  cat > "$d/docs/knowledge/insights.md" <<'EOF'
# insights

## モデルの自己申告は過大評価バイアスがある

- 事実: テスト用のダミー知見。
EOF
  git -C "$d" add -A
  git -C "$d" -c user.email=t@t -c user.name=t commit -q -m init
  git -C "$d" -c user.email=t@t -c user.name=t commit -q --allow-empty \
    -m "fix: 過大評価バイアスを補正するため他薦を優先する"
}

# ケース1: insights.md のヒットが表示される
t=$(mktemp -d); make_fixture_repo "$t/repo"
out=$(cd "$t/repo" && SEARCH_KNOWLEDGE_NO_GH=1 "$SCRIPT" "過大評価" 2>&1); code=$?
assert "insights ヒットで exit 0" 0 "$code" "$out" "=== insights.md ==="
assert "insights.md 本文がヒットする" 0 "$code" "$out" "過大評価バイアス"
rm -rf "$t"

# ケース2: git log --grep のヒットが表示される(コミットログのWhy)
t=$(mktemp -d); make_fixture_repo "$t/repo"
out=$(cd "$t/repo" && SEARCH_KNOWLEDGE_NO_GH=1 "$SCRIPT" "過大評価" 2>&1); code=$?
assert "git log (Why) 見出しがある" 0 "$code" "$out" "=== git log (Why) ==="
assert "コミットログのWhyがヒットする" 0 "$code" "$out" "他薦を優先する"
rm -rf "$t"

# ケース3: gh スタブがあれば issue と PR の両方が個別に呼ばれ表示される
t=$(mktemp -d); make_fixture_repo "$t/repo"
mkdir -p "$t/bin"
cat > "$t/bin/gh" <<'EOF'
#!/usr/bin/env bash
case "$1" in
  issue) echo "#99 dummy issue matching keyword" ;;
  pr) echo "#100 dummy PR matching keyword" ;;
esac
EOF
chmod +x "$t/bin/gh"
out=$(cd "$t/repo" && PATH="$t/bin:$PATH" "$SCRIPT" "過大評価" 2>&1); code=$?
assert "issue/PR 見出しがある" 0 "$code" "$out" "=== issue/PR ==="
assert "gh issue list の出力が表示される" 0 "$code" "$out" "dummy issue"
assert "gh pr list の出力が表示される" 0 "$code" "$out" "dummy PR"
rm -rf "$t"

# ケース3b: キーワードに正規表現メタ文字を含んでもリテラル一致で動作する
t=$(mktemp -d); make_fixture_repo "$t/repo"
out=$(cd "$t/repo" && SEARCH_KNOWLEDGE_NO_GH=1 "$SCRIPT" "[" 2>&1); code=$?
assert "メタ文字 '[' を含んでもクラッシュせず exit 0" 0 "$code" "$out"
rm -rf "$t"

# ケース4: gh が無い/NO_GH のときは issue/PR セクションをスキップする旨を表示
t=$(mktemp -d); make_fixture_repo "$t/repo"
out=$(cd "$t/repo" && SEARCH_KNOWLEDGE_NO_GH=1 "$SCRIPT" "過大評価" 2>&1); code=$?
assert "gh 無し時は exit 0" 0 "$code" "$out"
assert "issue/PR セクションのスキップを明示" 0 "$code" "$out" "スキップ"
rm -rf "$t"

# ケース5: キーワード省略は Usage を出して exit 1
t=$(mktemp -d); make_fixture_repo "$t/repo"
out=$(cd "$t/repo" && "$SCRIPT" 2>&1); code=$?
assert "キーワード省略で exit 1" 1 "$code" "$out" "Usage"
rm -rf "$t"

[ $FAILED -eq 0 ] && echo "ALL TESTS PASSED" || { echo "TESTS FAILED"; exit 1; }

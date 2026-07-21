#!/usr/bin/env bash
# tools/new-bolt.sh のテスト。フィクスチャの git リポジトリ上で実行し、
# gh は PATH 上のスタブに差し替えて実際の GitHub 通信をしない。
set -u

SCRIPT="$(cd "$(dirname "$0")" && pwd)/new-bolt.sh"
FAILED=0

assert() { # <desc> <expected_exit> <actual_exit> <output> [expected_substring]
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

make_fixture_repo() { # $1 にフィクスチャの git リポジトリを作る
  local d="$1"
  mkdir -p "$d"
  git -C "$d" init -q -b main
  mkdir -p "$d/docs/work"
  cat > "$d/docs/work/README.md" <<'EOF'
## intent.md ミニテンプレート

```markdown
# intent: <topic>

プロファイル: standard(docs/process/workflows.md から選ぶ)

- 解きたい課題:(1〜3行。誰が何に困っているか)
- この bolt でやること:(スコープ。1トピックに絞る)
- やらないこと:
- 完了の定義:(何ができたらこの bolt を閉じるか)
```
EOF
  git -C "$d" add -A
  git -C "$d" -c user.email=t@t -c user.name=t commit -q -m init
}

# ケース1: issue番号ありでブランチ・worktree・intent.mdが作られる
t=$(mktemp -d); make_fixture_repo "$t/repo"
out=$(cd "$t/repo" && "$SCRIPT" my-topic 42 2>&1); code=$?
assert "issue番号ありで exit 0" 0 "$code" "$out"
assert "ブランチ名に issue番号を含む" 0 "$code" "$out" "bolt/42-my-topic"
[ -f "$t/repo-wt-issue-42/docs/work/my-topic/intent.md" ] && echo "PASS: intent.md 生成" || { echo "FAIL: intent.md 未生成"; FAILED=1; }
grep -q "Issue: #42" "$t/repo-wt-issue-42/docs/work/my-topic/intent.md" 2>/dev/null && echo "PASS: intent.md に Issue 番号記載" || { echo "FAIL: Issue 番号未記載"; FAILED=1; }
rm -rf "$t"

# ケース2: gh の無い環境(NEW_BOLT_NO_GH でシミュレート)ではローカル命名にフォールバックする
t=$(mktemp -d); make_fixture_repo "$t/repo"
out=$(cd "$t/repo" && NEW_BOLT_NO_GH=1 "$SCRIPT" local-topic 2>&1); code=$?
assert "gh 無し・issue番号無しで exit 0" 0 "$code" "$out"
assert "ブランチ名は日付・issue番号なし" 0 "$code" "$out" "bolt/local-topic"
[ -f "$t/repo-wt-local-topic/docs/work/local-topic/intent.md" ] && echo "PASS: フォールバック時も intent.md 生成" || { echo "FAIL: フォールバック時に intent.md 未生成"; FAILED=1; }
rm -rf "$t"

# ケース3: topic 省略は Usage を出して exit 1
t=$(mktemp -d); make_fixture_repo "$t/repo"
out=$(cd "$t/repo" && "$SCRIPT" 2>&1); code=$?
assert "topic 省略で exit 1" 1 "$code" "$out" "Usage"
rm -rf "$t"

# ケース4: topic に不正文字(空白・スラッシュ)は exit 1
t=$(mktemp -d); make_fixture_repo "$t/repo"
out=$(cd "$t/repo" && "$SCRIPT" "foo/bar" 2>&1); code=$?
assert "topic にスラッシュを含むと exit 1" 1 "$code" "$out"
out=$(cd "$t/repo" && "$SCRIPT" "foo bar" 2>&1); code=$?
assert "topic に空白を含むと exit 1" 1 "$code" "$out"
rm -rf "$t"

# ケース5: issue番号が数字以外は exit 1
t=$(mktemp -d); make_fixture_repo "$t/repo"
out=$(cd "$t/repo" && "$SCRIPT" my-topic abc 2>&1); code=$?
assert "issue番号が数字以外だと exit 1" 1 "$code" "$out"
rm -rf "$t"

# ケース6: gh がある(スタブ)が非対話環境(stdin が tty でない)では
# プロンプトでハングせずローカル命名にフォールバックする
t=$(mktemp -d); make_fixture_repo "$t/repo"
mkdir -p "$t/bin"
cat > "$t/bin/gh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$t/bin/gh"
out=$(cd "$t/repo" && PATH="$t/bin:$PATH" "$SCRIPT" noninteractive-topic < /dev/null 2>&1); code=$?
assert "gh ありでも非tty なら exit 0 でフォールバック" 0 "$code" "$out" "bolt/noninteractive-topic"
rm -rf "$t"

[ $FAILED -eq 0 ] && echo "ALL TESTS PASSED" || { echo "TESTS FAILED"; exit 1; }

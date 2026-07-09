#!/usr/bin/env bash
# tools/check-links.sh のテスト。フィクスチャを一時ディレクトリに生成して検証する。
set -u

SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-links.sh"
FAILED=0

assert() { # <desc> <expected_exit> <actual_exit> <output> [expected_substring]
  local desc="$1" expected="$2" actual="$3" output="$4" substr="${5:-}"
  if [ "$actual" != "$expected" ]; then
    echo "FAIL: $desc (exit: expected=$expected actual=$actual)"; FAILED=1; return
  fi
  if [ -n "$substr" ] && ! printf '%s' "$output" | grep -qF "$substr"; then
    echo "FAIL: $desc (output missing: $substr)"; echo "--- output ---"; echo "$output"; FAILED=1; return
  fi
  echo "PASS: $desc"
}

make_fixture() { # 共通フィクスチャを $1 に生成
  local d="$1"
  mkdir -p "$d/sub"
  echo "target" > "$d/sub/target.md"
  cat > "$d/ok.md" <<'EOF'
[valid file](sub/target.md)
[valid dir](sub/)
[anchor in valid file](sub/target.md#section)
[external](https://example.com/page)
[external http](http://example.com)
[pure anchor](#local-heading)
EOF
}

# ケース1: 有効リンクのみ → exit 0, ALL LINKS OK
t=$(mktemp -d); make_fixture "$t"
out=$("$SCRIPT" "$t" 2>&1); code=$?
assert "有効リンクのみで exit 0" 0 "$code" "$out" "ALL LINKS OK"
rm -rf "$t"

# ケース2: 壊れリンク → exit 1, BROKEN 行
t=$(mktemp -d); make_fixture "$t"
echo "[broken](no/such/file.md)" > "$t/bad.md"
out=$("$SCRIPT" "$t" 2>&1); code=$?
assert "壊れリンクで exit 1" 1 "$code" "$out" "BROKEN:"
assert "壊れリンクのファイルとリンク先を報告" 1 "$code" "$out" "no/such/file.md"
rm -rf "$t"

# ケース3: 壊れていても http/アンカーはスキップされ、それ自体は報告されない
t=$(mktemp -d); make_fixture "$t"
out=$("$SCRIPT" "$t" 2>&1); code=$?
if printf '%s' "$out" | grep -q "example.com\|#local-heading"; then
  echo "FAIL: http/アンカーがスキップされていない"; FAILED=1
else
  echo "PASS: http/アンカーをスキップ"
fi
rm -rf "$t"

# ケース4: .git/ 配下は対象外
t=$(mktemp -d); make_fixture "$t"
mkdir -p "$t/.git"
echo "[broken in git](nope.md)" > "$t/.git/x.md"
out=$("$SCRIPT" "$t" 2>&1); code=$?
assert ".git配下の壊れリンクは無視" 0 "$code" "$out" "ALL LINKS OK"
rm -rf "$t"

# ケース5: 空リンク () は壊れリンクとして報告される
t=$(mktemp -d); make_fixture "$t"
echo "[todo]()" > "$t/empty.md"
out=$("$SCRIPT" "$t" 2>&1); code=$?
assert "空リンクは BROKEN" 1 "$code" "$out" "BROKEN:"
rm -rf "$t"

# ケース6: 画像リンクも検証される(実在はOK・欠落はBROKEN)
t=$(mktemp -d); make_fixture "$t"
mkdir -p "$t/assets"; echo x > "$t/assets/logo.png"
printf '![ok](assets/logo.png)\n' > "$t/img-ok.md"
out=$("$SCRIPT" "$t" 2>&1); code=$?
assert "実在する画像リンクは OK" 0 "$code" "$out" "ALL LINKS OK"
printf '![missing](assets/nope.png)\n' > "$t/img-bad.md"
out=$("$SCRIPT" "$t" 2>&1); code=$?
assert "欠落した画像リンクは BROKEN" 1 "$code" "$out" "assets/nope.png"
rm -rf "$t"

# ケース7: サブディレクトリのファイル基準で解決される
t=$(mktemp -d); make_fixture "$t"
echo "[up](../ok.md)" > "$t/sub/rel.md"
out=$("$SCRIPT" "$t" 2>&1); code=$?
assert "ファイル基準の相対解決" 0 "$code" "$out" "ALL LINKS OK"
rm -rf "$t"

[ $FAILED -eq 0 ] && echo "ALL TESTS PASSED" || { echo "TESTS FAILED"; exit 1; }

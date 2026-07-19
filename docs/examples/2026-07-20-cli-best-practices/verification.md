# verification: cli-best-practices

- 実行した検証コマンドと結果:
  - `./tools/check-links.sh` → ALL LINKS OK / `./tools/test-check-links.sh` → PASS
  - 出典の取得(WebFetch、2026-07-20):
    - Claude Code BP(code.claude.com/docs/ja/best-practices)→ 取得成功
    - GPT-5.5 ガイド(developers.openai.com)→ 取得成功
    - Antigravity BP(antigravity.google/docs/cli/best-practices)→ 本文取得不可
      (別パスも1回試行し不可)。推測で書かず、実測知見+改訂bolt起票の指示として構成
- レビュー往復の記録(2往復で収束、`max_review_rounds`=2 以内):
  - レビュアー: Codex(read-only)。1往復目: major 1・minor 1 → 全採用:
    1. mvp-sprint「計画を省略」が lifecycle のフェーズ規定と矛盾して読める →
       「plan.md の最小化(フェーズは飛ばさない)」に修正
    2. design-first の推奨値が自動適用の規定に読める → 適用手段(表の書き換え/intent明記)を
       明示
  - 2往復目: 「収束」。棄却した指摘: なし
- エスカレーション/未解決事項: Antigravity 公式BPが閲覧可能になったら該当節を改訂する
  bolt を起票する(doc 内に明記済み)
- merge: squash merge to main

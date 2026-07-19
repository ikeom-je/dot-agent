# verification: release-process

- 実行した検証コマンドと結果:
  - `./tools/check-links.sh` → ALL LINKS OK / `./tools/test-check-links.sh` → PASS
  - lean-canvas の参照元が prfaq スキルに存在することを grep で確認(孤立解消)
  - release.md への参照が lifecycle / git / AGENTS.md / README にあることを確認
- レビュー往復の記録(2往復で収束、`max_review_rounds`=2 以内):
  - レビュアー: Codex(編成表の第一候補。read-only)
  - 1往復目: major 2・minor 1 → 全採用:
    1. リリース判定が上流boltの収束形式(引き継ぎメモ)と矛盾 → 併記で解消
    2. リリース実行の主体が2通りに読める → 「GO判断=人間(委譲不可)・GO前の実行禁止・
       GO後の作業は指示があればエージェント可」に一意化
    3. 初回リリース(前回タグ無し)の範囲が未定義 → 全履歴を対象と明記
  - 2往復目: 「収束」。棄却した指摘: なし
- エスカレーション/未解決事項: なし
- merge: squash merge to main

# verification: skill-install

- 実行した検証コマンドと結果:
  - `./tools/check-links.sh` → ALL LINKS OK / `./tools/test-check-links.sh` → PASS
  - 外部リポジトリ2件の実在・内容を WebFetch で確認(2026-07-20):
    - sickn33/antigravity-awesome-skills: 1,965+ スキルのカタログ。CATALOG.md /
      skills_index.json、Claude Code / Codex CLI / Gemini CLI / Antigravity 等 10+ ツール対応
    - cisco-ai-defense/skill-scanner: Cisco AI Defense 製。プロンプトインジェクション・
      データ流出・悪意あるコード等を検出。pip/uv 導入、`skill-scanner scan` 実行。
      README 自身が「検出なし≠安全」と明記(スキルの目視必須の根拠に採用)
- レビュー往復の記録(2往復で収束、`max_review_rounds`=2 以内):
  - レビュアー: Codex(read-only)。1往復目: major 1・minor 1 → 全採用:
    1. 検査済みツリーと導入物の同一性が未保証 → コミット固定+検査済みディレクトリ
       そのものを導入・変更時は再検査、を明記
    2. 目視対象が本文限定と読める → 導入される全ファイルに拡大
  - 2往復目: 「収束」。棄却した指摘: なし
- エスカレーション/未解決事項: なし
- merge: squash merge to main

# verification: generic-template

- 実行した検証コマンドと結果:
  - 案件固有語の残存 grep(docs/examples・docs/superpowers・この bolt の intent を除外)→ なし
  - `./tools/check-links.sh` → ALL LINKS OK / `./tools/test-check-links.sh` → PASS
- 監査結果(bolt 前の状態):
  1. docs/work/ に試行案件2件+フレームワーク開発記録6件が混在、README に案件例 → 是正
  2. .gitignore 不在 → 追加(秘密情報・OS/エディタ・生成物・ハーネス一時ファイル)
  3. 秘密情報の取り扱い禁止が .claude/settings.json の deny のみ → AGENTS.md 共通禁止事項+
     GEMINI.md・.codex/config.toml に注記を追加(3エージェント全てに効く場所へ)
  4. ユースケース別ワークフロー未定義 → workflows.md 新設(standard/design-first/
     mvp-sprint/pitch-deck)+ pitch-deck テンプレート+ bolt スキル/README/AGENTS.md 接続
- レビュー往復の記録(2往復で収束、`max_review_rounds`=2 以内):
  - レビュアー: Codex(read-only)。1往復目: major 3・minor 2 → 全採用:
    1. standard 選択時の記録が無く区別不能 → standard 含め intent.md に記録
    2. プロファイル優先規定が「単一定義箇所」の原則と矛盾 → 例外規定を AGENTS.md 側に
       置き workflows.md は参照のみ(原則の規定元を一元化)
    3. design-first「全フェーズ必須」が lifecycle 省略ルールと衝突 → 省略ルール適用可+
       設計フェーズ厚めの趣旨に修正
    4. .gemini 側への注記漏れ(intent スコープ未達)→ GEMINI.md に追加
    5. 完了条件の grep がこの intent 自身に自己言及で失敗 → 除外を明記
  - 2往復目: 「収束」。棄却した指摘: なし
- エスカレーション/未解決事項: なし
- merge: squash merge to main

# verification: context-diet

- 実行した検証コマンドと結果:
  - `./tools/check-links.sh` → ALL LINKS OK / `./tools/test-check-links.sh` → PASS
  - 圧縮結果: AGENTS.md 148→97行 / bolt スキル 62→49行(lifecycle との重複表を削除)/
    上流4スキルのレビューゲート定型段落を条件付き1行に統一
  - **3モデル読解チェック合格**: AGENTS.md のみを読ませて規定5問
    (max_fix_loops・指揮者の責務・調査の担当と代替・コミットログ・外部スキル導入条件)
    に Codex / Gemini(agy flash)とも全問正答。Claude(指揮者)も同様
- レビュー往復の記録(2往復で収束、`max_review_rounds`=2 以内):
  - レビュアー: Codex(read-only)。1往復目: major 3・minor 1 —
    **圧縮しすぎによる規定の欠落を4件検出** → 全採用して復元:
    1. 4スキルの `review_gate_phases` 条件が消え相互レビューが無条件化していた
    2. 編成表の「変更の目安」列(担当変更時の判断軸)が消えていた
    3. 禁止事項から「エージェント定義」と「skill-scanner」が縮退していた
    4. bolt単位調整の「プロファイルに従う」条件が消え任意上書きに読めた
  - 2往復目: 「収束」。棄却した指摘: なし
- エスカレーション/未解決事項: なし
- merge: squash merge to main(merge 後、本記録を docs/examples/ へ移動)

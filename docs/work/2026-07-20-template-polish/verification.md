# verification: template-polish

- 実行した検証コマンドと結果:
  - `./tools/check-links.sh` → ALL LINKS OK(bolt記録8件の examples 移動後も切れなし)
  - `./tools/test-check-links.sh` → PASS
  - docs/work/ がこの bolt のみであることを確認
- 反映したギャップ(3モデルレビューの統合 P1+P2+⑨):
  LICENSE(MIT)/ README 前提ツール節(委譲先なしの開始導線)/ 範囲表現を「リリースまで」に
  統一 / check-links 制限の明記 / bolt 記録の examples 移動+運用ルール化 /
  bolt チェックリストの上流 bolt 矛盾解消 / intent テンプレートにプロファイル欄 /
  `review_gate_phases` のフェーズ番号厳密化
- レビュー往復の記録(2往復で収束、`max_review_rounds`=2 以内):
  - レビュアー: Codex(read-only)。1往復目: major 2 → 全採用:
    1. `review_gate_phases` にフェーズ9(レビュー実施)を含めると再帰的 → 対象を
       「成果物を生むフェーズ 1〜8」に修正
    2. 委譲先なし時の「レビューは指揮者が自分で」が別モデル原則と矛盾 →
       cross-reviewer subagent+同モデル記録(review.md フォールバック)に接続
  - 2往復目: 「収束」。棄却した指摘: なし
- エスカレーション/未解決事項: なし(P3 の bolt初期化スクリプト・release実証・リモート化は
  将来 bolt の候補として残る)
- merge: squash merge to main(merge 後、本記録を docs/examples/ へ移動)

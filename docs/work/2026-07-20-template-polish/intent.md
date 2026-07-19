# intent: template-polish

プロファイル: standard

- 解きたい課題: 3モデルレビュー(Claude/Codex/Gemini、いずれも「条件付き十分」)で挙がった
  配布前の欠け — 初導入の導線断絶・自身のbolt記録の混入・LICENSE欠落・規定の矛盾/曖昧さ。
- この bolt でやること(統合ギャップ P1+P2+⑨):
  1. README: 前提ツール節を追加(必須は1CLIのみ。委譲先未導入時は編成表の代替+汎用経路で
     開始できることを明記)、冒頭の対象範囲を「リリースまで」に統一、check-links の
     既知の制限を明記
  2. docs/work/ の自身のbolt記録8件を docs/examples/ へ移動し、
     「このリポジトリ自身のboltは merge 後 examples へ移す」運用をプロジェクト固有欄に明記
  3. LICENSE(MIT)を追加
  4. bolt スキルの完了チェックリストに上流boltの収束形式(引き継ぎメモ)を反映(矛盾解消)
  5. intent.md ミニテンプレートに「プロファイル:」欄を追加
  6. `review_gate_phases` の値を lifecycle のフェーズ番号で厳密化
- やらないこと: bolt初期化スクリプト(new-bolt.sh)、CHANGELOG/SECURITY等の追加同梱物、
  未実走要素(release等)の実証、GitHubリモート化。
- 完了の定義: 上記6点が反映され、docs/work がこの bolt のみ、正式グリーン判定グリーン、
  相互レビュー収束、merge 済み(merge 後にこの bolt の記録も examples へ)。

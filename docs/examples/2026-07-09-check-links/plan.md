# plan: check-links

## 設計方針

- 単一の bash スクリプト。`grep -roE` でインラインリンクを抽出し、ファイル基準で解決。
- 対抗案「Node/Python 製リンカー導入」は依存が増えるため不採用(テンプレートの
  汎用性を優先。spec 要件7)。
- テストは一時ディレクトリにフィクスチャを生成して実行結果と終了コードを検証する
  自己完結スクリプト(テストフレームワーク依存なし)。

## タスク分解

- [x] Task 1: `tools/test-check-links.sh` を書く(正常系/壊れリンク/httpスキップ/
      アンカースキップ/ディレクトリリンクの5ケース)→ 実行して失敗を確認(RED)
- [x] Task 2: `tools/check-links.sh` を実装 → テストがグリーン(GREEN)
- [x] Task 3: リポジトリ本体に対して実行し 0 終了を確認。AGENTS.md のプロジェクト固有欄に
      テストコマンドを登録
- [x] Task 4: 相互レビュー(Codex)→ 採否反映 → verification.md → merge

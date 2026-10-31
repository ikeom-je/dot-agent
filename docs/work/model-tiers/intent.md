# intent: model-tiers

プロファイル: standard(docs/process/workflows.md から選ぶ)
Issue: #15
規模: 標準
省略: 技術的な内部改善のためフェーズ2〜5(PRFAQ〜UX設計)を省略し spec から始める

- 解きたい課題: 計画・複雑実装・軽量修正でどのモデル(と effort)を使うかがテンプレートに
  無く、委譲先ごとの優先順位表しかない。deepseek-harness(dsh)からの使い方も未定義。
- この bolt でやること: AGENTS.md に「規模(標準/軽量修正)×役割」のモデル割り当て表を
  単一定義箇所として置き、CLAUDE.md / GEMINI.md / cli-routing / review 系 / CLI 設定を
  その表の参照に揃える。dsh を汎用経路の呼び出し先に加える。
- やらないこと: dsh への担当領域の割り当て(編成変更手順の対象。roster-review で別 bolt)/
  Claude Code settings.json でのモデル既定化 / 実機での各モデル識別子の検証
- 完了の定義: モデル名・effort が AGENTS.md の表にだけ書かれ、他 doc は表を参照している。
  `./tools/check-links.sh && ./tools/test-check-links.sh` がグリーン。クロスレビュー収束。

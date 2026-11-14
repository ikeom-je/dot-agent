# intent: antigravity-model-priority

プロファイル: standard
Issue: #23

- 解きたい課題: AGENTS.md「モデル優先順位」の Antigravity 行が旧世代モデル
  (gemini-3-pro / 3.x flash)のまま。委譲時に第一候補として指定するモデルが
  `agy models` で現在利用できるものと合っていない。
- この bolt でやること: Antigravity の優先順位を
  `gemini-4-hydrogen-high` → `gemini-4-argon-high` → `gemini-3.8-flash-high` に更新する
  (順序は人間の指示。ID は 2026-11-14 時点の `agy models` 出力の表記)。
- やらないこと: Codex 行の変更。cli-routing など参照側の書き換え(表を参照しているだけで、
  定義はここにしかないため不要)。
- 完了の定義: AGENTS.md の表が更新され、正式グリーン判定
  (`./tools/check-links.sh && ./tools/test-check-links.sh`)が通る。
- フェーズ省略: 内部設定値1行の変更なので 2〜5 は省略する。要件・計画はこの intent に
  含まれる範囲で完結している。

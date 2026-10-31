# spec: model-tiers

## スコープ / 非スコープ

スコープ: AGENTS.md / CLAUDE.md / GEMINI.md / cli-routing / review.md / cross-review /
lifecycle.md / .codex/config.toml / README.md / docs/knowledge/insights.md(反映先の追記のみ)。非スコープは intent.md の「やらないこと」。

## 要件

1. AGENTS.md の「モデル優先順位」を「モデル割り当て(★単一の定義箇所)」に置き換え、
   規模2区分(標準/軽量修正)× 役割のモデルと effort を定義する。値は kimeruyaru・medo の
   実運用(2026-10-25 時点)に揃える(軽量修正の実装は `gpt-6-luna`(medium))。
   役割は「計画・指揮・最終判断」「実装・テスト設計」「Codex 作 diff のテスト・レビュー」
   「指揮者作の生成物のレビュー」「上記以外の委譲」の5行で、委譲する全領域を表から引ける。
2. 軽量修正の条件(差分の目安・触れてはいけない領域)と、判定を intent.md に1行書くことを定める。
   軽量修正では spec/plan を intent.md の数行で兼ねてよいと lifecycle.md に定める。
3. 非対応エラー時の次点モデルを残す(従来の優先順位表の機能を失わない)。
4. 編成表・損益分岐と矛盾しない: 軽量修正は軽量モデルに委譲し、一行修正・typo 等の
   極小タスクだけ指揮者が直接行う。
5. 別モデル原則と矛盾しない: 誰がレビューするかは review.md の作成者別の表、どのモデルかは
   AGENTS.md の表で決める。Codex 作 diff への Codex レビューは別モデルに数えない。
6. dsh を汎用経路(ヘッドレスCLI)表に加え、AGENTS.md を起点に読む旨を書く。
7. 他 doc にモデル名・effort をハードコードしない(.codex/config.toml の既定値は例外として
   表への参照コメントを付ける)。

## 成功基準

- `grep` でモデルIDが AGENTS.md・config.toml・cli-routing の呼び出し例以外に現れない
- `./tools/check-links.sh && ./tools/test-check-links.sh` がグリーン

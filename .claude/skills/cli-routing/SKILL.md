---
name: cli-routing
description: タスクを Claude Code / Codex / Antigravity のどれで実行するか判断するとき、または subagent への委譲を検討するときに使う。委譲の損益分岐と委譲時の必須手順を定める。
---

# cli-routing — 3つのエージェントCLIの使い分け

Claude Code が指揮者(オーケストレーター)、Codex と Antigravity(Gemini)が奏者。
委譲は目的ではなくコスト・品質の最適化手段。**迷ったら自分(Claude)でやる。**

## 判断表

| エージェント | 得意領域 | 使う場面 |
|---|---|---|
| **Claude Code** | オーケストレーション・判断・検証・難所の実装 | 常時。要件の解釈、設計判断、レビューの最終採否、グリーン判定、複雑で判断の多い実装 |
| **Codex** | 仕様が固まった独立実装・セカンドオピニオン | spec/plan が書面化済みの実装単位の委譲(codex-worker subagent)、Claude が書いたコードのクロスレビュー |
| **Antigravity** | バルク生成・移行・Web検索・長文コンテキストの要約 | 損益分岐を超える反復作業(大量scaffold・テスト網羅生成・機械的migration)、live Web検索、長文を読ませてダイジェストだけ受け取る |

## 委譲の損益分岐

委譲には「仕様の書面化+往復+検証」の固定コストがかかる。以下は**委譲しない**:

- 小さいタスク(1〜2ファイルの編集、リネーム、一行修正)— 往復コストの方が高い
- 判断が重いタスク(要件の解釈、設計のトレードオフ、レビューの採否)— 指揮者の仕事
- 自己完結していないタスク(会話の文脈を大量に引き継がないと説明できないもの)

逆に、仕様が明確で反復的・大量なら、細切れに委譲せず**1回の大きな委譲にまとめる**。

## 委譲時の必須3点

1. **仕様を書面で渡す** — 会話履歴の貼り付けではなく、`spec.md` / `plan.md` へのパスと完了条件を渡す。
   リポジトリを直接読ませる(Antigravity なら `--dir` で AGENTS.md を読ませる)。
2. **ダイジェストで受ける** — 生の出力全文をコンテキストに戻さない。変更ファイル一覧+要約を受け、
   確認は diff に対して行う。
3. **検証は Claude が行う** — subagent の自己申告 GREEN を信じない。
   [docs/process/test.md](../../../docs/process/test.md) に従い、クリーン状態で自分で実行して判定する。

## 呼び出し方

- **Codex へ**: `codex-worker` subagent([.claude/agents/codex-worker.md](../../agents/codex-worker.md))を使う。
- **Antigravity へ**: `antigravity:delegate` スキル(または antigravity-delegate subagent)を使う。
  Web調査は `antigravity:research`、クロスレビューは `antigravity:review`。
- **クロスレビュー**: `cross-reviewer` subagent。運用ルールは
  [docs/process/review.md](../../../docs/process/review.md)。

---
name: bolt
description: 新しいトピック(企画・機能・調査)の作業を始めるとき、または進行中の bolt の現在地を確認して次の一手を決めるときに使う。AI-DLC の1サイクルを開始から収束まで導く進行役。
---

# bolt — 1サイクルの進行役

bolt は「1トピックを `bolt_max_size` の範囲で収束させる」作業単位。
全体プロセスは [docs/process/lifecycle.md](../../../docs/process/lifecycle.md) を参照。

## 開始手順

1. **サイズ確認** — トピックが1セッションで収束するサイズか判断する。大きければ分割し、
   最初の1つだけ始める。
2. **プロファイル選択** — 案件の性質(設計重視/MVP速度/スライド共有など)に合わせて
   [docs/process/workflows.md](../../../docs/process/workflows.md) からプロファイルを選び、
   **standard を含めて** intent.md に「プロファイル: <名前>」と1行書く。
3. **ブランチ作成** — `git checkout -b bolt/YYYY-MM-DD-<topic>`
4. **work ディレクトリ作成** — `docs/work/YYYY-MM-DD-<topic>/` を作り、`intent.md` を記入する
   (テンプレート: [docs/work/README.md](../../../docs/work/README.md))。
   intent は3行でもよいが、「やらないこと」と「完了の定義」は必ず書く。

## フェーズ判定と進行

現在地は**成果物の有無**で判定する(詳細は lifecycle.md の「フェーズ判定基準」):

| 無いファイル | いるフェーズ | 使うもの |
|---|---|---|
| intent.md | 企画 | このスキルの開始手順 |
| prfaq.md(上流boltのみ) | PRFAQ | `prfaq` スキル |
| ux-research.md(上流boltのみ) | UX調査 | `ux-research` スキル |
| user-story.md(UXを含むboltのみ) | ユーザーストーリー | `user-story` スキル |
| ux-design.md(UIのあるプロダクトのみ) | UX設計 | `ux-design` スキル |
| spec.md | 要件 | work/README.md の spec テンプレート |
| plan.md | 設計 | [design-doc テンプレート](../../../docs/design/templates/design-doc.md) |
| (planに未完了タスク) | 実装 | [test.md](../../../docs/process/test.md)・`cli-routing` スキル |
| verification.md | 収束 | 下の完了チェックリスト |

上流・UXフェーズの省略可否は [lifecycle.md](../../../docs/process/lifecycle.md) に従い、
省略する場合は intent.md に1行残す。

各フェーズの成果物は「計画→作成→検証→相互レビュー→収束」のミニループ
([docs/process/review.md](../../../docs/process/review.md)、`review_gate_phases` の対象フェーズ)が
収束したら次へ。飛ばさない(実装依頼でも intent と spec を先に書く)。

## 実装フェーズの注意

- 委譲判断は `cli-routing` スキルに従う。
- diff が intent の範囲を超えたら [docs/process/git.md](../../../docs/process/git.md) の分割基準に従う。
- テストループの停止条件は [docs/process/test.md](../../../docs/process/test.md)
  (`max_fix_loops` 回で止まる)。

## 完了チェックリスト(収束)

- [ ] テストグリーンを自分で実行して確認した(subagent の申告ではなく。
      ドキュメントのみの bolt では正式グリーン判定コマンドの実行)
- [ ] クロスモデルレビューが収束した([docs/process/review.md](../../../docs/process/review.md))
- [ ] `verification.md` に検証記録・レビュー採否・未解決事項を書いた
      (実装に入らない上流 bolt は、代わりに intent.md 末尾の引き継ぎメモでよい —
      [lifecycle.md](../../../docs/process/lifecycle.md) の収束規定)
- [ ] squash merge して bolt ブランチを削除した
- [ ] 続きのトピックがあれば新しい bolt の intent として起票した(このboltを膨らませない)

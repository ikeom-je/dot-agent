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
3. **issue 作成** — リモートがある場合、intent の骨子(課題・やること・完了の定義)で
   issue を作る(`gh issue create`)。既存 issue があれば紐付ける。
4. **ブランチ+worktree 作成** —
   `git worktree add ../<repo>-wt-issue-<番号> -b bolt/<issue番号>-<topic>`
   (issue の無いローカル運用は `bolt/<topic>`。日付は使わない —
   [git.md](../../../docs/process/git.md))。
5. **work ディレクトリ作成** — `docs/work/<topic>/` を作り、`intent.md` を記入する
   (テンプレート: [docs/work/README.md](../../../docs/work/README.md)、
   issue があれば `Issue: #<番号>` を1行)。intent は3行でもよいが、「やらないこと」と
   「完了の定義」は必ず書く。

## フェーズ判定と進行

現在地は**成果物の有無**で判定する。判定基準・各フェーズの成果物と使うスキル・
省略ルールは [lifecycle.md](../../../docs/process/lifecycle.md) のフェーズ表に従う
(この skill では重複定義しない)。省略する場合は intent.md に1行残す。

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
- [ ] 検証記録(何をどう確認したか・レビュー採否・未解決事項)を PR 本文に書いた
      (ローカル運用では merge コミット本文)
- [ ] knowledge dump をした([docs/knowledge/](../../../docs/knowledge/README.md)。
      知見が無ければ PR 本文に「なし」と1行)
- [ ] `docs/work/<topic>/` を削除した(恒久成果物は docs/design/ 等へ移してから —
      [git.md](../../../docs/process/git.md) マージ収束ルール)
- [ ] PR を squash merge し(`Closes #<番号>` で issue クローズ)、ブランチと worktree を
      削除した
- [ ] 続きのトピックがあれば新しい issue として起票した(このboltを膨らませない)

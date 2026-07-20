# git.md — issue・ブランチ運用とマージ収束ルール

## issue ベース運用(リモートがある場合)

- **1 bolt = 1 issue**。bolt 開始時に issue を作る(または既存 issue に紐付ける)。
  issue 本文には intent の骨子(課題・やること・完了の定義)を書き、
  intent.md に `Issue: #<番号>` を1行書く。
- issue は人間との合意点・非同期の会話場所として使う。エスカレーション
  (`escalation_to`)も issue コメントで行ってよい。
- リモートの無いローカル運用では issue を省略してよい。その場合もブランチは `bolt/<topic>`
  (日付なし)とし、検証記録は PR の代わりに merge コミット本文に書く。

## ブランチ運用

- **1 bolt = 1 ブランチ**。命名は issue があれば `bolt/<issue番号>-<topic>`、
  無ければ `bolt/<topic>`(work ディレクトリは `docs/work/<topic>/`。日付は使わない)。
- main への直接コミットはしない。bolt 開始時に必ずブランチを切る。
- **worktree を推奨**: `git worktree add ../<repo>-wt-issue-<番号> -b <ブランチ名>` で
  分離した作業ツリーを作る。main を汚さず、並行 bolt の衝突も防げる。
  merge 後に `git worktree remove` で片付ける。
- ブランチは短命に保つ。1セッションで merge まで到達できないなら bolt が大きすぎる。

## コミット規約

- **検証済みの単位でのみコミットする**。「動くか未確認だがとりあえず保存」のコミットはしない
  (途中保存が必要なら `git stash` を使う)。
- メッセージは conventional commits(`feat:` `fix:` `docs:` `refactor:` `test:` `chore:`)。
- **コミットログには Why を書く**(AGENTS.md 表現の原則)。1行目の要約にも可能な限り
  理由を含める(例: `fix: 空リンクを見逃すため正規表現を緩和` — 「何を」だけの
  `fix: 正規表現を変更` にしない)。本文を省略してよいのは、1行目だけで Why が伝わる
  小さな変更のみ。変更内容(What)の列挙は diff が語るので書かない。
- 1コミット = 1つの意味のある変更。テストと実装は同じコミットに含めてよい。

## diff 膨張の分割基準

作業中の diff に **intent.md に書かれていない変更**が混ざったら、その場で止まって分割する:

1. 目的外の変更(ついでのリファクタ、無関係なバグ修正)を発見したら、まず intent.md と照合する。
2. intent の達成に必須でなければ、変更を revert し、新しい bolt の intent.md として起票する。
3. intent の達成に必須なら、intent.md に1行追記してから進める(黙ってスコープを広げない)。

「ついでにやる」は循環最適化の入り口。bolt を小さく保つことが収束の前提条件になる。

## マージ収束ルール(bolt の閉じ方)

以下を順に満たしたときだけ merge する:

1. **グリーン確認**: [test.md](test.md) の手順でオーケストレーター自身がテストを実行し確認済み。
2. **レビュー**: [review.md](review.md) のクロスモデルレビューが収束済み。
3. **検証記録**: 何をどう確認したか・レビュー往復と採否を PR 本文(ローカル運用では
   merge コミット本文)に書く。
4. **knowledge dump**: 揮発しやすい知見があれば [docs/knowledge/](../knowledge/README.md) に
   追記する(無ければ PR 本文に「knowledge dump: なし」と1行)。
5. **work ディレクトリの削除**: `docs/work/<topic>/` は一時作業場であり、merge に含めない。
   intent の骨子は issue に、検証記録は PR にあるので、削除してから merge する
   (spec / plan / design-doc など後から参照する成果物は `docs/design/` 等の恒久位置へ移す)。
6. **merge**: リモートがあれば push して PR を作り(`gh pr create`)、squash merge する。
   PR 本文は issue を `Closes #<番号>` で参照し、merge で issue を自動クローズする。
   ローカル運用では `git merge --squash` でよい。
7. **後始末**: bolt ブランチと worktree を削除する。

merge 後にそのブランチへ戻って作業を続けない。続きがあるなら新しい bolt(新しい issue)を切る。
merge された bolt 群を外(利用者)に出すときは [release.md](release.md) に従う。

# docs/work/ — bolt の一時作業場

1 bolt = 1 ディレクトリ。命名は `<topic>`(日付は使わない。ブランチは
`bolt/<issue番号>-<topic>`)。プロセス全体は [docs/process/lifecycle.md](../process/lifecycle.md)。

**ここは一時作業場であり、bolt を閉じるとき削除して merge する**([git.md](../process/git.md))。
intent の骨子は issue に、検証記録は PR に、知見は [docs/knowledge/](../knowledge/README.md) に、
恒久成果物(design-doc / ADR 等)は docs/design/ 等に残るのが正。

```
docs/work/<topic>/
├── intent.md         # 必須。bolt の目的
├── prfaq.md          # 上流bolt。テンプレート: ../product/templates/prfaq.md
├── ux-research.md    # 上流bolt。テンプレート: ../product/templates/ux-research.md
├── user-story.md     # UXを含むbolt。テンプレート: ../product/templates/user-story.md
├── ux-design.md      # UIのあるプロダクト。テンプレート: ../product/templates/ux-design.md
├── spec.md           # 要件
└── plan.md           # 設計・タスク分解
```

収束の証跡(検証記録)はファイルではなく PR 本文に書く(下のテンプレート)。

## intent.md ミニテンプレート

```markdown
# intent: <topic>

プロファイル: standard(docs/process/workflows.md から選ぶ)

- 解きたい課題:(1〜3行。誰が何に困っているか)
- この bolt でやること:(スコープ。1トピックに絞る)
- やらないこと:
- 完了の定義:(何ができたらこの bolt を閉じるか)
```

## spec.md ミニテンプレート

```markdown
# spec: <topic>

## スコープ / 非スコープ
## 要件(番号付き・検証可能な形で)
## 成功基準
```

## plan.md ミニテンプレート

```markdown
# plan: <topic>

## 設計方針(必要なら design-doc / ADR へのリンク)
## タスク分解(チェックボックス。1タスク=検証してコミットできる単位)
- [ ] Task 1: ...
```

## 検証記録(PR 本文)ミニテンプレート

```markdown
Closes #<issue番号>

## 検証記録
- 実行した検証コマンドと結果:
- レビュー往復の記録(指摘・採否と理由):
- knowledge dump:(insights.md への追記 or「なし」)
- エスカレーション/未解決事項:(あれば)
```

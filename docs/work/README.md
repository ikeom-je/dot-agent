# docs/work/ — bolt 成果物置き場

1 bolt = 1 ディレクトリ。命名は `YYYY-MM-DD-<topic>`(ブランチ名 `bolt/YYYY-MM-DD-<topic>` と揃える)。
プロセス全体は [docs/process/lifecycle.md](../process/lifecycle.md) を参照。

```
docs/work/2026-07-06-example-topic/
├── intent.md         # 必須。bolt の目的
├── prfaq.md          # 上流bolt。テンプレート: ../product/templates/prfaq.md
├── ux-research.md    # 上流bolt。テンプレート: ../product/templates/ux-research.md
├── spec.md           # 要件
├── plan.md           # 設計・タスク分解
└── verification.md   # 収束の証跡
```

## intent.md ミニテンプレート

```markdown
# intent: <topic>

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

## verification.md ミニテンプレート

```markdown
# verification: <topic>

- 実行した検証コマンドと結果:
- レビュー往復の記録(指摘・採否と理由):
- エスカレーション/未解決事項:(あれば)
- merge日時・コミット:
```

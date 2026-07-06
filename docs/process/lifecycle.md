# lifecycle.md — 企画から収束までの全体プロセス

dot-agent のプロセスは、上流(企画)から下流(実装)までを **bolt** という小さな作業単位で回す。
どのフェーズにいても「小さく始めて、成果物を残して、収束条件で止まる」を繰り返す。

## フェーズ一覧

| # | フェーズ | 入力 | 成果物 | 完了条件 | 使うスキル / doc |
|---|---------|------|--------|----------|------------------|
| 1 | 企画(intent) | アイデア・課題意識 | `intent.md` | 解きたい課題と対象ユーザーが1段落で書けている | `bolt` スキル |
| 2 | PRFAQ | intent.md | `prfaq.md` | プレスリリースが顧客言葉で書け、内部FAQで実現性の懸念に答えている | `prfaq` スキル |
| 3 | UX調査 | prfaq.md の仮説 | `ux-research.md` | 主要仮説ごとに支持/棄却/不明の判定とインサイトがある | `ux-research` スキル |
| 4 | 要件(spec) | prfaq / ux-research | `spec.md` | スコープ・非スコープ・成功基準が明記されている | `bolt` スキル |
| 5 | 設計 | spec.md | `plan.md`(+ design-doc / ADR) | 2〜3案の比較と採用理由、タスク分解がある | [design-doc テンプレート](../design/templates/design-doc.md) |
| 6 | 実装 | plan.md | コード + テスト | plan のタスクが完了し、テストがグリーン | [git.md](git.md) / [test.md](test.md) / `cli-routing` スキル |
| 7 | テスト・レビュー | 実装 diff | レビュー指摘と反映 | [review.md](review.md) の収束条件を満たす | [review.md](review.md) |
| 8 | 収束(close) | 全成果物 | `verification.md` + merge | 検証記録が書かれ、ブランチが merge・削除済み | [git.md](git.md) |

**各フェーズの成果物は、完了条件を満たすだけでは完了にならない。**
「計画→作成→検証→相互レビュー→収束」の成果物ミニループ([review.md](review.md))が
収束して初めてフェーズ完了とする。レビュー対象フェーズと往復回数は
[AGENTS.md](../../AGENTS.md) の収束パラメータ(`review_gate_phases` / `max_review_rounds`)に従う。

上流だけの bolt(企画のみ)ではフェーズ 1〜4 で収束してよい。その場合の成果物は
`verification.md` の代わりに「次の bolt への引き継ぎメモ」を intent.md 末尾に書く。

## bolt とは

- **1 bolt = 1 トピック**(企画1件、機能1つ、調査1テーマ)。`bolt_max_size` の範囲で
  完結するサイズに切る。
- 上限内に終わらない見込みなら、bolt を分割する。bolt を大きくしない。
- 各 bolt は `docs/work/YYYY-MM-DD-<topic>/` に成果物を残す:

```
docs/work/2026-07-06-user-onboarding/
├── intent.md         # 目的・課題・対象ユーザー(フェーズ1)
├── prfaq.md          # 上流boltの場合(フェーズ2)
├── ux-research.md    # 上流boltの場合(フェーズ3)
├── spec.md           # 要件(フェーズ4)
├── plan.md           # 設計・タスク分解(フェーズ5)
└── verification.md   # 検証記録・収束の証跡(フェーズ8)
```

ファイルテンプレートは [docs/work/README.md](../work/README.md) を参照。

## フェーズ判定基準

いま bolt がどのフェーズにいるかは、**成果物の有無**で判定する:

1. `intent.md` が無い → フェーズ1(企画)から始める
2. 上流boltで `prfaq.md` が無い → フェーズ2
3. `spec.md` が無い → フェーズ4(要件)
4. `plan.md` が無い → フェーズ5(設計)
5. plan のタスクに未完了がある、またはテスト未グリーン → フェーズ6〜7(実装・レビュー)
6. `verification.md` が無い → フェーズ8(収束)

会話の途中参加やセッション再開時も、この基準で現在地を特定してから作業する。

## 原則

- **フェーズを飛ばさない**: 実装依頼でも intent と spec が無ければ先にそれを書く(数行でよい)。
- **成果物は小さくてよい**: intent.md が3行でも、無いよりはるかに良い。
- **収束条件で止まる**: 各フェーズの完了条件を満たしたら次へ。満たせないループは
  [test.md](test.md) / [review.md](review.md) の停止条件に従いエスカレーションする。

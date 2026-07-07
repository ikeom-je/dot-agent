# lifecycle.md — 企画から収束までの全体プロセス

dot-agent のプロセスは、上流(企画)から下流(実装)までを **bolt** という小さな作業単位で回す。
どのフェーズにいても「小さく始めて、成果物を残して、収束条件で止まる」を繰り返す。

## フェーズ一覧

| # | フェーズ | 入力 | 成果物 | 完了条件 | 使うスキル / doc |
|---|---------|------|--------|----------|------------------|
| 1 | 企画(intent) | アイデア・課題意識 | `intent.md` | 解きたい課題と対象ユーザーが1段落で書けている | `bolt` スキル |
| 2 | PRFAQ | intent.md | `prfaq.md` | プレスリリースが顧客言葉で書け、内部FAQで実現性の懸念に答えている | `prfaq` スキル |
| 3 | UX調査 | prfaq.md の仮説 | `ux-research.md` | 主要仮説ごとに支持/棄却/不明の判定とインサイトがある | `ux-research` スキル |
| 4 | ユーザーストーリー | ux-research.md の判定(UX調査を省略した bolt では prfaq の仮説。ペルソナは仮説と明記) | `user-story.md` | 調査に裏付けられた(または仮説と明記された)ペルソナと、受け入れ条件付きMVPスライスがある | `user-story` スキル |
| 5 | UX設計 | user-story.md | `ux-design.md` | 全MVPストーリーの画面フローと状態(空・エラー)が埋まっている | `ux-design` スキル |
| 6 | 要件(spec) | prfaq / user-story / ux-design | `spec.md` | スコープ・非スコープ・成功基準が明記されている | `bolt` スキル |
| 7 | 設計 | spec.md | `plan.md`(+ design-doc / ADR) | 2〜3案の比較と採用理由、タスク分解がある | [design-doc テンプレート](../design/templates/design-doc.md) |
| 8 | 実装 | plan.md | コード + テスト | plan のタスクが完了し、テストがグリーン | [git.md](git.md) / [test.md](test.md) / `cli-routing` スキル |
| 9 | テスト・レビュー | 実装 diff | レビュー指摘と反映 | [review.md](review.md) の収束条件を満たす | [review.md](review.md) |
| 10 | 収束(close) | 全成果物 | `verification.md` + merge | 検証記録が書かれ、ブランチが merge・削除済み | [git.md](git.md) |

フェーズ 2〜5(PRFAQ〜UX設計)は上流・UXフェーズであり、bolt の性質に応じて省略できる:
UI の無いプロダクト(API・CLI)では UX設計(5)を省略してよい。技術的な内部改善の bolt では
2〜5 を省略して要件(6)から始めてよい。省略の判断は intent.md に1行残す。
UX調査(3)とユーザーストーリー(4)は小さく往復してよい(ストーリー化で新たな不明点が
出たら追加仮説として調査に戻す)。往復は `max_phase_bounce` 回で打ち切り、
不明点は「未調査」と明記して先に進む。

**各フェーズの成果物は、完了条件を満たすだけでは完了にならない。**
「計画→作成→検証→相互レビュー→収束」の成果物ミニループ([review.md](review.md))が
収束して初めてフェーズ完了とする。レビュー対象フェーズと往復回数は
[AGENTS.md](../../AGENTS.md) の収束パラメータ(`review_gate_phases` / `max_review_rounds`)に従う。

実装に入らない bolt(企画・UX・要件 spec.md まで)は、フェーズ 1〜6 の任意の到達点で収束
してよい。その場合の成果物は `verification.md` の代わりに「次の bolt への引き継ぎメモ」を
intent.md 末尾に書く。

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
├── user-story.md     # UXを含むboltの場合(フェーズ4)
├── ux-design.md      # UIのあるプロダクトの場合(フェーズ5)
├── spec.md           # 要件(フェーズ6)
├── plan.md           # 設計・タスク分解(フェーズ7)
└── verification.md   # 検証記録・収束の証跡(フェーズ10)
```

ファイルテンプレートは [docs/work/README.md](../work/README.md) を参照。

## フェーズ判定基準

いま bolt がどのフェーズにいるかは、**成果物の有無**で判定する:

1. `intent.md` が無い → フェーズ1(企画)から始める
2. 上流boltで `prfaq.md` が無い → フェーズ2
3. 上流boltで `ux-research.md` が無い → フェーズ3
4. UXを含むboltで `user-story.md` が無い → フェーズ4
5. UIのあるプロダクトで `ux-design.md` が無い → フェーズ5
6. `spec.md` が無い → フェーズ6(要件)
7. `plan.md` が無い → フェーズ7(設計)
8. plan のタスクに未完了がある、またはテスト未グリーン → フェーズ8〜9(実装・レビュー)
9. `verification.md` が無い → フェーズ10(収束)

(2〜5 は intent.md に省略の記載があれば飛ばす)

会話の途中参加やセッション再開時も、この基準で現在地を特定してから作業する。

## 原則

- **フェーズを飛ばさない**: 実装依頼でも intent と spec が無ければ先にそれを書く(数行でよい)。
- **成果物は小さくてよい**: intent.md が3行でも、無いよりはるかに良い。
- **収束条件で止まる**: 各フェーズの完了条件を満たしたら次へ。満たせないループは
  [test.md](test.md) / [review.md](review.md) の停止条件に従いエスカレーションする。

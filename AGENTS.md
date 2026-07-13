# AGENTS.md — 全エージェント共通コンテキスト(単一ソース)

このファイルが唯一の常時コンテキスト。CLAUDE.md / GEMINI.md はここへの参照+役割宣言のみを持つ。
プロジェクト固有の情報(技術スタック、ビルド/テストコマンド等)は、このファイル末尾の
「プロジェクト固有」セクションに追記する。

## このリポジトリ / フレームワーク

dot-agent は、Claude Code をオーケストレーター、Codex / Antigravity(Gemini)を worker として、
企画(PRFAQ・UX調査)から設計・実装・テストまでを **bolt** という小さなサイクルで回すための
テンプレートフレームワーク。

## 常時前提とする原則

1. **bolt 原則** — 作業は必ず bolt(1トピック・1ブランチ・1 work ディレクトリ)として行う。
   フェーズを飛ばさない。大きければ分割する。
2. **ミニループ原則** — どのフェーズの成果物(intent / PRFAQ / UX調査 / ユーザーストーリー /
   UX設計 / spec / plan / コード)も、
   「計画→作成→検証→相互レビュー→収束」の同じ小ループで作る。ループ回数は下の
   収束パラメータで打ち切り、超えたら記録して人間にエスカレーション。
   グリーン判定はオーケストレーターが自ら実行して行う。
3. **ルーティング** — 委譲は損益分岐で判断する。判断・検証・小タスクは Claude、
   書面化済みの独立実装は Codex、バルク・検索・長文要約は Antigravity。

## 収束パラメータ(★単一の定義箇所)

回数・サイズの数値はここだけで定義する。他の doc・スキルはパラメータ名で参照する。
プロジェクトに合わせて調整するときは、この表の「値」列を直接編集する。
bolt 単位の一時調整は、[workflows.md](docs/process/workflows.md) のプロファイルに従って
intent.md に明記された場合のみ許す(明記があれば、その bolt 内ではそちらを使う)。

| パラメータ | 値 | 意味 | 調整の目安 |
|---|---|---|---|
| `max_fix_loops` | 3 | 同一原因のテスト修正ループの上限([test.md](docs/process/test.md)) | 未知領域・実験的な実装なら 4〜5、枯れた定型実装なら 2 |
| `max_review_rounds` | 2 | 成果物1つあたりの相互レビュー往復の上限。全フェーズ共通([review.md](docs/process/review.md)) | 品質重視(公開API・課金まわり)なら 3、社内ツール・試作なら 1 |
| `review_gate_phases` | all | 相互レビューを必須にするフェーズ。`all` = 全成果物 | 試作フェーズのプロジェクトは `spec以降` や `コードのみ` に緩めてよい |
| `max_phase_bounce` | 2 | 隣接フェーズ間の往復(UX調査↔ユーザーストーリー等)の上限([lifecycle.md](docs/process/lifecycle.md)) | 探索が深いテーマなら 3、定型的な機能追加なら 1 |
| `max_delegation_retries` | 3 | 委譲先1つあたりの合計試行回数の上限(初回を含む。空応答・エラー時)。超えたら代替経路へ([cli-routing](.claude/skills/cli-routing/SKILL.md)) | 委譲先が不安定な環境では 2 に下げて早く切り替える |
| `bolt_max_size` | 1セッション | 1 bolt の上限サイズ。超える見込みなら分割 | 大規模移行など分割不能な作業のみ 2〜3 セッションに緩める |
| `escalation_to` | 人間 | 打ち切り時のエスカレーション先 | チーム運用ではレビュー担当者名・チャンネル名を書く |

### 全エージェント共通の禁止事項

- 検証していない変更をコミットする
- intent.md に書かれていない変更を diff に混ぜる(発見したら分割する)
- テストを弱める修正(skip・アサーション緩和・無断モック化・環境の書き換え)で通す
- 秘密情報(.env・鍵・トークン・顧客データ)を読む・コミットする・成果物や
  委譲プロンプトに貼る(検証で必要な場合も値そのものは伏せる)

## 参照ドキュメント(該当作業時に読む)

| いつ読むか | ドキュメント |
|---|---|
| bolt を開始・再開するとき | [.claude/skills/bolt/SKILL.md](.claude/skills/bolt/SKILL.md) |
| プロセス全体・フェーズ判定を知りたいとき | [docs/process/lifecycle.md](docs/process/lifecycle.md) |
| 案件の性質に合わせてワークフローを選ぶとき | [docs/process/workflows.md](docs/process/workflows.md) |
| 委譲・CLI 使い分けを判断するとき | [.claude/skills/cli-routing/SKILL.md](.claude/skills/cli-routing/SKILL.md) |
| ブランチ・コミット・merge のとき | [docs/process/git.md](docs/process/git.md) |
| テストループを回すとき | [docs/process/test.md](docs/process/test.md) |
| レビューを依頼・実施するとき | [docs/process/review.md](docs/process/review.md)(運用ルール)+ [.claude/skills/cross-review/SKILL.md](.claude/skills/cross-review/SKILL.md)(実行手順) |
| PRFAQ を書くとき | [.claude/skills/prfaq/SKILL.md](.claude/skills/prfaq/SKILL.md) |
| UX 調査をするとき | [.claude/skills/ux-research/SKILL.md](.claude/skills/ux-research/SKILL.md) |
| ユーザーストーリーを書くとき | [.claude/skills/user-story/SKILL.md](.claude/skills/user-story/SKILL.md) |
| UX 設計(画面フロー・情報設計)をするとき | [.claude/skills/ux-design/SKILL.md](.claude/skills/ux-design/SKILL.md) |
| 成果物テンプレートが必要なとき | [docs/work/README.md](docs/work/README.md) / [docs/product/templates/](docs/product/templates/) / [docs/design/templates/](docs/design/templates/) |

## 記述言語

ドキュメント・コミュニケーションは日本語主体。コード識別子・コマンド・技術用語は英語のまま。

## プロジェクト固有

<!-- このテンプレートを導入したプロジェクトで追記する:
- プロダクト概要:
- 技術スタック:
- ビルド: `<command>`
- テスト: `<command>`(グリーン判定に使う正式コマンド)
- lint/format: `<command>`
-->

- ドキュメント検証(このリポジトリの正式グリーン判定):
  `./tools/check-links.sh && ./tools/test-check-links.sh`

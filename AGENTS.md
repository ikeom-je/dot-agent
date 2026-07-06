# AGENTS.md — 全エージェント共通コンテキスト(単一ソース)

このファイルが唯一の常時コンテキスト。CLAUDE.md / GEMINI.md はここへの参照+役割宣言のみを持つ。
プロジェクト固有の情報(技術スタック、ビルド/テストコマンド等)は、このファイル末尾の
「プロジェクト固有」セクションに追記する。

## このリポジトリ / フレームワーク

dot-agent は、Claude Code をオーケストレーター、Codex / Antigravity(Gemini)を worker として、
企画(PRFAQ・UX調査)から設計・実装・テストまでを **bolt** という小さなサイクルで回すための
テンプレートフレームワーク。

## 常時前提とする原則

1. **bolt 原則** — 作業は必ず bolt(1トピック・1ブランチ・1 work ディレクトリ、
   数時間〜1セッションで収束)として行う。フェーズを飛ばさない。大きければ分割する。
2. **収束ルール** — テスト修正ループは最大3回、レビュー往復は最大2回。超えたら記録して
   人間にエスカレーション。グリーン判定はオーケストレーターが自ら実行して行う。
3. **ルーティング** — 委譲は損益分岐で判断する。判断・検証・小タスクは Claude、
   書面化済みの独立実装は Codex、バルク・検索・長文要約は Antigravity。

### 全エージェント共通の禁止事項

- 検証していない変更をコミットする
- intent.md に書かれていない変更を diff に混ぜる(発見したら分割する)
- テストを弱める修正(skip・アサーション緩和・無断モック化・環境の書き換え)で通す

## 参照ドキュメント(該当作業時に読む)

| いつ読むか | ドキュメント |
|---|---|
| bolt を開始・再開するとき | [.claude/skills/bolt/SKILL.md](.claude/skills/bolt/SKILL.md) |
| プロセス全体・フェーズ判定を知りたいとき | [docs/process/lifecycle.md](docs/process/lifecycle.md) |
| 委譲・CLI 使い分けを判断するとき | [.claude/skills/cli-routing/SKILL.md](.claude/skills/cli-routing/SKILL.md) |
| ブランチ・コミット・merge のとき | [docs/process/git.md](docs/process/git.md) |
| テストループを回すとき | [docs/process/test.md](docs/process/test.md) |
| レビューを依頼・実施するとき | [docs/process/review.md](docs/process/review.md) |
| PRFAQ を書くとき | [.claude/skills/prfaq/SKILL.md](.claude/skills/prfaq/SKILL.md) |
| UX 調査をするとき | [.claude/skills/ux-research/SKILL.md](.claude/skills/ux-research/SKILL.md) |
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

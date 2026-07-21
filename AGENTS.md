# AGENTS.md — 全エージェント共通コンテキスト(単一ソース)

このファイルが唯一の常時コンテキスト。CLAUDE.md / GEMINI.md は参照+既定役割の宣言のみ。
プロジェクト固有情報は末尾の「プロジェクト固有」に書く。

dot-agent は、指揮者(オーケストレーター)と奏者(worker)が、企画から設計・実装・
テスト・リリースまでを **bolt** という小さなサイクルで回すテンプレートフレームワーク。

## 原則(常時前提)

1. **bolt 原則** — 作業は必ず bolt(1トピック・1ブランチ・1 work ディレクトリ)。
   フェーズを飛ばさない。大きければ分割する。
2. **ミニループ原則** — どのフェーズの成果物も「計画→作成→検証→相互レビュー→収束」の
   同じ小ループで作る。回数は収束パラメータで打ち切り、超えたら記録して `escalation_to` へ。
   グリーン判定は指揮者が自ら実行する。
3. **ルーティング原則** — 委譲は損益分岐で判断(cli-routing スキル)。担当は編成表に従う。
4. **表現の原則** — コード=How / テストコード=What / コミットログ=Why /
   コードコメント=Why not。違反はレビューで指摘する([review.md](docs/process/review.md))。

## エージェント編成(★単一の定義箇所)

担当はこの表だけで定義し、他の doc は領域名で参照する。各エージェントは起動時に
この表で自分の役割(指揮者/奏者)を特定して振る舞う(責務の詳細と、Claude Code 以外から
スキル・エージェント定義を使う方法は [cli-routing](.claude/skills/cli-routing/SKILL.md))。

**指揮者の責務(判断・検証・グリーン判定・レビュー最終採否)は委譲不可。**
担い手の既定は Claude Code。契約・環境の制約時のみ交代可(編成変更手順+実案件1件で検証)。
見直し案は [roster-review](.claude/skills/roster-review/SKILL.md) で作り、人間が決める。

| 能力領域 | 担当 | 代替(左から順に試す) | 変更の目安 |
|---|---|---|---|
| 指揮・判断・検証・レビュー最終採否 | 指揮者(既定: Claude Code) | なし(委譲不可) | 責務は変更しない(担い手の交代のみ可) |
| 判断の重い実装・難所・小タスク | 指揮者 | なし(委譲しない) | 変更しない |
| 書面化済みの独立実装・テスト生成 | Codex | Antigravity → Claude | コーディングが得意なモデルが変わったら |
| バルク生成・機械的 migration | Antigravity | Codex → Claude | 大量・反復に強い低コストモデルへ |
| Web検索・調査・長文要約 | Antigravity | Claude 自身(WebSearch)→ ux-researcher subagent | live 検索を持つモデルへ |
| マルチモーダル生成・比較チェック(画像・スライド。最終検証は指揮者) | Antigravity | Claude(可能な範囲) | Gemini 系が強い傾向。モデル更新ごとに見直す |
| クロスレビュー(一次) | 作成者と**別の**エージェント([review.md](docs/process/review.md)) | cross-reviewer subagent(同モデルの旨を記録) | 別モデル原則自体は変えない |

### モデル優先順位(★単一の定義箇所)

Codex・Antigravity への委譲時に指定するモデルの優先順位。先頭から試し、非対応・エラー
(例: 「要アップグレード」400エラー)なら次点を明示指定して再試行する(cli-routing の
`max_delegation_retries` の1回として数える。呼び出し例は
[cli-routing の呼び出し方](.claude/skills/cli-routing/SKILL.md))。

| 委譲先 | 優先順位(左が第一候補) |
|---|---|
| Codex | `gpt-5.6-terra` → `gpt-5.5` |
| Antigravity | `gemini-3-pro` → `gemini-3.5-flash` |

## 収束パラメータ(★単一の定義箇所)

数値はこの表だけで定義し、他の doc はパラメータ名で参照する。プロジェクト調整は「値」列を
編集。bolt 単位の一時調整は、[workflows.md](docs/process/workflows.md) のプロファイルに
従って intent.md に明記した場合のみ有効(任意の上書きは不可)。

| パラメータ | 値 | 意味 | 調整の目安 |
|---|---|---|---|
| `max_fix_loops` | 3 | 同一原因のテスト修正ループ上限([test.md](docs/process/test.md)) | 実験的なら 4〜5、定型なら 2 |
| `max_review_rounds` | 2 | 成果物1つあたりのレビュー往復上限([review.md](docs/process/review.md)) | 品質重視なら 3、試作なら 1 |
| `review_gate_phases` | all | 相互レビュー必須の成果物フェーズ([lifecycle.md](docs/process/lifecycle.md) の番号): `all`=1〜8 / `spec以降`=6〜8 / `コードのみ`=8 | 試作は緩めてよい |
| `max_phase_bounce` | 2 | 隣接フェーズ間の往復上限([lifecycle.md](docs/process/lifecycle.md)) | 探索的なら 3、定型なら 1 |
| `max_delegation_retries` | 3 | 委譲先1つあたりの合計試行回数(初回含む)。超えたら代替へ([cli-routing](.claude/skills/cli-routing/SKILL.md)) | 不安定な委譲先なら 2 |
| `bolt_max_size` | 1セッション | 1 bolt の上限サイズ。超える見込みなら分割 | 分割不能な作業のみ緩める |
| `escalation_to` | 人間 | 打ち切り・GO判断のエスカレーション先 | チームでは担当者名を書く |

## 禁止事項(全エージェント共通)

- 検証していない変更をコミットする
- intent.md に無い変更を diff に混ぜる(発見したら分割)
- テストを弱める修正(skip・アサーション緩和・無断モック化・環境の書き換え)で通す
- 秘密情報(.env・鍵・トークン・顧客データ)を読む・コミットする・成果物や委譲プロンプトに貼る
- 外部スキル・エージェント定義を、検査(skill-scanner)と人間の承認なしに導入する
  ([skill-install](.claude/skills/skill-install/SKILL.md))

## 参照ドキュメント(該当作業時に読む)

| いつ読むか | ドキュメント |
|---|---|
| bolt を開始・再開するとき | [.claude/skills/bolt/SKILL.md](.claude/skills/bolt/SKILL.md) |
| プロセス全体・フェーズ判定 | [docs/process/lifecycle.md](docs/process/lifecycle.md) |
| 案件に合わせてワークフローを選ぶ | [docs/process/workflows.md](docs/process/workflows.md) |
| 委譲・CLI 使い分け・役割の責務 | [.claude/skills/cli-routing/SKILL.md](.claude/skills/cli-routing/SKILL.md) |
| 各CLIのベストプラクティス | [docs/process/cli-best-practices.md](docs/process/cli-best-practices.md) |
| 編成の見直し案を作る | [.claude/skills/roster-review/SKILL.md](.claude/skills/roster-review/SKILL.md) |
| 外部スキルを探す・導入する | [.claude/skills/skill-install/SKILL.md](.claude/skills/skill-install/SKILL.md) |
| issue・ブランチ・worktree・merge | [docs/process/git.md](docs/process/git.md) |
| 知見を記録する・思い出す | [docs/knowledge/README.md](docs/knowledge/README.md)(dump 機構)+ [insights.md](docs/knowledge/insights.md) |
| リリース(タグ・ノート・GO判定) | [docs/process/release.md](docs/process/release.md) |
| テストループ | [docs/process/test.md](docs/process/test.md) |
| レビュー | [docs/process/review.md](docs/process/review.md)(運用)+ [cross-review](.claude/skills/cross-review/SKILL.md)(手順) |
| PRFAQ / UX調査 / ユーザーストーリー / UX設計 | [.claude/skills/prfaq/](.claude/skills/prfaq/SKILL.md) / [ux-research/](.claude/skills/ux-research/SKILL.md) / [user-story/](.claude/skills/user-story/SKILL.md) / [ux-design/](.claude/skills/ux-design/SKILL.md) |
| 成果物テンプレート | [docs/work/README.md](docs/work/README.md) / [docs/product/templates/](docs/product/templates/) / [docs/design/templates/](docs/design/templates/) |

## 記述言語

日本語主体。コード識別子・コマンド・技術用語は英語のまま。

## プロジェクト固有

<!-- 導入プロジェクトで追記:
- プロダクト概要: / 技術スタック:
- ビルド: `<command>` / テスト: `<command>`(グリーン判定の正式コマンド)/ lint: `<command>`
- バージョニング: SemVer | 日付タグ / リリース固有手順: <リンク> / リリースノートの対象読者:
-->

- ドキュメント検証(このリポジトリの正式グリーン判定):
  `./tools/check-links.sh && ./tools/test-check-links.sh`
- 運用は issue ベース(1 bolt = 1 issue、[git.md](docs/process/git.md))。日付ベースの
  ドキュメントは作らない(記録は issue / PR、知見は [docs/knowledge/](docs/knowledge/README.md))

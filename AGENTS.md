# AGENTS.md — 全エージェント共通コンテキスト(単一ソース)

このファイルが唯一の常時コンテキスト。CLAUDE.md / GEMINI.md は参照+既定役割の宣言のみ。
プロジェクト固有情報は末尾の「プロジェクト固有」に書く。

dot-agent は、指揮者(オーケストレーター)と奏者(worker)が、企画から設計・実装・
テスト・リリースまでを **bolt** という小さなサイクルで回すテンプレートフレームワーク。
対応CLI: Claude Code / Codex / Antigravity(agy)/ DeepSeek Harness(dsh)。どのCLIも起点は
このファイル(CLI ごとの読み方・呼び出し方は [cli-routing](.claude/skills/cli-routing/SKILL.md))。

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
| 判断の重い実装・難所・極小タスク(一行修正・typo・リネーム) | 指揮者 | なし(委譲しない) | 変更しない |
| 書面化済みの実装・テスト設計(軽量修正を含む) | Codex | Antigravity → Claude | コーディングが得意なモデルが変わったら |
| バルク生成・機械的 migration | Antigravity | Codex → Claude | 大量・反復に強い低コストモデルへ |
| Web検索・調査・長文要約 | Antigravity | Claude 自身(WebSearch)→ ux-researcher subagent | live 検索を持つモデルへ |
| マルチモーダル生成・比較チェック(画像・スライド。最終検証は指揮者) | Antigravity | Claude(可能な範囲) | Gemini 系が強い傾向。モデル更新ごとに見直す |
| テスト・クロスレビュー(一次) | 作成者と**別の**エージェント(規模別の担当は下の「モデル割り当て」。[review.md](docs/process/review.md)) | cross-reviewer subagent(同モデルの旨を記録) | 別モデル原則自体は変えない |

### モデル割り当て(★単一の定義箇所)

作業の重さで「標準」と「軽量修正」を選び、委譲するときは呼び出し側でモデルと effort を
明示する(ユーザー設定の既定値に頼らない — 既定値が変わっても委譲先のモデルがぶれないように)。
規模は指揮者が bolt 開始時に判定し、intent.md に `規模: 標準` / `規模: 軽量修正` と1行書く。
どちらの規模でも**最終レビューと判断は指揮者**が行う。表記は「モデルID(effort)」で、
Antigravity はモデルID自体に effort を含む(`agy models` で一覧)。呼び出し方は
[cli-routing](.claude/skills/cli-routing/SKILL.md)。

| 役割 | 標準(計画・設計・複雑な実装) | 軽量修正 |
|---|---|---|
| 計画・指揮・最終レビューと判断 | Claude `claude-opus-5-5`(medium) | Claude `claude-opus-5-5`(medium) |
| 実装・テスト設計 | Codex `gpt-6.1-sol`(high) | Codex `gpt-6-luna`(medium) |
| テスト・レビュー(Codex 作の diff) | Codex `gpt-6.1-sol`(medium)+ agy `gemini-4-argon-medium` + agy `gemini-3.8-flash-high`。すべて実行する | agy `gemini-3.8-flash-medium` |
| レビュー(指揮者作の生成物) | Codex `gpt-6.1-sol`(medium)+ agy `gemini-4-argon-medium` + agy `gemini-3.8-flash-high` | Codex `gpt-6-luna`(medium)+ agy `gemini-3.8-flash-medium` |
| 上記以外の委譲(バルク生成・マルチモーダル・代替経路。調査は下の箇条書き) | Codex `gpt-6.1-sol`(medium)/ agy `gemini-4-argon-medium` | Codex `gpt-6-luna`(medium)/ agy `gemini-3.8-flash-medium` |

- **軽量修正の条件**(すべて満たすとき): 設計・公開インターフェース・スキーマを変えない /
  差分が目安 50行・3ファイル以下 / 何をするかが issue で決まっている(文言・テストの追加・
  1関数内のバグ修正など。typo・一行修正のような極小タスクは委譲せず指揮者が直接直す)/ 課金・認証・秘密情報に触れない。迷ったら標準にする。実装して条件を
  超えた、またはレビューで重大指摘が出たら標準に戻してやり直す。
- **誰が**レビューするかは [review.md](docs/process/review.md) の作成者別の表で決め、この表は
  そのレビュアーが**どのモデルで**動くかを決める。Codex 作の diff を Codex がレビューしても
  同じモデルなので別モデル原則には数えない(補助の指摘として扱い、独立したレビュアーは
  Gemini と指揮者)。
- 調査(Web検索・長文要約)は規模に関わらず `gemini-3.8-flash-medium` を基本にし、深い調査は
  指揮者の判断で `gemini-4-argon-medium` に上げてよい。
- 使ったモデルと effort は PR 本文の検証記録に書く。
- **非対応・エラー時の次点**(cli-routing の `max_delegation_retries` の1回として数える):
  `gpt-6.1-sol` ⇄ `gpt-6-luna`(effort は維持)/ `gemini-4-argon-*` ⇄ `gemini-3.8-flash-*`
  (同じ effort)。Gemini の quota 切れは agy 経由の `claude-sonnet-5-5-medium` に切り替えて
  続行してよいが、Claude 系なので指揮者作の生成物のレビュアーには数えない(記録に残す)。

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
| 知見を記録する・思い出す | [docs/knowledge/README.md](docs/knowledge/README.md)(dump 機構・3層探索モデル)+ [insights.md](docs/knowledge/insights.md)。検索は `tools/search-knowledge.sh <キーワード>` |
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

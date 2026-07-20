# dot-agent

マルチエージェント開発のテンプレートフレームワーク(MIT License)。
指揮者(既定: Claude Code)と奏者(既定: Codex / Antigravity(Gemini))が、
企画(PRFAQ・UX調査)から設計・実装・テスト・リリースまでを **bolt** という
小さなサイクルで回し続ける。

## 前提ツール

- **必須はエージェントCLIどれか1つ**(既定編成なら Claude Code)。
- 委譲先(Codex の MCP 連携、Antigravity プラグイン等)は**無くても始められる**:
  エージェント編成表(AGENTS.md)の「代替」列に従い、検索は指揮者自身の WebSearch、
  実装は指揮者が自分で行う。レビューは cross-reviewer subagent(別コンテキスト)で行い、
  同モデルレビューになる旨を記録する(review.md のフォールバック規定)。委譲先を後から足すときは
  [cli-routing の呼び出し方](.claude/skills/cli-routing/SKILL.md)(ヘッドレスCLIの
  汎用経路を含む)と [skill-install](.claude/skills/skill-install/SKILL.md)(外部スキルの
  安全な導入)を参照。

## 思想(3行)

1. **小さく回す** — 1トピック=1 bolt=1ブランチ。`bolt_max_size` の範囲で必ず収束させる。
2. **止まり方を決めておく** — 全フェーズの成果物を「計画→作成→検証→相互レビュー→収束」の
   小ループで作り、回数上限([AGENTS.md](AGENTS.md) の収束パラメータで調整可)で打ち切って
   記録し、人間に渡す。
3. **単一ソース** — 常時コンテキストは AGENTS.md だけ。CLI ごとの重複記述を持たない。

## 導入手順

1. このリポジトリを新規プロジェクトにコピー(または clone して `.git` を作り直す)。
2. [AGENTS.md](AGENTS.md) 末尾の「プロジェクト固有」セクションに、プロダクト概要・技術スタック・
   ビルド/テストコマンドを記入する(テストコマンドはグリーン判定の正式コマンドになる)。
   使うモデルの得意領域に合わせて「エージェント編成表」の担当・代替も見直す
   (例: マルチモーダル生成が強いモデルに画像・スライド系の領域を割り当てる)。
3. `.codex/config.toml` のモデル指定など、CLI 設定を環境に合わせて調整する。
4. 案件の性質に合わせて [docs/process/workflows.md](docs/process/workflows.md) から
   ワークフロープロファイル(design-first / mvp-sprint / pitch-deck 等)を選ぶ。
5. [docs/knowledge/insights.md](docs/knowledge/insights.md)(このリポジトリでの運用知見)を
   一読し、不要な項目は削除して自プロジェクトの知見置き場として使う。
6. `claude` を起動し、「◯◯の bolt を始めたい」と伝える(`bolt` スキルが進行を導く)。

## 全体マップ

| パス | 役割 |
|---|---|
| `AGENTS.md` | ★単一ソースの常時コンテキスト(原則・エージェント編成表・収束パラメータ・禁止事項) |
| `CLAUDE.md` | AGENTS.md を import + Claude=オーケストレーター宣言 |
| `GEMINI.md` | AGENTS.md 参照 + Gemini/Antigravity=worker 宣言 |
| `.claude/skills/bolt/` | 1サイクルの進行役(開始→フェーズ判定→収束チェック) |
| `.claude/skills/cli-routing/` | CLI 使い分けの判断表・委譲の損益分岐・失敗時フォールバック |
| `.claude/skills/cross-review/` | クロスモデルレビューの実行手順(依頼の型・往復プロトコル・採否記録) |
| `tools/` | check-links.sh: リンク検証(このリポジトリの正式グリーン判定。既知の制限: コードブロック内のリンク記法も検査対象のため、実在しない例をリンク記法で書かない) |
| `.claude/skills/prfaq/` `.claude/skills/ux-research/` | 上流フェーズのスキル(企画・調査) |
| `.claude/skills/user-story/` `.claude/skills/ux-design/` | UXフェーズのスキル(ストーリー・体験設計) |
| `.claude/agents/` | codex-worker / ux-researcher / cross-reviewer subagent |
| `docs/process/` | lifecycle / git / test / review / release / workflows(ユースケース別プロファイル)のプロセスと収束ルール |
| `docs/product/templates/` | PRFAQ / UX調査 / ユーザーストーリー / UX設計 / Lean Canvas / ピッチ資料 テンプレート |
| `docs/design/templates/` | design-doc / ADR テンプレート |
| `docs/work/` | bolt の一時作業場(1 bolt = 1 ディレクトリ。merge 時に削除) |
| `docs/knowledge/` | 知見の永続化(忘却防止の dump 先。insights.md が正) |
| `.gitignore` | 秘密情報・OS/エディタゴミ・生成物の混入防御 |

## 設定ファイルの方針

- `.claude/settings.json` — 読み取り系と git の日常操作を allow、破壊的操作
  (`rm -rf`、force push、`reset --hard`)と秘密情報の読み取りを deny する安全側の例。
- `.codex/config.toml` — worker 用途のため `workspace-write` サンドボックス+ネットワーク遮断。
  モデルは導入プロジェクトで指定する。
- `.gemini/settings.json` — GEMINI.md をコンテキストとして読み、自動承認は off、
  破壊的コマンドを除外する例。

いずれも「プラクティスの出発点」であり、導入プロジェクトのポリシーに合わせて調整する。

## チュートリアル: 最初の bolt(企画の例)

```
you    > 「<あなたのサービス案>」を企画したい。boltを始めて。
claude > (boltスキル) issue を作成し、worktree でブランチ bolt/<issue番号>-<topic> を
         作成、docs/work/<topic>/intent.md を一緒に記入
claude > (prfaqスキル) 顧客課題→プレスリリース→FAQ の順に prfaq.md を作成
claude > 内部FAQで答えられなかった仮説を ux-research スキルへ。
         Web調査は編成表の担当(既定: Antigravity)に委譲し、出典付きダイジェストで受領
claude > 仮説判定が出たら user-story スキルでペルソナとMVPスライスを作り、
         ux-design スキルで画面フロー・情報設計に落とす
claude > その上で spec.md(要件)へ。実装 bolt は別途分割して起票
claude > 検証記録を PR 本文に書き、知見を docs/knowledge/ に dump、work を片付けて
         squash merge(issue 自動クローズ)→ bolt 収束
```

実装 bolt でも流れは同じで、フェーズ 7〜9(設計→実装→テスト)では
[docs/process/test.md](docs/process/test.md) の収束条件と
[cli-routing](.claude/skills/cli-routing/SKILL.md) の委譲判断が効く。

## このリポジトリ自体の開発

フレームワーク自体の変更も bolt として回す(ドッグフーディング)。経緯は git 履歴と
issue / PR に、運用知見は [docs/knowledge/insights.md](docs/knowledge/insights.md) にある。

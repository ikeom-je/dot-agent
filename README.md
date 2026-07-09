# dot-agent

マルチエージェント開発のテンプレートフレームワーク。
Claude Code を**指揮者**、Codex / Antigravity(Gemini)を**奏者**として、
企画(PRFAQ・UX調査)から設計・実装・テストまでを **bolt** という小さなサイクルで回し続ける。

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
3. `.codex/config.toml` のモデル指定など、CLI 設定を環境に合わせて調整する。
4. `claude` を起動し、「◯◯の bolt を始めたい」と伝える(`bolt` スキルが進行を導く)。

## 全体マップ

| パス | 役割 |
|---|---|
| `AGENTS.md` | ★単一ソースの常時コンテキスト(原則・禁止事項・参照リンク集) |
| `CLAUDE.md` | AGENTS.md を import + Claude=オーケストレーター宣言 |
| `GEMINI.md` | AGENTS.md 参照 + Gemini/Antigravity=worker 宣言 |
| `.claude/skills/bolt/` | 1サイクルの進行役(開始→フェーズ判定→収束チェック) |
| `.claude/skills/cli-routing/` | CLI 使い分けの判断表・委譲の損益分岐・失敗時フォールバック |
| `.claude/skills/cross-review/` | クロスモデルレビューの実行手順(依頼の型・往復プロトコル・採否記録) |
| `tools/` | check-links.sh: リンク検証(このリポジトリの正式グリーン判定) |
| `.claude/skills/prfaq/` `.claude/skills/ux-research/` | 上流フェーズのスキル(企画・調査) |
| `.claude/skills/user-story/` `.claude/skills/ux-design/` | UXフェーズのスキル(ストーリー・体験設計) |
| `.claude/agents/` | codex-worker / ux-researcher / cross-reviewer subagent |
| `docs/process/` | lifecycle / git / test / review のプロセスと収束ルール |
| `docs/product/templates/` | PRFAQ / UX調査 / ユーザーストーリー / UX設計 / Lean Canvas テンプレート |
| `docs/design/templates/` | design-doc / ADR テンプレート |
| `docs/work/` | bolt 成果物置き場(1 bolt = 1 ディレクトリ) |

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
you    > 「個人開発者向けの請求書自動化サービス」を企画したい。boltを始めて。
claude > (boltスキル) ブランチ bolt/2026-07-06-invoice-automation を作成、
         docs/work/2026-07-06-invoice-automation/intent.md を一緒に記入
claude > (prfaqスキル) 顧客課題→プレスリリース→FAQ の順に prfaq.md を作成
claude > 内部FAQで答えられなかった仮説を ux-research スキルへ。
         Web調査は Antigravity に委譲し、出典付きダイジェストで受領
claude > 仮説判定が出たら user-story スキルでペルソナとMVPスライスを作り、
         ux-design スキルで画面フロー・情報設計に落とす
claude > その上で spec.md(要件)へ。実装 bolt は別途分割して起票
claude > verification.md に記録を書き、squash merge してブランチ削除 → bolt 収束
```

実装 bolt でも流れは同じで、フェーズ 7〜9(設計→実装→テスト)では
[docs/process/test.md](docs/process/test.md) の収束条件と
[cli-routing](.claude/skills/cli-routing/SKILL.md) の委譲判断が効く。

## このリポジトリ自体の開発

このフレームワーク自体の設計経緯は
[docs/superpowers/specs/](docs/superpowers/specs/) と
[docs/superpowers/plans/](docs/superpowers/plans/) にある。
フレームワーク自体の変更も bolt として回す(ドッグフーディング)。

# dot-agent スケルトン Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** claude / codex / agy の3 CLIが役割分担して企画〜実装のフルサイクルを小さく回せる、Markdownのみのテンプレートリポジトリを作る。

**Architecture:** `AGENTS.md` を単一ソースとし、`CLAUDE.md`/`GEMINI.md` は薄い参照。プロセスは `docs/process/` の4つのdoc、進行と判断は `.claude/skills/` の4スキル、委譲は `.claude/agents/` の3 subagent定義で担う。実行コードなし(宣言的設定ファイルは可)。

**Tech Stack:** Markdown、Claude Code skills/agents形式、Codex `config.toml`、Gemini `settings.json`。

**Spec:** `docs/superpowers/specs/2026-07-06-dot-agent-framework-design.md`

**検証方法(全タスク共通):** テストの代わりに (a) ファイル内の相対リンク先が実在すること、(b) specの該当要件を満たすことを確認してからコミットする。

**記述言語:** 日本語主体。コード識別子・コマンドは英語。

---

### Task 1: プロセスdoc(docs/process/)

**Files:**
- Create: `docs/process/lifecycle.md`
- Create: `docs/process/git.md`
- Create: `docs/process/test.md`
- Create: `docs/process/review.md`

- [ ] **Step 1: lifecycle.md を書く**

必須内容: フェーズ一覧(企画→PRFAQ→UX調査→要件→設計→実装→テスト→収束)、各フェーズの入力/成果物/完了条件/使うスキルの表、bolt(1トピック=数時間〜1セッション)の定義と `docs/work/YYYY-MM-DD-<topic>/` の構造(intent.md → spec.md → plan.md → 実装 → verification.md)、フェーズ判定基準(成果物の有無で現在地を判定: intentが無ければ企画、specが無ければ要件、planが無ければ設計、テスト未グリーンなら実装中)。

- [ ] **Step 2: git.md を書く**

必須内容: 1 bolt = 1 ブランチ(`bolt/YYYY-MM-DD-<topic>`)、コミットは検証済み単位のみ、diffがintent外に膨らんだら別boltに分割する基準(intent.mdに書かれていない変更が混ざったら)、マージ収束ルール(グリーン確認→レビュー→squash merge→ブランチ削除)、コミットメッセージ規約(conventional commits)。

- [ ] **Step 3: test.md を書く**

必須内容: テストループの手順(実装→実行→失敗分析→修正)、収束条件(修正ループ最大3回、超えたら原因分析をverification.mdに書いて人間にエスカレーション)、グリーン判定はオーケストレーターがクリーン状態で自分で実行して確認する(subagentの自己申告を信じない)、テスト自体を弱める修正(skip・アサーション削除・モック化で通す)の禁止。

- [ ] **Step 4: review.md を書く**

必須内容: クロスモデルレビューの運用(実装がCodexならレビューはClaude/Antigravity、のように別モデル)、レビュー往復は最大2回、指摘の採否はClaudeが最終判断(盲目的に全指摘を反映しない)、レビュー観点(正しさ・intentとの整合・簡潔さ)。

- [ ] **Step 5: リンク実在チェック後コミット**

```bash
git add docs/process && git commit -m "docs: プロセスdoc(lifecycle/git/test/review)を追加"
```

### Task 2: テンプレート(docs/product/, docs/design/, docs/work/)

**Files:**
- Create: `docs/product/templates/prfaq.md`
- Create: `docs/product/templates/ux-research.md`
- Create: `docs/product/templates/lean-canvas.md`
- Create: `docs/design/templates/design-doc.md`
- Create: `docs/design/templates/adr.md`
- Create: `docs/work/README.md`

- [ ] **Step 1: prfaq.md** — プレスリリース(見出し/課題/解決/顧客の声)+ FAQ(外部FAQ・内部FAQ)のセクション構造と各欄の書き方ガイドをコメントで含む。
- [ ] **Step 2: ux-research.md** — 調査目的/仮説/対象ユーザー/調査方法(インタビュー・競合調査・デスクリサーチ)/発見/インサイト/次アクション。
- [ ] **Step 3: lean-canvas.md** — 9ブロックを見出しで表現。
- [ ] **Step 4: design-doc.md** — 背景/ゴール・非ゴール/設計案(2-3案と採用理由)/構成/エラー処理/テスト方針。
- [ ] **Step 5: adr.md** — ステータス/コンテキスト/決定/結果。
- [ ] **Step 6: docs/work/README.md** — boltディレクトリの構造説明(intent.md/spec.md/plan.md/verification.md)と各ファイルのミニテンプレート。
- [ ] **Step 7: コミット**

```bash
git add docs/product docs/design docs/work && git commit -m "docs: 成果物テンプレート一式を追加"
```

### Task 3: スキル(.claude/skills/)

**Files:**
- Create: `.claude/skills/cli-routing/SKILL.md`
- Create: `.claude/skills/bolt/SKILL.md`
- Create: `.claude/skills/prfaq/SKILL.md`
- Create: `.claude/skills/ux-research/SKILL.md`

各SKILL.mdはfrontmatter(`name`, `description`)必須。descriptionは「いつ使うか」を書く。

- [ ] **Step 1: cli-routing/SKILL.md** — specの判断表(Claude=指揮・判断・検証・難所/Codex=独立実装・セカンドオピニオン/Antigravity=バルク・検索・長文要約)、委譲の損益分岐(小タスク・判断が重いタスクは委譲しない)、委譲時の必須3点(仕様を書面で渡す/ダイジェストで受ける/検証はClaude)、具体的な呼び出し方(codex-worker subagent、antigravity:delegateスキル)。
- [ ] **Step 2: bolt/SKILL.md** — bolt開始手順(ブランチ作成→workディレクトリ作成→intent.md記入)、フェーズ判定(lifecycle.mdの基準を参照)、各フェーズで読むべきプロセスdoc・使うテンプレートへのリンク、完了条件チェックリスト(グリーン確認・verification.md記入・merge)。
- [ ] **Step 3: prfaq/SKILL.md** — テンプレートへのリンク、書く順序(顧客課題→プレスリリース→FAQ)、レビュー観点(顧客視点か・測定可能か)、完了後にux-researchまたは要件フェーズへ進む導線。
- [ ] **Step 4: ux-research/SKILL.md** — テンプレートへのリンク、調査のWeb検索はAntigravityへ委譲する指示(cli-routing参照)、仮説→検証の構造、完了後の導線。
- [ ] **Step 5: リンクチェック後コミット**

```bash
git add .claude/skills && git commit -m "feat: cli-routing/bolt/prfaq/ux-researchスキルを追加"
```

### Task 4: subagent定義(.claude/agents/)

**Files:**
- Create: `.claude/agents/codex-worker.md`
- Create: `.claude/agents/ux-researcher.md`
- Create: `.claude/agents/cross-reviewer.md`

各agentはfrontmatter(`name`, `description`, 必要なら`tools`)+ システムプロンプト本文。

- [ ] **Step 1: codex-worker.md** — mcp__codex経由でCodexに実装を委譲するagent。渡すもの: spec/planへのパス・完了条件。返すもの: 変更ファイル一覧と要約(ダイジェスト)。自己検証はするが最終グリーン判定は呼び出し元が行うことを明記。
- [ ] **Step 2: ux-researcher.md** — Web調査・競合調査を行い、ux-research.mdテンプレートに沿った調査結果を返すagent。検索はAntigravity/WebSearchを使う。
- [ ] **Step 3: cross-reviewer.md** — diffとintentを受け取り、review.mdの観点でレビューし、severity付き指摘リストを返すagent。修正はしない(読み取り専用)。
- [ ] **Step 4: コミット**

```bash
git add .claude/agents && git commit -m "feat: codex-worker/ux-researcher/cross-reviewer subagentを追加"
```

### Task 5: ルートコンテキスト(AGENTS.md / CLAUDE.md / GEMINI.md)

**Files:**
- Create: `AGENTS.md`
- Create: `CLAUDE.md`
- Create: `GEMINI.md`

- [ ] **Step 1: AGENTS.md** — 常時前提セクション(プロジェクトの目的、bolt原則、収束ルールの要約3行、CLIルーティングの要約表)と、参照時のみセクション(各プロセスdoc・テンプレート・スキルへのリンクを「いつ読むか」付きで列挙)。全CLI共通の禁止事項(検証なしのコミット、intent外のdiff、テストを弱める修正)。
- [ ] **Step 2: CLAUDE.md** — `@AGENTS.md` でimport + Claude固有: 「あなたはオーケストレーター。判断・検証・難所を担い、委譲はcli-routingスキルに従う。bolt開始時はboltスキルを使う」。
- [ ] **Step 3: GEMINI.md** — AGENTS.md参照 + Gemini/Antigravity固有: 「あなたは実行者(worker)。渡されたspecの範囲でのみ作業し、結果はダイジェストで返す。自己申告のGREENは最終判定ではない」。
- [ ] **Step 4: リンク実在チェック後コミット**

```bash
git add AGENTS.md CLAUDE.md GEMINI.md && git commit -m "feat: AGENTS.md単一ソースとCLAUDE/GEMINI参照を追加"
```

### Task 6: 設定ファイル(.claude/settings.json / .codex/config.toml / .gemini/settings.json)

**Files:**
- Create: `.claude/settings.json`
- Create: `.codex/config.toml`
- Create: `.gemini/settings.json`

- [ ] **Step 1: .claude/settings.json** — 安全側の権限プラクティス例: read系Bash(ls/cat相当は専用ツール推奨のため最小限)、`git status/diff/log` をallow、deny例(`rm -rf`等)。コメント不可のJSONなので、説明は同ディレクトリのdocかREADMEに書く。
- [ ] **Step 2: .codex/config.toml** — approval_policy/sandboxの推奨値、AGENTS.mdを読む前提のコメント、モデル指定はプレースホルダ。
- [ ] **Step 3: .gemini/settings.json** — GEMINI.mdをcontextとして読む設定、ツール許可の例。
- [ ] **Step 4: コミット**

```bash
git add .claude/settings.json .codex .gemini && git commit -m "feat: 3 CLIの設定プラクティス例を追加"
```

### Task 7: README.md と最終検証

**Files:**
- Create: `README.md`

- [ ] **Step 1: README.md** — フレームワークの思想(3行)、導入手順(コピー→プロジェクト固有情報をAGENTS.mdに追記→bolt開始)、全体マップ(ディレクトリ構造と各ファイルの役割の表)、最初のboltの回し方チュートリアル(企画boltの例)。
- [ ] **Step 2: 全リンク検証** — 全.mdファイル内の相対リンクを抽出し、リンク先の実在をスクリプトで確認。壊れリンクは修正。

```bash
grep -roE '\]\(([^)#http][^)]*)\)' --include='*.md' . | # 相対リンク抽出して実在確認
```

- [ ] **Step 3: spec成功基準との突合** — specの成功基準3点(役割把握・両フェーズがboltで回る・重複なし)を満たすか確認し、結果を記録。
- [ ] **Step 4: コミット**

```bash
git add README.md && git commit -m "docs: READMEと導入チュートリアルを追加"
```

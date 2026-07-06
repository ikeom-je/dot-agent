# dot-agent フレームワーク設計

日付: 2026-07-06
ステータス: 承認済み

## 目的

Claude Code をオーケストレーターとし、Codex / Antigravity(Gemini)を subagent として使い、
サービス・アプリの企画(PRFAQ、UX調査)から AI-DLC 的な設計・実装・テストまでの
上流〜下流工程を伴走支援するためのテンプレートリポジトリ(スケルトン)を提供する。

利用者はこのリポジトリを新規プロジェクトにコピー/clone して開始する。
フレームワーク自体は実行コードを持たず、Markdown(設定・スキル・プロセスdoc)のみで構成する。

## 決定事項

- 配布形態: テンプレートリポジトリ(コピーして使う)
- 範囲: 企画〜実装のフルサイクル(全フェーズをスキル+ドキュメントで定義)
- 記述言語: 日本語主体(コード識別子・コマンド・技術用語は英語のまま)

## ディレクトリ構造

```
dot-agent/
├── README.md              # 思想・導入手順・全体マップ
├── AGENTS.md              # ★単一ソース:常時読み込むコンテキスト(全CLI共通)
├── CLAUDE.md              # AGENTS.md 参照 + Claude 固有(オーケストレーター役割宣言)
├── GEMINI.md              # AGENTS.md 参照 + Gemini/Antigravity 固有(実行者役割)
├── .claude/
│   ├── settings.json      # 権限・共通設定のプラクティス例
│   ├── agents/
│   │   ├── codex-worker.md     # Codex への実装委譲 subagent
│   │   ├── ux-researcher.md    # UX 調査 subagent
│   │   └── cross-reviewer.md   # クロスモデルレビュー subagent
│   └── skills/
│       ├── cli-routing/SKILL.md   # CC/Codex/Antigravity 使い分け判断基準
│       ├── prfaq/SKILL.md         # PRFAQ 作成(テンプレート付き)
│       ├── ux-research/SKILL.md   # UX 調査
│       └── bolt/SKILL.md          # AI-DLC の 1 サイクル(bolt)進行
├── .codex/config.toml     # Codex CLI のプラクティス設定
├── .gemini/settings.json  # Antigravity / Gemini CLI のプラクティス設定
└── docs/
    ├── process/
    │   ├── lifecycle.md   # 企画→PRFAQ→UX調査→要件→設計→実装→テスト→収束の全体像
    │   ├── git.md         # ブランチ運用・コミット粒度・マージ収束ルール
    │   ├── test.md        # テストループの回し方と収束条件
    │   └── review.md      # クロスモデルレビューの運用
    ├── product/templates/ # prfaq.md / ux-research.md / lean-canvas.md
    ├── design/templates/  # design-doc.md / adr.md
    └── work/              # 実際の成果物置き場(bolt 単位のディレクトリ)
```

## 中核概念

### 1. 単一ソースのコンテキスト

- `AGENTS.md` にプロジェクト規約・役割分担・プロセス doc へのリンク集を集約する。
  リンクには「常時前提とする」「該当作業時のみ読む」の区別を付ける。
- `CLAUDE.md` は `@AGENTS.md` で import し、Claude 固有の「オーケストレーター」宣言のみ持つ。
- `GEMINI.md` も同様に AGENTS.md を参照し、「実行者(worker)」としての振る舞いのみ追記する。
- Codex は AGENTS.md をネイティブに読むため追記不要。重複記述はゼロにする。

### 2. bolt(小さい作業単位)

- 企画 1 トピック・機能 1 つを、数時間〜1 セッションで完結する bolt として定義する。
- 各 bolt は `docs/work/YYYY-MM-DD-<topic>/` に intent(目的)→ spec → plan →
  実装 → 検証記録を残す。上流(PRFAQ)も下流(実装)も同じ bolt 構造で回す。
- `bolt` スキルが進行役: フェーズ判定 → 該当プロセス doc の参照 → 成果物テンプレートの適用
  → 完了条件チェック、を導く。

### 3. 収束ルール(循環最適化の停止条件)

- test.md: テスト失敗の修正ループは最大 3 回。超えたら原因分析を書いて人間にエスカレーション。
  グリーン判定はオーケストレーター自身がクリーンな状態で実行して確認する
  (subagent の自己申告 GREEN を信じない)。
- git.md: 1 bolt = 1 ブランチ。diff が bolt の intent 外に膨らんだら別 bolt に分割。
  コミットは検証済みの単位でのみ行う。
- review.md: レビュー往復は最大 2 回。指摘の採否は Claude が最終判断する。

### 4. CLI ルーティング(cli-routing スキル)

判断表を持つ:

| エージェント | 得意領域 | 使う場面 |
|---|---|---|
| Claude Code | オーケストレーション・判断・検証・難所の実装 | 常時(指揮者)。小さい/判断が重いタスクは自分で |
| Codex | 独立した実装タスク・セカンドオピニオン | 仕様が固まった実装単位の委譲、レビュー |
| Antigravity | バルク生成・移行・Web検索・長文要約 | 損益分岐を超える反復作業、検索系 |

- 委譲の損益分岐を明記: 小タスクの委譲は往復コストで損。
- 委譲時の必須事項: 仕様を書面で渡す・結果はダイジェストで受ける・検証は Claude が行う。

## スコープ外(YAGNI)

- 実行スクリプト・Makefile による自動化(必要になったら追加)
- Claude Code プラグイン化・マーケットプレイス配布
- CI/CD 設定、特定言語向けのテスト設定

## 成功基準

- このリポジトリをコピーした新規プロジェクトで、各 CLI(claude / codex / agy)が
  自分の役割とプロセスを追加説明なしに把握できる。
- 企画フェーズ(PRFAQ 作成)と実装フェーズ(テストループ付き実装)の両方が
  bolt スキルの導きで最初から最後まで回る。
- ドキュメント間のリンクが切れておらず、記述の重複がない。

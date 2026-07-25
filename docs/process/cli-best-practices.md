# cli-best-practices.md — 各CLIのベストプラクティスと dot-agent での実践

各CLIの公式ベストプラクティスを、dot-agent の仕組みに対応づけた運用ガイド。
公式docの置き換えではなく「dot-agent 上でどう実践するか」の変換表。出典と取得日を明記する
(公式は更新されるため、大きな乖離に気づいたらこの doc を bolt で改訂する)。

## Claude Code(指揮者・既定)

出典: https://code.claude.com/docs/ja/best-practices (2026-07-20 取得)、
https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models
(2026-07-25 取得。Claude 5世代モデル固有の追補)

**Claude 5世代の追補(2026-07-25)**: Anthropic はシステムプロンプトを80%以上削減しても
コード評価に測定可能な低下が無かったと報告している(原文: "We removed over 80% of Claude
Code's system prompt for models like Claude Opus 5 and Claude Fable 5"。逐語引用を
2026-07-25にWebFetchで再確認済み)。核心は「ルールを与える→判断に任せる」への転換で、
"leave documentation as appropriate" と "DO NOT add comments" のような**矛盾する指示**が
悪影響を与えていた、という具体例がある(こちらも同様に逐語確認済み)。ツール/スキルの
説明は使用例の羅列よりパラメータ構造の明確さを重視し、段階的開示(必要時にスキルを
読み込む)を推奨する。記事は `/doctor` コマンド(Claude Code でスキル・CLAUDE.md を
適正サイズに調整する)の存在にも言及している(原文: "use the command /doctor in Claude
Code to rightsize your skills, and CLAUDE.md files"。2026-07-25にWebFetchで逐語確認済み)。
利用可能なら AGENTS.md/skills の定期的な削減(過去に本リポジトリで行った圧縮 bolt の
ような棚卸し作業)の一次手段として試す価値がある(手元のCLIバージョンでの利用可否は
導入時に確認する)。

**Sonnet/Opus 向け Fable5 的振る舞いの補強(2026-07-25)**: 出典
https://qiita.com/TakanobuSano/items/68e136b22294e1575d55 、
https://note.com/hataraiku/n/n70ca8c2e217a (2026-07-25取得)+
公式 [Output styles](https://code.claude.com/docs/en/output-styles) /
[costs (effort)](https://code.claude.com/docs/en/costs) で仕様確認済み。

- **Output Style で報告スタイルを補強** — `.claude/output-styles/` はプロジェクト単位で
  使え、Claude Code 専用機能(Codex/Antigravity は読まない)。既存のコーディング規律を
  消さないため `keep-coding-instructions: true` を必ず付ける(既定 `false`)。
  [.claude/output-styles/fable-mode.md](../../.claude/output-styles/fable-mode.md) に
  結論先行・境界意識(状態変更前の証拠確認)・即行動(承認ゲートは除く)を収録した。
  有効化は `/config` でのオプトイン(settings.json での既定化はしていない)。
- **サブエージェントは継承しない**(fork は例外)。`.claude/agents/` 配下の Claude 実行の
  subagent には別途最小限の出力規約を書く必要がある(cross-reviewer / ux-researcher に反映)。
- **effort レベルは `/effort` または `/model` で調整可能**(公式確認済み)。設計判断・
  レビューなど精度が要る局面で引き上げる。「Fable5 の低effort ≒ 旧モデルの高effort」の
  ような換算式は公式文書に存在しないため、断定的に使わない。
- **意図的に転記しなかったもの**: 提示された行動規範のうち「進捗の実証」「スコープ規律」は
  dot-agent の既存規約(GREEN判定権限・intent.md規律)と重複するため、「ターン終了規律」は
  Claude Code の既定の振る舞いに近い領域のため output style には書かない(Claude 5世代の
  「重複を書かない」原則を優先。詳細と各項目の判断根拠は fable-mode.md 内に記録)。

| 公式BPの要点 | dot-agent での実践 |
|---|---|
| **コンテキストウィンドウが最重要リソース**。満杯になるほど性能低下 | bolt を `bolt_max_size` に収める・無関係なタスクを混ぜない(1 bolt = 1 トピック)。話題が変わったら bolt を閉じて新セッション+新 bolt |
| **判断に任せる>硬いルール**(Claude 5世代)。矛盾する指示を置かない | AGENTS.md/CLAUDE.mdの禁止事項は安全・プロセス上必須のガードレールのみに絞る(検証していないコミット・秘密情報の取り扱い等)。スタイルの好みのような判断で足りる領域は「〜に従う」より「〜を判断する」と書く |
| ツール/スキル説明は使用例の羅列よりパラメータ構造の明確さ(Claude 5世代) | skill frontmatterの`description`は「いつ使うか」を1文で明確に。エージェント定義(`.claude/agents/`)も長い使用例より役割・入出力の構造を優先 |
| 調査・大量読みはサブエージェントに分離し、本体のコンテキストを守る | [cli-routing](../../.claude/skills/cli-routing/SKILL.md) の委譲(ダイジェストで受ける)。調査系は編成表の担当へ |
| **検証手段を与える**(pass/fail を返すチェック)。成功の主張ではなく証拠を出させる | AGENTS.md プロジェクト固有欄の正式テストコマンド=グリーン判定。証拠は PR 本文に記録([test.md](test.md)) |
| **探索→計画→実装→コミット**。ただし小さく明確な修正は計画を省略 | lifecycle のフェーズ(spec→plan→実装)がこの型。省略判断は [workflows.md](workflows.md) のプロファイルと lifecycle の省略ルール |
| プロンプトは具体的に: ファイル・制約・既存パターンを指す | 委譲の必須3点(spec/plan のパスと完了条件を書面で渡す) |
| **CLAUDE.md は短く**、広く適用されるもののみ。ドメイン知識はスキルへ。「削るとClaudeが間違えるか?」で査定 | AGENTS.md 単一ソース+「該当作業時に読む」参照表の設計根拠。AGENTS.md が肥大化したらこの基準で削る bolt を回す |
| 権限は allowlist / sandbox で中断を減らしつつ制御 | `.claude/settings.json`(安全側の例)。破壊的操作 deny は維持 |
| 2回修正して直らないコンテキストは汚れている。クリアしてより良いプロンプトで再開 | `max_fix_loops` の思想と同じ。打ち切り時は issue に記録してエスカレーション |
| 新しいコンテキストのレビュアー(Writer/Reviewer 分離・敵対的レビュー)。ただし指摘の全採用は過剰設計を生む | [cross-review](../../.claude/skills/cross-review/SKILL.md) の別モデル原則+指揮者の採否判断(盲目的全反映の禁止) |
| 大きい機能は先にインタビューさせて仕様化し、実装は新セッションで | 上流フェーズ(prfaq/spec)で人間に問いを立てる運用。仕様は自己完結(関連ファイル・非スコープ・検証手順)にする |
| ヘッドレス `claude -p` で自動化・ファンアウト。`--allowedTools` でスコープ制限 | cli-routing の汎用経路。無人実行ほど権限を絞る |

## Codex / GPT-5.x(奏者・実装とレビューの既定担当)

出典: https://developers.openai.com/api/docs/guides/latest-model (2026-07-20 取得)

| 公式ガイドの要点 | dot-agent での実践 |
|---|---|
| **アウトカムファースト**: 手順を細かく縛らず「達成すべき結果と成功基準」を指示し、効率的なパスをモデルに選ばせる | codex-worker への委譲は spec/plan のパス+完了条件のみ渡す(実装手順を指図しない)。cross-review 依頼も「観点と出力形式」を渡し、レビュー手順は任せる |
| **停止条件を明記する**(「十分な証拠が得られたら止める」等) | 委譲プロンプトに収束条件を含める: 修正ループは `max_fix_loops`、レビューは「残存 major のみ/無ければ収束と回答」 |
| 冗長度・推論量は調整可能(verbosity / reasoning.effort) | レビュー依頼は「指摘リストのみ出力」を指定(現行テンプレ)。重い設計判断を任せる場合のみ深い推論を要求 |
| **検証コマンドを明示的に指示する** | 委譲の必須3点(完了条件=実行すべきテストコマンド)。ただし最終グリーン判定は指揮者([test.md](test.md)) |
| ツールの副作用・リトライ安全性を説明する | 委譲時に read-only か書き込み可か、リトライしてよい操作かを明示(レビューは read-only サンドボックス) |

## Antigravity / Gemini(奏者・調査/バルク/マルチモーダルの既定担当)

出典: https://antigravity.google/docs/cli/best-practices —
**2026-07-20 時点で本文の取得不可(JSレンダリングのため)**。閲覧可能になったら
この節を公式BPで改訂する bolt を起票すること。以下は本リポジトリでの実測知見と
プラグインの運用方針に基づく:

| 実測・運用知見 | dot-agent での実践 |
|---|---|
| コスト規律のある委譲: 小タスクの委譲は往復コストで損。バルク・検索・長文で使う | cli-routing の損益分岐+編成表の担当領域 |
| リポジトリを直接読ませる(`--dir` で AGENTS.md と実ファイルを参照させる)方が、文脈の貼り付けより安く正確 | 委譲の必須3点(書面で渡す・リポジトリを読ませる) |
| 出力はダイジェストで受け、生出力を指揮者のコンテキストに戻さない | 同上(ダイジェストで受ける) |
| ティア選択(flash=安価な検索・バルク / pro=精度が要る処理)がコストレバー | 委譲時にタスクの重さでティアを指定。失敗時のティア変更も試行1回に数える(`max_delegation_retries`) |
| 自己申告 GREEN を信じない(環境書き換えでテストを通す挙動の観察例あり)。出典なしの主張を検証せず使わない | [test.md](test.md) のグリーン判定権限+[review.md](review.md) の「Antigravity の出力は必ず指揮者が検証」 |
| 空応答・不安定応答が起きうる(本リポジトリで実績) | `max_delegation_retries` で打ち切り、編成表の代替(WebSearch 等)へフォールバック |

## 案件(プロファイル)ごとの使い分けガイド

[workflows.md](workflows.md) のプロファイルに、上のBPを重ねたときの力点:

- **design-first**: Claude Code の「探索→計画」を最大化(Plan を厚く、レビュー往復は
  workflows.md の推奨値 3。適用は AGENTS.md パラメータ表の書き換え、または bolt 単位なら
  intent.md への明記で)。実装委譲は spec が固まってからに限る。
- **mvp-sprint**: 公式BPの「小さく明確な修正は計画を省略」は、bolt では**plan.md を
  最小化(タスク分解1〜3行)する**形で適用する(フェーズ自体は飛ばさない —
  lifecycle.md の規定はこのガイドでは変更しない)。検証手段(テストコマンド)だけは
  最初に確立する(公式BP「検証できないなら出荷しない」)。レビューはコードのみ。
- **pitch-deck**: 調査ファンアウトは Antigravity(コスト規律+出典必須)。
  資料の主張はレビューで出典チェック。
- **共通**: どのプロファイルでも、コンテキストが汚れたら(同一問題への修正2回超)
  セッションを畳んで bolt の書面(intent/spec/plan)から再開する。書面が整っていれば
  セッションはいつでも捨てられる — これが bolt 構造の狙いでもある。

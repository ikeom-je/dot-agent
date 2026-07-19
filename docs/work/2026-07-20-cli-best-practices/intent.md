# intent: cli-best-practices

プロファイル: standard

- 解きたい課題: 各CLI(Claude Code / Codex / Antigravity)の公式ベストプラクティスが
  dot-agent の運用に対応づけられておらず、案件ごとの使い方が個人の経験知に依存している。
- この bolt でやること: `docs/process/cli-best-practices.md` を新設し、
  1. Claude Code 公式BP(code.claude.com/docs/ja/best-practices、2026-07-20 取得)
  2. GPT-5.5/Codex 公式ガイド(developers.openai.com、2026-07-20 取得)
  3. Antigravity 公式BP(URL のみ。本文は 2026-07-20 時点で取得不可 → 実測知見と
     プラグイン方針で補い、その旨明記)
  の要点を「dot-agent のどの仕組みに対応するか」+「案件(プロファイル)ごとの使い方」
  として整理。AGENTS.md 参照表に行を追加。
  ※ 内部改善boltのため上流フェーズ(2〜5)は省略。
- やらないこと: 公式docの全訳・転載、既存プロセスdocの規定変更(対応づけと運用ガイドのみ)、
  Antigravity 公式BPの推測による創作。
- 完了の定義: ガイドが存在し AGENTS.md から参照され、3CLI分の要点が出典日付きで
  dot-agent の仕組みに対応づいている。正式グリーン判定グリーン、相互レビュー収束、merge 済み。

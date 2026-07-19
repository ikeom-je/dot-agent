# intent: generic-template

- 解きたい課題: テンプレートとして他案件にコピーする際、(1) 試行した個別案件
  (請求書自動化・MediaMine)とフレームワーク自身の開発記録が docs/work/ と README に
  混入している、(2) .gitignore が無く秘密情報・OSゴミの混入防御が無い、(3) 秘密情報の
  取り扱い禁止が全エージェント共通の場所(AGENTS.md)に無い、(4) 案件の性質
  (設計重視/MVP速度/アイデア共有)に応じたワークフローの使い分けが定義されていない。
- この bolt でやること:
  1. docs/work/ の既存記録を docs/examples/ に隔離し、テンプレ導入時に削除してよいと明記。
     README の案件例を汎用プレースホルダーに書き換え
  2. .gitignore を追加(秘密情報・OS/エディタゴミ・主要言語の生成物・ハーネスの
     一時ファイル。誤トラックされていた .claude/scheduled_tasks.lock の削除を含む)
  3. AGENTS.md 共通禁止事項に秘密情報の取り扱いを追加、.codex/.gemini にも注記
  4. docs/process/workflows.md を新設: ユースケースプロファイル
     (design-first / mvp-sprint / pitch-deck)をフェーズ構成+パラメータ推奨値で定義。
     pitch-deck 用スライド構成テンプレートを追加。bolt スキル・AGENTS.md から参照
  ※ 内部改善boltのため上流フェーズ(2〜5)は省略。
- やらないこと: プロファイルの自動適用機構、収束パラメータの既定値変更、
  docs/superpowers(設計経緯)の削除、スライドのビジュアルデザインガイド。
- 完了の定義: 案件固有語が docs/examples/ 以外に無い(grep で確認。監査記録として
  案件名に言及するこの intent 自身は除く)、
  正式グリーン判定(check-links + test)がグリーン、相互レビュー収束、merge 済み。

---
name: ux-research
description: PRFAQ や企画の仮説を検証するための UX 調査(デスクリサーチ・競合調査・インタビュー設計)を行うときに使う。
---

# ux-research — UX 調査

仮説を立ててから調べる。「なんとなく調べる」は発散して収束しない。
テンプレート: [docs/product/templates/ux-research.md](../../../docs/product/templates/ux-research.md) を
bolt の work ディレクトリに `ux-research.md` としてコピーして書く。

## 手順

1. **仮説を書き出す** — prfaq.md(特に内部FAQの「答えられなかった質問」)から、
   検証すべき仮説を番号付きで抜き出す。仮説の無い調査は始めない。
2. **調査方法を選ぶ** — デスクリサーチ/競合調査/インタビューから、仮説ごとに最小の方法を選ぶ。
3. **調査を実行する**:
   - **Web検索・競合調査は Antigravity に委譲する**(live 検索は Claude 単体より
     Antigravity が得意。`cli-routing` スキル参照、呼び出しは `antigravity:research`
     または `ux-researcher` subagent)。結果はダイジェストで受け、出典 URL を必ず添えさせる。
   - インタビューは人間が行う。ここでは設問設計とリクルート条件の定義までを支援する。
4. **発見とインサイトを分けて書く** — ファクト(出典付き)とその解釈を混ぜない。
5. **仮説に判定を付ける** — 支持/棄却/不明。「不明」を無理に支持にしない。

## 収束条件

- 主要仮説すべてに判定が付いたら調査を止める。追加で調べたいことが出ても、
  この bolt の仮説に関係なければ次アクションに書いて終わる(調査の無限拡大を防ぐ)。
- 判定が出たら、`review_gate_phases` がこのフェーズを対象とする場合、
  [docs/process/review.md](../../../docs/process/review.md) に従い別モデルに相互レビューさせる
  (観点: 出典の実在・発見と解釈の分離・判定の妥当性)。往復は `max_review_rounds` まで。
  レビュー収束をもってフェーズ完了。

## 完了後の導線

- 仮説が棄却された → prfaq.md を直すか、企画を pivot する(新しい bolt)
- 仮説が支持された → `user-story` スキル(ユーザーストーリーフェーズ)へ

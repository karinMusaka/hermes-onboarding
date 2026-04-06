# Hermes オンボーディング — セットアップガイド（管理者向け）

## 概要

ターミナル未経験の中村さん（COO）が Hermes を使えるようにするためのパッケージ。
1行コピペ → ウィザード → チュートリアル → ミッションの流れ。

## リポジトリ

- URL: https://github.com/karinMusaka/hermes-onboarding
- 種別: private
- 作成日: 2026-04-06

## ファイル構成

```
install.sh      メインインストーラー (curl で実行)
wizard.sh       日本語対話式の設定ウィザード (3ステップ)
tutorial.sh     ハンズオンチュートリアル (5レッスン)
missions.sh     レベルアップミッション (9問: 初級3, 中級3, 上級3)
plan.md         設計ドキュメント
docs/           管理者向けドキュメント
```

## 中村さんに渡す前のチェックリスト

- [ ] Anthropic アカウント新規作成（中村さん用、別サブスク）
- [ ] API キー発行
- [ ] リポジトリを public にする or install.sh を Gist に置く
      ※ private のままだと raw URL に認証が必要
- [ ] API キーを中村さんに共有（Slack DM 推奨、コピペしやすい）

## 中村さんに伝えること

1. ターミナルの開き方
   - Spotlight (Cmd+Space) → 「ターミナル」と入力 → Enter
   
2. 以下を貼り付けて Enter
   ```
   curl -sL https://raw.githubusercontent.com/karinMusaka/hermes-onboarding/main/install.sh | bash
   ```

3. あとは画面の指示に従う
   - パスワード聞かれたら Mac のログインパスワード
   - API キー聞かれたら共有されたキーを貼り付け

4. 初回は木原さんが横で見てあげると安心
   - Xcode CLT のダイアログが出る（「インストール」を押すだけ）
   - Homebrew インストール時にパスワード入力あり

## インストール後に入るもの

- Homebrew（パッケージマネージャー）
- Python 3.11 + uv
- ripgrep（ファイル検索高速化）
- Hermes 本体 (~/.hermes/hermes-agent/)
- hermes コマンド (~/.local/bin/hermes)
- オンボーディングスクリプト (~/.hermes/onboarding/)

## フロー詳細

```
Phase 1: install.sh（自動、3-5分）
  - Xcode CLT 確認
  - Homebrew インストール
  - uv + Python 3.11
  - Hermes クローン + セットアップ
  - オンボーディングスクリプト取得

Phase 2: wizard.sh（対話式、5分）
  - ステップ1: AI プロバイダー選択 + API キー入力 + 接続テスト
  - ステップ2: 名前・メール・役職・会社名
  - ステップ3: Slack 連携（オプション、スキップ推奨）

Phase 3: tutorial.sh（ハンズオン、10分）
  - レッスン1: Hermes と話す（hermes "質問"）
  - レッスン2: ファイル作成
  - レッスン3: 情報収集
  - レッスン4: ビジネス活用（メール下書き）
  - レッスン5: 便利機能まとめ
  ※ 途中でやめても続きから再開可能

Phase 4: missions.sh（自分のペースで）
  🟢 初級: 天気確認、リマインダー、予定確認
  🟡 中級: メール下書き、リサーチ、議事録テンプレ
  🔴 上級: cron ブリーフィング、Slack 連携、ワークフロー自動化
  ※ bash ~/.hermes/onboarding/missions.sh で一覧表示
```

## トラブルシューティング

### ターミナルが真っ白 / hermes が動かない
```
source ~/.zshrc
```

### API キーエラー
```
hermes setup  ← 設定ウィザード再実行
```

### Hermes を更新したい
```
hermes update
```

### チュートリアルをやり直したい
```
bash ~/.hermes/onboarding/tutorial.sh
```
進捗をリセットしてからやり直す場合:
```
rm ~/.hermes/onboarding/progress.txt
bash ~/.hermes/onboarding/tutorial.sh
```

## 今後の拡張案

- [ ] missions を Hermes の skill として統合（hermes mission コマンド）
- [ ] 進捗を Slack に通知（木原さんが中村さんの進捗を見れる）
- [ ] Google Workspace 連携のウィザード追加（Gmail, Calendar）
- [ ] Web UI 版（ブラウザから使えるフロントエンド）

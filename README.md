# Hermes オンボーディングパッケージ

ターミナル未経験者が Hermes を使い始めるためのセットアップ＆チュートリアル。

## ワンライナーインストール

```bash
curl -sL https://raw.githubusercontent.com/karinMusaka/hermes-onboarding/main/install.sh | bash
```

## 何が起きるか

```
ワンライナー実行
  ↓
Phase 1: 自動インストール (Homebrew, Python, Hermes)  ← 3-5分、触らなくてOK
  ↓
Phase 2: 設定ウィザード (API キー、名前、Slack)       ← 番号選ぶだけ
  ↓
Phase 3: チュートリアル (5レッスン、実際に使う)        ← 10分
  ↓
Phase 4: ミッション (日常業務の練習問題)               ← 自分のペースで
```

## ファイル構成

```
install.sh      ← メインインストーラー (curl で実行される)
wizard.sh       ← 日本語対話式の設定ウィザード
tutorial.sh     ← ハンズオンチュートリアル (5レッスン)
missions.sh     ← レベルアップミッション (9問)
plan.md         ← 設計ドキュメント
```

## 個別実行

```bash
# チュートリアルだけやり直す
bash ~/.hermes/onboarding/tutorial.sh

# ミッション一覧
bash ~/.hermes/onboarding/missions.sh

# ミッション詳細
bash ~/.hermes/onboarding/missions.sh 3

# ミッション完了マーク
bash ~/.hermes/onboarding/missions.sh done 3

# 設定ウィザード再実行
bash ~/.hermes/onboarding/wizard.sh
```

## 前提条件

- macOS (Apple Silicon / Intel)
- インターネット接続
- Anthropic or OpenAI の API キー

## サポート担当向けメモ

事前に準備しておくもの:
1. Anthropic API キー（中村さん用アカウント）
2. 初回は横について Xcode CLT のインストールダイアログを見てあげる
3. API キーは Slack DM で共有（メールだとコピペしにくい）

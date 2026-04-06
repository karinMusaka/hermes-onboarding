#!/bin/bash
# ============================================================================
# Hermes ミッションシステム
# ============================================================================
# hermes からエイリアスで呼ばれる or 直接実行
# Usage: bash missions.sh [list|1|2|...|reset]
# ============================================================================

set -e

# ── 色定義 ──
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

MISSION_DIR="$HOME/.hermes/onboarding"
PROGRESS_FILE="$MISSION_DIR/mission_progress.txt"
mkdir -p "$MISSION_DIR"
touch "$PROGRESS_FILE"

is_complete() { grep -q "^M${1}$" "$PROGRESS_FILE" 2>/dev/null; }
mark_complete() { echo "M${1}" >> "$PROGRESS_FILE"; }
status_icon() { if is_complete "$1"; then echo "✅"; else echo "□"; fi; }

ACTION="${1:-list}"

# ============================================================================
# ミッション一覧
# ============================================================================
show_list() {
    clear
    cat << 'BANNER'

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    🎯 ミッション一覧
    Hermes を使いこなすための練習問題
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BANNER

    echo -e "  ${GREEN}🟢 初級（今日やってみよう）${NC}"
    echo ""
    echo "    $(status_icon 1)  M1: 今日の天気を聞いてみる"
    echo "    $(status_icon 2)  M2: リマインダーを1つ作る"
    echo "    $(status_icon 3)  M3: 「明日の予定を教えて」と聞く"
    echo ""
    echo -e "  ${YELLOW}🟡 中級（今週チャレンジ）${NC}"
    echo ""
    echo "    $(status_icon 4)  M4: メールの下書きを作ってもらう"
    echo "    $(status_icon 5)  M5: 調べものをして箇条書きでまとめてもらう"
    echo "    $(status_icon 6)  M6: 議事録のテンプレートを作ってもらう"
    echo ""
    echo -e "  ${RED}🔴 上級（使いこなし）${NC}"
    echo ""
    echo "    $(status_icon 7)  M7: 毎朝のブリーフィングを設定する"
    echo "    $(status_icon 8)  M8: Slack 連携を設定する"
    echo "    $(status_icon 9)  M9: 自分のワークフローを1つ自動化する"
    echo ""

    # 進捗カウント
    DONE=0
    for i in $(seq 1 9); do
        is_complete "$i" && ((DONE++)) || true
    done
    echo -e "  ${DIM}進捗: ${DONE}/9 完了${NC}"
    echo ""
    echo "  ミッションの詳細を見るには:"
    echo "    bash ~/.hermes/onboarding/missions.sh [番号]"
    echo ""
    echo "  例: bash ~/.hermes/onboarding/missions.sh 1"
    echo ""
}

# ============================================================================
# 各ミッションの詳細
# ============================================================================
show_mission() {
    local num=$1
    clear

    case $num in
    1)
        echo ""
        echo -e "  ${BOLD}🎯 ミッション 1: 今日の天気を聞いてみる${NC}"
        echo -e "  ${DIM}難易度: 🟢 初級${NC}"
        echo ""
        echo "  Hermes に今日の天気を聞いてみましょう。"
        echo ""
        echo -e "  ${BOLD}やり方:${NC}"
        echo "    ターミナルで以下を実行:"
        echo ""
        echo -e "    ${CYAN}hermes \"東京の今日の天気を教えて\"${NC}"
        echo ""
        echo -e "  ${BOLD}成功条件:${NC}"
        echo "    天気の情報が返ってくればOK！"
        ;;
    2)
        echo ""
        echo -e "  ${BOLD}🎯 ミッション 2: リマインダーを作る${NC}"
        echo -e "  ${DIM}難易度: 🟢 初級${NC}"
        echo ""
        echo "  Hermes に Apple リマインダーを作ってもらいましょう。"
        echo ""
        echo -e "  ${BOLD}やり方:${NC}"
        echo "    ターミナルで以下を実行:"
        echo ""
        echo -e "    ${CYAN}hermes \"明日の10時に『Hermes練習』というリマインダーを作って\"${NC}"
        echo ""
        echo -e "  ${BOLD}成功条件:${NC}"
        echo "    Mac のリマインダーアプリに追加されていればOK！"
        ;;
    3)
        echo ""
        echo -e "  ${BOLD}🎯 ミッション 3: 予定を確認する${NC}"
        echo -e "  ${DIM}難易度: 🟢 初級${NC}"
        echo ""
        echo "  Hermes に明日の予定を聞いてみましょう。"
        echo "  ※カレンダー連携が必要です（Google Calendar 等）"
        echo ""
        echo -e "  ${BOLD}やり方:${NC}"
        echo ""
        echo -e "    ${CYAN}hermes \"明日の予定を教えて\"${NC}"
        echo ""
        echo -e "  ${BOLD}成功条件:${NC}"
        echo "    予定一覧が表示されるか、「連携が必要」と教えてくれればOK！"
        ;;
    4)
        echo ""
        echo -e "  ${BOLD}🎯 ミッション 4: メールの下書きを作る${NC}"
        echo -e "  ${DIM}難易度: 🟡 中級${NC}"
        echo ""
        echo "  実際のビジネスメールの下書きを作ってもらいましょう。"
        echo ""
        echo -e "  ${BOLD}やり方:${NC}"
        echo "    hermes を起動して、こんな感じで指示:"
        echo ""
        echo -e "    ${CYAN}hermes${NC}"
        echo -e "    ${CYAN}> 取引先の〇〇さんに、先日の打ち合わせのお礼と${NC}"
        echo -e "    ${CYAN}  次回の日程調整をお願いするメールを書いて${NC}"
        echo ""
        echo -e "  ${BOLD}成功条件:${NC}"
        echo "    そのまま使えそうなメール文面ができればOK！"
        echo "    気に入らなければ「もう少しカジュアルに」等で修正できます。"
        ;;
    5)
        echo ""
        echo -e "  ${BOLD}🎯 ミッション 5: リサーチしてまとめてもらう${NC}"
        echo -e "  ${DIM}難易度: 🟡 中級${NC}"
        echo ""
        echo "  仕事で気になるトピックを調べてもらいましょう。"
        echo ""
        echo -e "  ${BOLD}やり方:${NC}"
        echo ""
        echo -e "    ${CYAN}hermes \"VTuber市場の2025年のトレンドを5つ、箇条書きでまとめて\"${NC}"
        echo ""
        echo -e "  ${BOLD}成功条件:${NC}"
        echo "    わかりやすい箇条書きが返ってくればOK！"
        ;;
    6)
        echo ""
        echo -e "  ${BOLD}🎯 ミッション 6: 議事録テンプレートを作る${NC}"
        echo -e "  ${DIM}難易度: 🟡 中級${NC}"
        echo ""
        echo "  会議の議事録テンプレートをファイルとして作ってもらいましょう。"
        echo ""
        echo -e "  ${BOLD}やり方:${NC}"
        echo ""
        echo -e "    ${CYAN}hermes \"デスクトップに meeting_template.md という議事録テンプレートを${NC}"
        echo -e "    ${CYAN}作って。日付、参加者、議題、決定事項、TODO の欄があるもの\"${NC}"
        echo ""
        echo -e "  ${BOLD}成功条件:${NC}"
        echo "    デスクトップにファイルができていればOK！"
        ;;
    7)
        echo ""
        echo -e "  ${BOLD}🎯 ミッション 7: 毎朝のブリーフィングを設定${NC}"
        echo -e "  ${DIM}難易度: 🔴 上級${NC}"
        echo ""
        echo "  毎朝自動で情報をまとめてくれる仕組みを作りましょう。"
        echo ""
        echo -e "  ${BOLD}やり方:${NC}"
        echo "    Hermes に相談してみましょう:"
        echo ""
        echo -e "    ${CYAN}hermes \"毎朝9時に今日の予定と天気をまとめて${NC}"
        echo -e "    ${CYAN}Slackに送ってくれる仕組みを作りたい。やり方を教えて\"${NC}"
        echo ""
        echo -e "  ${BOLD}成功条件:${NC}"
        echo "    cron ジョブが設定されて、翌朝ブリーフィングが届けばOK！"
        echo ""
        echo -e "  ${DIM}※ 木原さんにサポートしてもらいましょう${NC}"
        ;;
    8)
        echo ""
        echo -e "  ${BOLD}🎯 ミッション 8: Slack 連携を設定${NC}"
        echo -e "  ${DIM}難易度: 🔴 上級${NC}"
        echo ""
        echo "  Slack から Hermes に話しかけられるようにしましょう。"
        echo ""
        echo -e "  ${BOLD}やり方:${NC}"
        echo "    Hermes に聞いてみましょう:"
        echo ""
        echo -e "    ${CYAN}hermes \"Slack連携を設定したい。手順を教えて\"${NC}"
        echo ""
        echo -e "  ${BOLD}成功条件:${NC}"
        echo "    Slack の DM で Hermes と会話できればOK！"
        echo ""
        echo -e "  ${DIM}※ Slack アプリの設定は木原さんにお願いしましょう${NC}"
        ;;
    9)
        echo ""
        echo -e "  ${BOLD}🎯 ミッション 9: 自分のワークフローを自動化${NC}"
        echo -e "  ${DIM}難易度: 🔴 上級${NC}"
        echo ""
        echo "  日常の繰り返し作業を1つ、Hermes で自動化しましょう。"
        echo ""
        echo -e "  ${BOLD}アイデア例:${NC}"
        echo "    ・週報の自動作成"
        echo "    ・毎日の売上データまとめ"
        echo "    ・定期メールの自動下書き"
        echo "    ・ファイル整理の自動化"
        echo ""
        echo -e "  ${BOLD}やり方:${NC}"
        echo "    Hermes に相談:"
        echo ""
        echo -e "    ${CYAN}hermes \"毎週金曜に今週やったことをまとめた週報の${NC}"
        echo -e "    ${CYAN}下書きを自動で作る仕組みを作りたい\"${NC}"
        echo ""
        echo -e "  ${BOLD}成功条件:${NC}"
        echo "    自動化が1つ動いていればOK！"
        ;;
    *)
        echo -e "  ${RED}ミッション ${num} は存在しません（1〜9）${NC}"
        return
        ;;
    esac

    echo ""
    if is_complete "$num"; then
        echo -e "  ${GREEN}✅ このミッションは完了済みです${NC}"
    else
        echo -e "  完了したら以下を実行:"
        echo -e "    ${CYAN}bash ~/.hermes/onboarding/missions.sh done ${num}${NC}"
    fi
    echo ""
}

# ============================================================================
# コマンド処理
# ============================================================================
case "$ACTION" in
    list|"")
        show_list
        ;;
    done)
        NUM="${2}"
        if [[ -n "$NUM" ]] && [[ "$NUM" =~ ^[1-9]$ ]]; then
            mark_complete "$NUM"
            echo -e "  ${GREEN}✅ ミッション ${NUM} を完了にしました！${NC}"
            echo ""
            # 進捗表示
            DONE=0
            for i in $(seq 1 9); do
                is_complete "$i" && ((DONE++)) || true
            done
            echo -e "  ${DIM}進捗: ${DONE}/9 完了${NC}"

            if [[ $DONE -eq 9 ]]; then
                echo ""
                echo -e "  ${BOLD}🏆 全ミッション完了！すごい！${NC}"
                echo "  Hermes マスターです！"
            fi
        else
            echo "  使い方: bash missions.sh done [1-9]"
        fi
        ;;
    reset)
        > "$PROGRESS_FILE"
        echo "  ミッション進捗をリセットしました"
        ;;
    [1-9])
        show_mission "$ACTION"
        ;;
    *)
        echo "  使い方:"
        echo "    bash missions.sh          ミッション一覧"
        echo "    bash missions.sh [1-9]    ミッション詳細"
        echo "    bash missions.sh done N   ミッション完了"
        echo "    bash missions.sh reset    進捗リセット"
        ;;
esac

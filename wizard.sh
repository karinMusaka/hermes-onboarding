#!/bin/bash
# ============================================================================
# Hermes 設定ウィザード — 日本語対話式
# ============================================================================
# install.sh から自動で呼ばれる。単独実行も可能。
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

info()  { echo -e "${CYAN}→${NC} $1"; }
ok()    { echo -e "${GREEN}✅${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠️${NC}  $1"; }
fail()  { echo -e "${RED}❌${NC} $1"; }
pause() { echo ""; echo -e "${DIM}  Enterキーを押してください...${NC}"; read -r; }

HERMES_DIR="$HOME/.hermes"
ENV_FILE="$HERMES_DIR/.env"
CONFIG_FILE="$HERMES_DIR/config.yaml"
ONBOARD_DIR="$HERMES_DIR/onboarding"

# .env がなければ作成
[[ ! -f "$ENV_FILE" ]] && touch "$ENV_FILE"

# ── .env ヘルパー ──
set_env() {
    local key="$1" value="$2"
    if grep -q "^${key}=" "$ENV_FILE" 2>/dev/null; then
        # 既存の値を更新（macOS sed 互換）
        sed -i '' "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
    else
        echo "${key}=${value}" >> "$ENV_FILE"
    fi
}

get_env() {
    grep "^${1}=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2-
}

# ============================================================================
clear
cat << 'BANNER'

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ⚙️  初期設定（3ステップで終わります）
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BANNER

# ============================================================================
# ステップ 1: AI プロバイダー
# ============================================================================
echo -e "${BOLD}📌 ステップ 1/3: AI プロバイダーの設定${NC}"
echo ""
echo "  Hermes は AI を使って動きます。"
echo "  API キーが必要です（管理者から共有されたものを使います）。"
echo ""
echo "  どの AI を使いますか？"
echo ""
echo "    [1] OpenRouter (Qwen 3) ← おすすめ・低コスト"
echo "    [2] Anthropic (Claude)"
echo "    [3] OpenAI (ChatGPT)"
echo ""

while true; do
    echo -n "  番号を入力 > "
    read -r provider_choice
    case "$provider_choice" in
        1) PROVIDER="openrouter"; PROVIDER_NAME="OpenRouter"; KEY_PREFIX="sk-or-"; KEY_ENV="OPENROUTER_API_KEY"; break ;;
        2) PROVIDER="anthropic"; PROVIDER_NAME="Anthropic"; KEY_PREFIX="sk-ant-"; KEY_ENV="ANTHROPIC_API_KEY"; break ;;
        3) PROVIDER="openai"; PROVIDER_NAME="OpenAI"; KEY_PREFIX="sk-"; KEY_ENV="OPENAI_API_KEY"; break ;;
        *) echo -e "  ${RED}1〜3 の番号を入力してください${NC}" ;;
    esac
done

echo ""

# 既存キーチェック
EXISTING_KEY=$(get_env "$KEY_ENV")
if [[ -n "$EXISTING_KEY" ]]; then
    MASKED="${EXISTING_KEY:0:10}...${EXISTING_KEY: -4}"
    echo -e "  既に API キーが設定されています: ${DIM}${MASKED}${NC}"
    echo -n "  変更しますか？ [y/N] > "
    read -r change_key
    if [[ ! "$change_key" =~ ^[yY]$ ]]; then
        ok "既存のキーを使用します"
        goto_step2=true
    fi
fi

if [[ "$goto_step2" != "true" ]]; then
    echo "  ${PROVIDER_NAME} の API キーを貼り付けてください。"
    echo -e "  ${DIM}（キーは ${KEY_PREFIX} で始まります）${NC}"
    echo ""

    while true; do
        echo -n "  API キー > "
        read -rs api_key  # -s で入力を隠す
        echo ""

        if [[ -z "$api_key" ]]; then
            echo -e "  ${RED}キーが入力されていません${NC}"
            continue
        fi

        # 接続テスト
        info "接続テスト中..."

        if [[ "$PROVIDER" == "anthropic" ]]; then
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
                -H "x-api-key: $api_key" \
                -H "anthropic-version: 2023-06-01" \
                -H "content-type: application/json" \
                -d '{"model":"claude-sonnet-4-20250514","max_tokens":10,"messages":[{"role":"user","content":"hi"}]}' \
                https://api.anthropic.com/v1/messages 2>/dev/null)
        elif [[ "$PROVIDER" == "openrouter" ]]; then
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
                -H "Authorization: Bearer $api_key" \
                -H "Content-Type: application/json" \
                -d '{"model":"qwen/qwen3-235b-a22b","max_tokens":10,"messages":[{"role":"user","content":"hi"}]}' \
                https://openrouter.ai/api/v1/chat/completions 2>/dev/null)
        else
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
                -H "Authorization: Bearer $api_key" \
                -H "Content-Type: application/json" \
                -d '{"model":"gpt-4o-mini","max_tokens":10,"messages":[{"role":"user","content":"hi"}]}' \
                https://api.openai.com/v1/chat/completions 2>/dev/null)
        fi

        if [[ "$HTTP_CODE" == "200" ]]; then
            set_env "$KEY_ENV" "$api_key"
            ok "接続テスト成功！${PROVIDER_NAME} が使えます。"
            break
        elif [[ "$HTTP_CODE" == "401" ]]; then
            fail "API キーが無効です。もう一度確認してください。"
        elif [[ "$HTTP_CODE" == "000" ]]; then
            fail "ネットワークエラー。Wi-Fi を確認してください。"
            echo -n "  もう一度試しますか？ [Y/n] > "
            read -r retry
            [[ "$retry" =~ ^[nN]$ ]] && break
        else
            warn "予期しない応答 (HTTP $HTTP_CODE)。キーを保存しますか？"
            echo -n "  [Y/n] > "
            read -r save_anyway
            if [[ ! "$save_anyway" =~ ^[nN]$ ]]; then
                set_env "$KEY_ENV" "$api_key"
                ok "キーを保存しました"
                break
            fi
        fi
    done
fi

# モデル設定
if [[ "$PROVIDER" == "openrouter" ]]; then
    DEFAULT_MODEL="qwen/qwen3-235b-a22b"
elif [[ "$PROVIDER" == "anthropic" ]]; then
    DEFAULT_MODEL="claude-sonnet-4-20250514"
else
    DEFAULT_MODEL="gpt-4o"
fi

# config.yaml にプロバイダー設定を書く
mkdir -p "$HERMES_DIR"
cat > "$CONFIG_FILE" << YAML
model:
  default: ${DEFAULT_MODEL}
  provider: ${PROVIDER}
YAML
ok "設定ファイル作成"

echo ""
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================================================
# ステップ 2: ユーザー情報
# ============================================================================
echo -e "${BOLD}📌 ステップ 2/3: あなたの情報${NC}"
echo ""
echo "  Hermes があなたのことを覚えて、より良いアシスタントになります。"
echo ""

echo -n "  名前（フルネーム）> "
read -r user_name
[[ -z "$user_name" ]] && user_name="ユーザー"

echo -n "  メールアドレス > "
read -r user_email

echo -n "  役職 > "
read -r user_role

echo -n "  会社名 > "
read -r user_company

# ユーザープロフィールを memory に書き込む
USER_PROFILE_DIR="$HERMES_DIR"
USER_PROFILE_FILE="$USER_PROFILE_DIR/user_profile.txt"
cat > "$USER_PROFILE_FILE" << PROFILE
name: ${user_name}
email: ${user_email}
role: ${user_role}
company: ${user_company}
setup_date: $(date +%Y-%m-%d)
PROFILE

ok "保存しました: ${user_name} さん"
echo ""
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================================================
# ステップ 3: Slack 連携
# ============================================================================
echo -e "${BOLD}📌 ステップ 3/3: Slack 連携（オプション）${NC}"
echo ""
echo "  Slack と連携すると、Slack から Hermes に話しかけられます。"
echo "  あとで設定することもできます。"
echo ""
echo "    [1] 今はスキップ ← おすすめ（まずターミナルで慣れよう）"
echo "    [2] 設定する（Bot Token が手元にある場合）"
echo ""

echo -n "  番号を入力 > "
read -r slack_choice

if [[ "$slack_choice" == "2" ]]; then
    echo ""
    echo "  Slack Bot User OAuth Token を貼り付けてください。"
    echo -e "  ${DIM}（xoxb- で始まります）${NC}"
    echo ""
    echo -n "  Token > "
    read -rs slack_token
    echo ""

    if [[ "$slack_token" == xoxb-* ]]; then
        set_env "SLACK_BOT_TOKEN" "$slack_token"
        ok "Slack Token 保存完了"

        echo ""
        echo -n "  Slack App Token も入力しますか？（xapp- で始まる、なくてもOK）[y/N] > "
        read -r app_token_choice
        if [[ "$app_token_choice" =~ ^[yY]$ ]]; then
            echo -n "  App Token > "
            read -rs slack_app_token
            echo ""
            if [[ -n "$slack_app_token" ]]; then
                set_env "SLACK_APP_TOKEN" "$slack_app_token"
                ok "App Token 保存完了"
            fi
        fi
    else
        warn "xoxb- で始まるトークンを入力してください。あとで設定できます。"
    fi
else
    ok "Slack はあとで設定できます（hermes setup で）"
fi

# ============================================================================
# 初回 memory 設定（Hermes に自己紹介させる）
# ============================================================================
info "Hermes にあなたのことを教えています..."

# user memory の初期設定を .hermes/user_memory.md に書く
MEMORY_FILE="$HERMES_DIR/user_memory_seed.txt"
cat > "$MEMORY_FILE" << SEED
${user_name} — ${user_role} at ${user_company}. Email: ${user_email}.
Hermes 初心者。ターミナル未経験。日本語で丁寧に説明すること。
コマンドを提示するときは「コピペして実行してください」と添える。
エラーが出たら原因と対処法をわかりやすく教える。
SEED
ok "完了"

# ============================================================================
# 完了！
# ============================================================================
echo ""
echo ""
cat << 'DONE'
  ╔══════════════════════════════════════════╗
  ║                                          ║
  ║   🎉 設定完了！                           ║
  ║                                          ║
  ║   Hermes を使う準備ができました。         ║
  ║   次はチュートリアルで基本を学びましょう。 ║
  ║                                          ║
  ╚══════════════════════════════════════════╝

DONE

echo "  チュートリアルに進みますか？（5〜10分で終わります）"
echo ""
echo "    [1] はい ← おすすめ"
echo "    [2] あとでやる"
echo ""
echo -n "  番号を入力 > "
read -r tutorial_choice

if [[ "$tutorial_choice" != "2" ]]; then
    if [[ -x "$ONBOARD_DIR/tutorial.sh" ]]; then
        exec bash "$ONBOARD_DIR/tutorial.sh"
    else
        echo ""
        echo "  チュートリアルを開始するには:"
        echo "    bash ~/.hermes/onboarding/tutorial.sh"
        echo ""
    fi
else
    echo ""
    echo "  いつでもチュートリアルを始められます:"
    echo "    bash ~/.hermes/onboarding/tutorial.sh"
    echo ""
    echo "  Hermes を起動するには:"
    echo "    hermes"
    echo ""
fi

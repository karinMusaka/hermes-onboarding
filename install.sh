#!/bin/bash
# ============================================================================
# Hermes オンボーディング インストーラー
# ============================================================================
# ワンライナー:
#   curl -sL https://raw.githubusercontent.com/karinMusaka/hermes-onboarding/main/install.sh | bash
#
# ターミナル未経験者向け。全て自動でインストールし、
# 設定ウィザード → チュートリアルへ誘導する。
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

# ── ユーティリティ ──
info()  { echo -e "${CYAN}→${NC} $1"; }
ok()    { echo -e "${GREEN}✅${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠️${NC}  $1"; }
fail()  { echo -e "${RED}❌${NC} $1"; exit 1; }
pause() { echo ""; echo -e "${DIM}  Enterキーを押してください...${NC}"; read -r; }

# ── macOS チェック ──
if [[ "$(uname)" != "Darwin" ]]; then
    fail "このスクリプトは macOS 専用です"
fi

# ============================================================================
clear
cat << 'BANNER'

  ╔══════════════════════════════════════════╗
  ║                                          ║
  ║   🚀 Hermes セットアップ                 ║
  ║   ターミナル AI アシスタント              ║
  ║                                          ║
  ╚══════════════════════════════════════════╝

BANNER

echo -e "  こんにちは！これから ${BOLD}Hermes${NC} をインストールします。"
echo -e "  全部自動でやるので、少しだけ待っていてください ☕"
echo ""
echo -e "  ${DIM}※ パスワードを聞かれたら Mac のログインパスワードを入力してください${NC}"
echo ""
pause

# ============================================================================
# [1/6] Xcode Command Line Tools
# ============================================================================
echo ""
echo -e "${BOLD}[1/6] 開発ツールを確認中...${NC}"

if xcode-select -p &>/dev/null; then
    ok "開発ツール OK"
else
    info "開発ツールをインストールします（数分かかります）"
    xcode-select --install 2>/dev/null || true
    # Wait for installation
    echo -e "${DIM}  インストールのダイアログが出たら「インストール」を押してください${NC}"
    echo -e "${DIM}  完了したら Enter を押してください${NC}"
    read -r
    if ! xcode-select -p &>/dev/null; then
        fail "開発ツールのインストールに失敗しました。もう一度試してください。"
    fi
    ok "開発ツール インストール完了"
fi

# ============================================================================
# [2/6] Homebrew
# ============================================================================
echo ""
echo -e "${BOLD}[2/6] Homebrew を確認中...${NC}"

if command -v brew &>/dev/null; then
    ok "Homebrew 見つかりました"
else
    info "Homebrew をインストールします..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Apple Silicon の PATH 設定
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        # .zprofile に追加
        if ! grep -q 'homebrew' ~/.zprofile 2>/dev/null; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        fi
    fi

    if command -v brew &>/dev/null; then
        ok "Homebrew インストール完了"
    else
        fail "Homebrew のインストールに失敗しました"
    fi
fi

# ============================================================================
# [3/6] Python + uv
# ============================================================================
echo ""
echo -e "${BOLD}[3/6] Python を準備中...${NC}"

# uv のインストール
if command -v uv &>/dev/null; then
    ok "uv 見つかりました"
elif [[ -x "$HOME/.local/bin/uv" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    ok "uv 見つかりました"
else
    info "uv をインストールします..."
    curl -LsSf https://astral.sh/uv/install.sh | sh 2>/dev/null
    export PATH="$HOME/.local/bin:$PATH"
    if command -v uv &>/dev/null; then
        ok "uv インストール完了"
    else
        fail "uv のインストールに失敗しました"
    fi
fi

# Python 3.11
UV_CMD="$(command -v uv)"
if $UV_CMD python find 3.11 &>/dev/null; then
    ok "Python 3.11 OK"
else
    info "Python 3.11 をインストール中..."
    $UV_CMD python install 3.11
    ok "Python 3.11 インストール完了"
fi

# ============================================================================
# [4/6] 追加ツール (ripgrep, git)
# ============================================================================
echo ""
echo -e "${BOLD}[4/6] 便利ツールを確認中...${NC}"

if command -v rg &>/dev/null; then
    ok "ripgrep OK"
else
    info "ripgrep をインストール中..."
    brew install ripgrep 2>/dev/null && ok "ripgrep インストール完了" || warn "ripgrep スキップ（後でも大丈夫）"
fi

if command -v git &>/dev/null; then
    ok "git OK"
else
    info "git をインストール中..."
    brew install git && ok "git インストール完了"
fi

# ============================================================================
# [5/6] Hermes 本体
# ============================================================================
echo ""
echo -e "${BOLD}[5/6] Hermes をダウンロード中...${NC}"

HERMES_DIR="$HOME/.hermes/hermes-agent"

if [[ -d "$HERMES_DIR/.git" ]]; then
    info "既存の Hermes を更新中..."
    cd "$HERMES_DIR"
    git pull --ff-only 2>/dev/null || warn "更新スキップ（ローカル変更あり）"
else
    info "Hermes をダウンロード中（30秒くらいかかります）..."
    mkdir -p "$HOME/.hermes"
    git clone https://github.com/hermes-ai/hermes-agent.git "$HERMES_DIR" 2>/dev/null || \
        fail "Hermes のダウンロードに失敗しました。ネットワークを確認してください。"
    ok "ダウンロード完了"
fi

# ============================================================================
# [5.5/6] Hermes セットアップ
# ============================================================================
info "Hermes をセットアップ中..."
cd "$HERMES_DIR"

# setup-hermes.sh の自動部分だけ実行（wizard は後で独自のを使う）
export VIRTUAL_ENV="$HERMES_DIR/venv"

if [[ -d "venv" ]]; then
    info "既存の venv を使用"
else
    $UV_CMD venv venv --python 3.11
fi

# 依存パッケージ
if [[ -f "uv.lock" ]]; then
    UV_PROJECT_ENVIRONMENT="$HERMES_DIR/venv" $UV_CMD sync --all-extras --locked 2>/dev/null || \
        $UV_CMD pip install -e ".[all]" 2>/dev/null || \
        $UV_CMD pip install -e "." 2>/dev/null
else
    $UV_CMD pip install -e ".[all]" 2>/dev/null || \
        $UV_CMD pip install -e "." 2>/dev/null
fi
ok "依存パッケージ インストール完了"

# CLI コマンド設置
mkdir -p "$HOME/.local/bin"
ln -sf "$HERMES_DIR/venv/bin/hermes" "$HOME/.local/bin/hermes"

# PATH 設定
SHELL_RC="$HOME/.zshrc"
[[ ! -f "$SHELL_RC" ]] && touch "$SHELL_RC"
if ! grep -q '\.local/bin' "$SHELL_RC" 2>/dev/null; then
    echo '' >> "$SHELL_RC"
    echo '# Hermes — CLI AI アシスタント' >> "$SHELL_RC"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
fi
export PATH="$HOME/.local/bin:$PATH"

# スキル同期
if [[ -f "$HERMES_DIR/tools/skills_sync.py" ]]; then
    "$HERMES_DIR/venv/bin/python" "$HERMES_DIR/tools/skills_sync.py" 2>/dev/null || true
fi

ok "Hermes コマンド準備完了"

# ============================================================================
# [6/6] オンボーディングスクリプト取得
# ============================================================================
echo ""
echo -e "${BOLD}[6/6] チュートリアルを準備中...${NC}"

ONBOARD_DIR="$HOME/.hermes/onboarding"
if [[ -d "$ONBOARD_DIR/.git" ]]; then
    cd "$ONBOARD_DIR" && git pull --ff-only 2>/dev/null || true
else
    git clone https://github.com/karinMusaka/hermes-onboarding.git "$ONBOARD_DIR" 2>/dev/null || {
        # フォールバック: スクリプトを直接ダウンロード
        mkdir -p "$ONBOARD_DIR"
        for f in wizard.sh tutorial.sh; do
            curl -sL "https://raw.githubusercontent.com/karinMusaka/hermes-onboarding/main/$f" \
                -o "$ONBOARD_DIR/$f" 2>/dev/null || true
        done
    }
fi
chmod +x "$ONBOARD_DIR"/*.sh 2>/dev/null || true

ok "チュートリアル準備完了"

# ============================================================================
# 完了！
# ============================================================================
echo ""
echo ""
cat << 'DONE'
  ╔══════════════════════════════════════════╗
  ║                                          ║
  ║   ✅ インストール完了！                   ║
  ║                                          ║
  ║   次は初期設定をします。                  ║
  ║   質問に答えるだけなので簡単です。        ║
  ║                                          ║
  ╚══════════════════════════════════════════╝

DONE

pause

# ウィザードを起動
if [[ -x "$ONBOARD_DIR/wizard.sh" ]]; then
    exec bash "$ONBOARD_DIR/wizard.sh"
else
    echo ""
    echo "  次のステップ:"
    echo "    hermes setup    ← 初期設定"
    echo "    hermes          ← チャット開始"
    echo ""
fi

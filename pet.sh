#!/bin/bash
# 青いネコロボットペット - コントロールスクリプト
#
# 使い方:
#   ./pet.sh show     - ペットを表示
#   ./pet.sh hide     - ペットを非表示
#   ./pet.sh toggle   - 表示/非表示を切替
#   ./pet.sh say      - ペットに話す（必須）
#   ./pet.sh state    - 状態を確認
#   ./pet.sh move dx dy - 移動（ピクセル単位）
#   ./pet.sh quit     - ペットを終了
#   ./pet.sh start    - Electron を起動
#   ./pet.sh help     - このヘルプ

PORT=17321
HOST=127.0.0.0.0
BASE_URL="http://${HOST}:${PORT}"

# Electron のパス
ELECTRON_BIN="./node_modules/.bin/electron"
if [ ! -f "$ELECTRON_BIN" ]; then
  ELECTRON_BIN="$(which electron)"
fi

# API を呼び出すヘルパ関数
api_call() {
  local url="$BASE_URL$1"
  local method="${2:-GET}"
  
  # API が反応しない場合、Electron を自動起動
  if ! curl -s --max-time 2 "$url" > /dev/null 2>&1; then
    echo "Electron not running. Starting pet robot..."
    if [ -f "$ELECTRON_BIN" ]; then
      cd "$(dirname "$0")" && $ELECTRON_BIN . &
      sleep 3
    else
      echo "Error: Electron not installed. Run 'npm install' first."
      return 1
    fi
  fi
  
  curl -s -X "$method" "$url"
}

# コマンド
case "${1:-help}" in
  show)
    api_call "/show"
    ;;
  hide)
    api_call "/hide"
    ;;
  toggle)
    api_call "/toggle"
    ;;
  say)
    text="${2:-にゃ〜}"
    api_call "/say?text=$(echo "$text" | sed 's/ /%20/g')"
    ;;
  state)
    api_call "/state"
    ;;
  move)
    dx="${2:-0}"
    dy="${3:-0}"
    api_call "/move?dx=${dx}&dy=${dy}"
    ;;
  quit)
    api_call "/quit"
    ;;
  start)
    if [ -f "$ELECTRON_BIN" ]; then
      cd "$(dirname "$0")" && $ELECTRON_BIN . &
      sleep 2
      api_call "/state"
    else
      echo "Electron not installed. Run 'npm install' first."
      exit 1
    fi
    ;;
  help)
    echo "青いネコロボットペット - コントロールスクリプト"
    echo ""
    echo "使い方:"
    echo "  ./pet.sh show     - ペットを表示"
    echo "  ./pet.sh hide     - ペットを非表示"
    echo "  ./pet.sh toggle   - 表示/非表示を切替"
    echo "  ./pet.sh say      - ペットに話す（テキスト付き）"
    echo "  ./pet.sh state    - 状態を確認"
    echo "  ./pet.sh move dx dy - 移動（ピクセル単位）"
    echo "  ./pet.sh quit     - ペットを終了"
    echo "  ./pet.sh start    - Electron を起動"
    echo "  ./pet.sh help     - このヘルプ"
    ;;
  *)
    echo "Unknown command: $1"
    echo "Run './pet.sh help' for usage."
    exit 1
    ;;
esac

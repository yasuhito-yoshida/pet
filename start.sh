#!/bin/bash
# 青いネコロボットペット - 起動スクリプト
cd "$(dirname "$0")"
echo "Starting pet robot..."
./node_modules/.bin/electron . &
sleep 2
echo "Pet robot is ready! Use the commands below to control it:"
echo "  ./pet.sh show    - 表示"
echo "  ./pet.sh hide    - 非表示"
echo "  ./pet.sh toggle  - 表示/切替"
echo "  ./pet.sh say     - 話す（テキスト付き）"
echo "  ./pet.sh state   - 状態確認"
echo "  ./pet.sh move    - 移動"
echo "  ./pet.sh quit    - 終了"

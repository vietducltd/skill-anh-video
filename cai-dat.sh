#!/bin/sh
# Cai (hoac cap nhat) bo skill anh va video vao Claude tren macOS / Linux.
#   curl -fsSL https://raw.githubusercontent.com/vietducltd/skill-anh-video/main/cai-dat.sh | sh
# Luu y: phan lon script trong bo skill la PowerShell (viet cho Windows). Tren macOS can cai
# PowerShell 7 (pwsh); chen-chu.ps1, soi-chu.ps1 cua tao-anh-quang-cao chi chay tren Windows.
set -e
REPO="vietducltd/skill-anh-video"
DICH="${SKILL_ANH_VIDEO_DICH:-$HOME/.claude/skills}"
TAM=$(mktemp -d)
trap 'rm -rf "$TAM"' EXIT
echo "Dang tai bo skill tu github.com/$REPO ..."
curl -fsSL "https://github.com/$REPO/archive/refs/heads/main.tar.gz" | tar -xz -C "$TAM"
mkdir -p "$DICH"
for s in "$TAM"/*/skills/*/; do
  n=$(basename "$s")
  mkdir -p "$DICH/$n"
  cp -R "$s". "$DICH/$n/"
  echo "  + $n"
done
echo "Da cai vao $DICH. Mo phien Claude moi de dung."

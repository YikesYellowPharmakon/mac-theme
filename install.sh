#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT/bin/lib.sh"

echo "==> mac-theme 安装（不关闭 SIP）"

if ! command -v brew >/dev/null 2>&1; then
  echo "需要 Homebrew：https://brew.sh" >&2
  exit 1
fi

echo "==> Homebrew 依赖"
brew tap FelixKratz/formulae
brew tap nikitabobko/tap
brew bundle --file="$ROOT/Brewfile"

echo "==> 编译强调色通知助手"
if command -v swiftc >/dev/null 2>&1; then
  if ! swiftc -O "$ROOT/bin/notify-colors.swift" -o "$ROOT/bin/notify-colors" 2>/tmp/mac-theme-swiftc.log; then
    echo "swiftc 编译失败，强调色会写入，部分 App 可能要重开才刷新。"
  fi
else
  echo "未找到 swiftc，主题切换后部分 App 可能要重开才更新强调色。"
fi

echo "==> 同步 Omarchy 色板"
"$ROOT/bin/sync-themes.sh"

echo "==> 链接配置"
mkdir -p "$LOCAL_BIN" \
  "$CONFIG_DIR/aerospace" \
  "$CONFIG_DIR/sketchybar/plugins" \
  "$CONFIG_DIR/borders" \
  "$CONFIG_DIR/ghostty/themes"

ln -sfn "$ROOT/config/aerospace.toml" "$HOME/.aerospace.toml"
ln -sfn "$ROOT/config/sketchybar/sketchybarrc" "$CONFIG_DIR/sketchybar/sketchybarrc"
ln -sfn "$ROOT/config/sketchybar/plugins" "$CONFIG_DIR/sketchybar/plugins"
ln -sfn "$ROOT/config/sketchybar/colors.sh" "$CONFIG_DIR/sketchybar/colors.sh"
ln -sfn "$ROOT/config/sketchybar/icon_map.sh" "$CONFIG_DIR/sketchybar/icon_map.sh"
ln -sfn "$ROOT/config/borders/bordersrc" "$CONFIG_DIR/borders/bordersrc"
ln -sfn "$ROOT/config/ghostty/config" "$CONFIG_DIR/ghostty/config"
ln -sfn "$ROOT/bin/theme-set" "$LOCAL_BIN/theme-set"
ln -sfn "$ROOT/bin/theme-pick" "$LOCAL_BIN/theme-pick"

chmod +x "$ROOT/bin/"* "$ROOT/config/sketchybar/sketchybarrc" "$ROOT/config/sketchybar/plugins/"* "$ROOT/config/borders/bordersrc" "$ROOT/install.sh"

if ! grep -q '.local/bin' "$HOME/.zprofile" 2>/dev/null; then
  printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.zprofile"
fi
if [[ -f "$HOME/.zshrc" ]] && ! grep -q '.local/bin' "$HOME/.zshrc"; then
  printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.zshrc"
fi
export PATH="$LOCAL_BIN:$PATH"

echo "==> 卸掉数字雨（全屏动画会发热）"
"$ROOT/bin/rain-ctl" uninstall >/dev/null 2>&1 || true

echo "==> 系统外观 + tokyo-night"
"$ROOT/bin/apply-macos-chrome"
"$ROOT/bin/theme-set" tokyo-night

echo "==> 启动服务"
# SketchyBar / borders 由 AeroSpace after-startup 拉起，避免 brew services 再开一份。
brew services stop sketchybar >/dev/null 2>&1 || true
brew services stop borders >/dev/null 2>&1 || true
open -a AeroSpace >/dev/null 2>&1 || true
open -a Ice >/dev/null 2>&1 || true
open -a Raycast >/dev/null 2>&1 || true
# Enable built-in Clipboard History only. Do not store-install-all, do not open Window Management.
open "raycast://extensions/raycast/clipboard-history/clipboard-history" >/dev/null 2>&1 || true

cat <<'EOF'

安装完成。默认主题：tokyo-night

快捷键
  Option-Shift-T   弹出主题列表
  Option-Shift-N   下一个主题
  Option-Shift-P   上一个主题
  Option-Shift-W   下一张壁纸
  Option-1-9       工作区
  Option-HJKL      聚焦窗口
  Option-Enter     打开 Ghostty
  Option-Space     打开 Raycast

Raycast：只当启动器 + Clipboard History。不要点 Store「全部安装」，不要开 Window Management（和 AeroSpace 冲突），不要开 Pro / AI。

第一次用需要在「系统设置 → 隐私与安全性 → 辅助功能」里打开：
  AeroSpace、borders，以及（换壁纸时）osascript / 终端

菜单栏已被隐藏，顶栏是 SketchyBar。Ice 已安装，用来收拾偶尔露出来的原生图标。
EOF

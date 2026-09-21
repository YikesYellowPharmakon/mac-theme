# mac-theme

不关 SIP。系统外观（A）+ AeroSpace / SketchyBar / JankyBorders / Ghostty（B），一份 `colors.toml` 全局换色。

默认主题：**tokyo-night**。没有桌面数字雨，也不再带 Into the Matrix。

## 安装

```bash
cd ~/Projects/mac-theme
./install.sh
```

第一次用，到 **系统设置 → 隐私与安全性 → 辅助功能**，打开：

- AeroSpace（平铺和主题快捷键）
- borders（窗口描边）

换壁纸如果弹权限，允许「终端」或「osascript」控制「系统事件」。

## 命令与快捷键

```bash
theme-set tokyo-night
theme-pick
theme-set --next
theme-set --prev
theme-set --wallpaper
theme-set --list
```

| 快捷键 | 作用 |
|---|---|
| Option-Shift-T | 弹出主题列表 |
| Option-Shift-N | 下一个主题 |
| Option-Shift-P | 上一个主题 |
| Option-Shift-W | 下一张壁纸 |
| Option-1…9 | 工作区 |
| Option-H / J / K / L | 聚焦窗口 |
| Option-Shift-HJKL | 移动窗口 |
| Option-Enter | Ghostty |
| Option-Space | Raycast |
| Option-F | 全屏 |
| Option-T | 浮动 / 平铺 |

Ghostty 换色后开新窗口，或按 Command-Shift-Comma 重载配置。

## 主题

Omarchy 官方色板：

`hackerman` `tokyo-night` `catppuccin` `catppuccin-latte` `osaka-jade` `gruvbox` `nord` `everforest` `kanagawa` `matte-black` `rose-pine` `ethereal` `flexoki-light` `last-horizon` `lumon` `lupine` `miasma` `retro-82` `ristretto` `solitude` `vantablack` `white`

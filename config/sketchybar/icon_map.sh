#!/bin/bash
__icon_map() {
  case "$1" in
    "Ghostty"|"Terminal"|"iTerm2"|"Alacritty"|"Kitty"|"Warp") icon_result="" ;;
    "Safari"|"Google Chrome"|"Chromium"|"Arc"|"Firefox"|"Brave Browser"|"Microsoft Edge") icon_result="" ;;
    "Finder") icon_result="" ;;
    "Cursor"|"Code"|"Visual Studio Code"|"Zed") icon_result="" ;;
    "Mail"|"Spark") icon_result="" ;;
    "Messages") icon_result="" ;;
    "Music"|"Spotify") icon_result="" ;;
    "Notes") icon_result="" ;;
    "Preview") icon_result="" ;;
    "System Settings"|"System Preferences") icon_result="" ;;
    "Slack"|"Discord") icon_result="" ;;
    "WeChat"|"Telegram"|"Signal") icon_result="" ;;
    "Xcode") icon_result="" ;;
    *) icon_result="" ;;
  esac
}

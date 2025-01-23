#!/usr/bin/env bash

test -f letscheck.dmg && rm letscheck.dmg
create-dmg \
  --volname "Letscheck Installer" \
  --volicon "./assets/letscheck_installer.icns" \
  --background "./assets/dmg_background.png" \
  --window-pos 200 120 \
  --window-size 800 530 \
  --icon-size 130 \
  --text-size 14 \
  --icon "Letscheck.app" 260 250 \
  --hide-extension "Letscheck.app" \
  --app-drop-link 540 250 \
  --hdiutil-quiet \
  "build/macos/Build/Products/Release/Letscheck.dmg" \
  "build/macos/Build/Products/Release/Letscheck.app"
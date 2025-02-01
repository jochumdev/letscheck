#!/usr/bin/env bash

# Thanks goes to: https://github.com/Merrit/flutter_flatpak_example

set -e # Exit if any command fails
set -x # Echo all commands for debug purposes


# No spaces in project name.
projectName=LetsCheck
projectId=io.github.jochumdev.letscheck
executableName=letscheck

mkdir "/app" && chown -R $(id -u -n): "/app"

# Copy the portable app to the Flatpak-based location.
cp -r ./build/linux/x64/release/bundle /app/${projectName}
chmod +x /app/${projectName}/${executableName}
mkdir -p /app/bin
ln -s /app/${projectName}/${executableName} /app/bin/${executableName}

# Install the icon.
iconDir=/app/share/icons/hicolor/scalable/apps
mkdir -p ${iconDir}
install -Dm644 ./assets/icons/${projectName}.svg ${iconDir}/${projectId}.svg
install -Dm644 ./assets/icons/${executableName}.png /app/share/icons/hicolor/16x16/apps/${executableName}.png

# Install the desktop file.
desktopFileDir=/app/share/applications
mkdir -p ${desktopFileDir}
install -Dm644 ./flathub/${projectId}.desktop ${desktopFileDir}/

# Install the AppStream metadata file.
metadataDir=/app/share/metainfo
mkdir -p ${metadataDir}
install -Dm644 ./flathub/${projectId}.metainfo.xml ${metadataDir}/


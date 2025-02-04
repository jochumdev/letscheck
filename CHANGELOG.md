# LetsCheck
## Unreleased
### Added
- Add notifications info on android to the README
- set default refresh time to 60 seconds

## 0.0.15+1265 - 2025-02-03
### Added
- update README
- add web.zip to release

### Fixed
- slow dart analyzes
- smaller fixes
- issue #14, reconnect when connection is lost

## 0.0.14+1264 - 2025-02-01
### Fixed
- add base href to web/index.html, pt2

## 0.0.13+1263 - 2025-02-01
### Fixed
- add base href to web/index.html

## 0.0.12+1262 - 2025-02-01
### Added
- github pages pwa

## 0.0.11+1261 - 2025-02-01
### Added
- allow multiple search terms seperated by a pipe, refs issue #8
- rework settings ui
- work on filters, redesign ui to users copy texts
- rename dev.jochum.letscheck -> io.github.jochumdev.letscheck
- move around flatpak files to improve the buildprocess

### Fixed
- don't monitor state 0 host/svc

## 0.0.10+1260 - 2025-02-01
### Added
- add development docs to the README

### Fixed
- appindicator3 as system library for linux builds
- github workflows, update upload-release-action to fix upload error
- linux flatpak, disable artifact upload
- missing library on flatpak, fixes issue #10
- flatpak appindicator icon, fixes issue #11

## 0.0.7+1230 - 2025-01-30
### Added
- google\_fonts and LicenseManager
- Release Workflow for Github
- Dependabot
- android apk builds on release
- a background service for notifications on android/ios
- SiteStats widget to all screens
- v2 logo

### Changed
- relicense MIT to Apache 2.0
- enabled flutter\_intl

### Fixed
- linux builds missing libquickjs
- flatpak builds
- use the right container for flatbak builds
- issue #2, self update home screen
- notifications on windows
- config/settings on flatpak

## 0.0.5+1225 - 2025-01-23

# LetsCheck
## Unreleased
### Added
- allow multiple search terms seperated by a pipe, refs issue #8
- rework settings ui
- work on filters, redesign ui to users copy texts
- rename dev.jochum.letscheck -&gt; io.github.jochumdev.letscheck

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

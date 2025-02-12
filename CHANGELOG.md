# LetsCheck
## Unreleased
### Fixed
- always use the last fetch data in background\_service
- move lib/javascript -&gt; lib/platform\_interfaces/javascript

## 0.2.1+1273 - 2025-02-12
### Added
- rework connection handling
- rework connection handling, pt2
- intodruce talker, rework connection handling, pt3
- rework connection handling, pt4
- little work on the theme.
- improve themeing, add floating action button
- use a FutureProvider for the client

### Fixed
- smaller fixes

## 0.2.0+1272 - 2025-02-08
### Added
- upgrade check\_mk\_api, it's now using final classes
- Replaced flutter\_bloc with flutter\_riverpod, its a rewrite of the whole app.
closes issue #17: Change Settings->Refresh Seconds to an number input Dialog
closes issue #19: Hide password
closes issue #20: Allow users to limit a connection on WIFI

## 0.1.4+1270 - 2025-02-05
### Added
- upgrade flutter 3.27.1 -> 3.27.3
- redirect home screen to add connection when theres no connection yet
- replace howmegrown router with go\_router
- linux-arm64 builder
- automatic releases on tag

### Fixed
- an unknown number of redirects after implementing redirects
- github workflow
- redirect to homepage when a connection has been successfuly saved
- typo in workflow
- macosx curl error

## 0.1.3+1269 - 2025-02-05
### Added
- replace all screens with StateFull ones, closes #18
- add arm64 builder, pt1

### Fixed
- run notifications once on load
- use systemlocale

## 0.1.2+1268 - 2025-02-05
### Added
- fix to portrait mode

### Fixed
- move the README FAQ to the WIKI
- reconnection issues when loosing internet, fixes issue #15
- its Checkmk not ChecMk

## 0.1.1+1267 - 2025-02-04
### Fixed
- README, no need for lql-api
- notifications when the timestamp is under a minute

## 0.1.0+1266 - 2025-02-04
### Added
- Add notifications info on android to the README
- set default refresh time to 60 seconds
- use views.py instead of lql-api for notifications

### Fixed
- flatpak notification icon
- always query all connections, don't test them in front

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

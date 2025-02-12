[![Tag build](https://github.com/jochumdev/letscheck/actions/workflows/tag.yml/badge.svg)](https://github.com/jochumdev/letscheck/actions/workflows/tag.yml)

# LetsCheck

LetsCheck is a Checkmk client for Android, iOS, Linux, Mac OS-X and Windows written with the [Flutter SDK](https://flutter.dev/).

[Checkmk](https://checkmk.com/) is a leading tool for Infrastructure and Application Monitoring. Simple configuration, scalable, flexible. Open Source and Enterprise.

## Features

- View Hosts/Services with comments
- Notifications
- Search Hosts/Services, use the | symbol to seperated multiple searches

## Intodruction and new release notes

See the [Checkmk forums](https://forum.checkmk.com/t/letscheck-a-checkmk-client-with-notifications-for-mobile-and-desktop/52088)

## Download

Get it from [Github Releases](https://github.com/jochumdev/letscheck/releases)

## Demo:

![image](docs/videos/letscheck_v0.0.1-rc1.webp)

## FAQ

The “Frequently asked questions” page is available on the [Github WIKI](https://github.com/jochumdev/letscheck/wiki/FAQ).

## Development

**Commit**:

```
git add ./file1 ./file2
./scripts/commit_fix.sh "a bug in component x"
```

**Release**:

- Create changelog, tag and push it
  ```
  ./scripts/release.sh "0.0.99+9763"
  ```
- Create a release on Github
- Wait for Github Actions to publish binaries

## Authors

- [@jochumdev](https://github.com/jochumdev)

## License

Apache 2.0 - Copyright 2025 by [@jochumdev](https://github.com/jochumdev)

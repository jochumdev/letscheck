# Let's Check

Let's check is a CheckMk client for Android, iOS, Linux, Mac OS-X and Windows written with the [Flutter SDK](https://flutter.dev/).

## Download

Get it from [Github Releases](https://github.com/jochumdev/letscheck/releases)

## Demo:

![image](docs/videos/letscheck_v0.0.1-rc1.webp)

## Preview:

[Available as PWA](https://jochumdev.github.io/letscheck/pwa/) **important** you need proper CORS Headers on you'r CheckMk proxy for a connection to work.

## FAQ

### Is lql-api required for this to work?

No, "only" for notifications you need lql-api installed on the checkmk server.

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

Apache 2.0 - Copyright 2024 by [@jochumdev](https://github.com/jochumdev)

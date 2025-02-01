#!/usr/bin/env bash

~/.pub-cache/bin/cider version "$1"
~/.pub-cache/bin/cider release "$1"
git add pubspec.lock
git add pubspec.yaml
git add CHANGELOG.md
git commit -S -m "Version $1"
git push
git tag $1
git push --tags

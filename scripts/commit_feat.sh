#!/usr/bin/env bash

~/.pub-cache/bin/cider log added "$1"
git add CHANGELOG.md
git commit -S -m "feat: $1"
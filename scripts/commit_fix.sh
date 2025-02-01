#!/usr/bin/env bash

~/.pub-cache/bin/cider log fixed "$1"
git add CHANGELOG.md
git commit -S -m "fix: $1"
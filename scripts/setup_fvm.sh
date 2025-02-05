#!/bin/bash                      
set -ex;               

FVM_VERSION="3.2.1"

check_command() {
	command -v "$1" >/dev/null 2>&1
}

# Function to log messages with date and time
error() {
    echo -e "$1"
    exit 1
}

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

# Map to FVM naming
case "$OS" in
  Linux*)  OS='linux' ;;
  Darwin*) OS='macos' ;;
  *)       error "Unsupported OS" ;;
esac

case "$ARCH" in
  x86_64)  ARCH='x64' ;;
  arm64)   ARCH='arm64' ;;
  armv7l)  ARCH='arm' ;;
  aarch64) ARCH='arm64' ;;
  *)       error "Unsupported architecture" ;;
esac

if ! check_command curl; then
    error "curl not found"
fi

if ! check_command jq; then
    error "jq not found"
fi

if ! check_command git; then
    error "git not found"
fi

# Download fvm
if [[ ! -x ~/.fvm_flutter/bin/fvm ]]; then
        tar_out="/tmp/fvm.tar.gz"
        fvm_url=$(curl -sSf https://api.github.com/repos/leoafarias/fvm/releases/latest | jq -r '.assets[] | select((.version = "'${FVM_VERSION}'") and (.name | contains ("'${OS}'-'${ARCH}'.tar.gz"))) | .browser_download_url')
        curl -sSLf "${fvm_url}" -o "${tar_out}"

        tmp_dir=$(mktemp -d)
        tar xf "${tar_out}" -C ${tmp_dir}
        rm -f "${tar_out}"

        [[ ! -d ~/.fvm_flutter ]] && mkdir -p ~/.fvm_flutter
        mv ${tmp_dir}/fvm ~/.fvm_flutter/bin
        rm -rf "${tmp_dir}"
fi

echo -e "yes\nyes\n" | $HOME/.fvm_flutter/bin/fvm install

# Invoke Flutter SDK to suppress the analytics
$HOME/.fvm_flutter/bin/fvm flutter --version --suppress-analytics 2>&1 >/dev/null

# Disable Google Analytics and CLI animations 
$HOME/.fvm_flutter/bin/fvm flutter config --no-analytics 2>&1 >/dev/null
$HOME/.fvm_flutter/bin/fvm flutter config --no-cli-animations 2>&1 >/dev/null

# Show versions
$HOME/.fvm_flutter/bin/fvm flutter doctor

# Allow future usages of "fvm" without the full path
echo "$HOME/.fvm_flutter/bin" >>"${GITHUB_PATH:-/dev/null}"
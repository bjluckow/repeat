#!/usr/bin/env bash
set -euo pipefail

REPO="shaankhosla/repeat"
APP="repeat"
INSTALL_DIR="/usr/local/bin"

# Determine platform and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64) ARCH="x86_64" ;;
    arm64|aarch64) ARCH="aarch64" ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

case "$OS" in
    linux) TARGET="${ARCH}-unknown-linux-gnu" ;;
    darwin) TARGET="${ARCH}-apple-darwin" ;;
    msys*|cygwin*|mingw*) TARGET="${ARCH}-pc-windows-msvc" ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

TAG=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
if [ -z "$TAG" ]; then
    echo "Could not determine latest release"
    exit 1
fi

# Build URLs
BASENAME="${APP}-${TAG}-${TARGET}"
ARCHIVE="${BASENAME}.tar.gz"
CHECKSUM="${ARCHIVE}.sha256"
URL="https://github.com/${REPO}/releases/download/${TAG}/${ARCHIVE}"
CHECKSUM_URL="https://github.com/${REPO}/releases/download/${TAG}/${CHECKSUM}"

# Download files
TMPDIR=$(mktemp -d)
cd "$TMPDIR"

echo "Downloading $URL..."
curl -LO "$URL"
curl -LO "$CHECKSUM_URL"

# Verify checksum
echo "Verifying checksum..."
sha256sum -c "${CHECKSUM}" || {
    echo "Checksum verification failed!"
    exit 1
}

# Extract and install
echo "Extracting..."
tar -xzf "$ARCHIVE"

echo "Installing to ${INSTALL_DIR} (may require sudo)..."
sudo install -m 755 "$APP" "$INSTALL_DIR/"

echo "Installed ${APP} successfully to ${INSTALL_DIR}/${APP}"

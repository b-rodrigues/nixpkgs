#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

LATEST_VERSION=$(curl -sL "https://registry.npmjs.org/cline/latest" | jq -r '.version')

echo "Updating cline to $LATEST_VERSION..."

LINUX_X64_HASH=$(curl -sL "https://registry.npmjs.org/@cline/cli-linux-x64/$LATEST_VERSION" | jq -r '.dist.integrity')
LINUX_ARM64_HASH=$(curl -sL "https://registry.npmjs.org/@cline/cli-linux-arm64/$LATEST_VERSION" | jq -r '.dist.integrity')
DARWIN_X64_HASH=$(curl -sL "https://registry.npmjs.org/@cline/cli-darwin-x64/$LATEST_VERSION" | jq -r '.dist.integrity')
DARWIN_ARM64_HASH=$(curl -sL "https://registry.npmjs.org/@cline/cli-darwin-arm64/$LATEST_VERSION" | jq -r '.dist.integrity')

jq -n \
  --arg version "$LATEST_VERSION" \
  --arg linux_x64 "$LINUX_X64_HASH" \
  --arg linux_arm64 "$LINUX_ARM64_HASH" \
  --arg darwin_x64 "$DARWIN_X64_HASH" \
  --arg darwin_arm64 "$DARWIN_ARM64_HASH" \
  '{
    version: $version,
    sources: {
      "x86_64-linux": {
        platform: "linux-x64",
        hash: $linux_x64
      },
      "aarch64-linux": {
        platform: "linux-arm64",
        hash: $linux_arm64
      },
      "x86_64-darwin": {
        platform: "darwin-x64",
        hash: $darwin_x64
      },
      "aarch64-darwin": {
        platform: "darwin-arm64",
        hash: $darwin_arm64
      }
    }
  }' > sources.json

echo "Updated sources.json successfully to $LATEST_VERSION"

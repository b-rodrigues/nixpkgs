#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix coreutils gnused

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

data=$(curl -sL https://registry.npmjs.org/freebuff/latest)
version=$(echo "$data" | jq -r .version)

sed -i 's/version = "[^"]*"/version = "'"$version"'"/' package.nix

for system in x86_64-linux aarch64-linux x86_64-darwin aarch64-darwin; do
  case "$system" in
    x86_64-linux) key="linux-x64" ;;
    aarch64-linux) key="linux-arm64" ;;
    x86_64-darwin) key="darwin-x64" ;;
    aarch64-darwin) key="darwin-arm64" ;;
  esac
  raw_hash=$(echo "$data" | jq -r ".binaryChecksums[\"$key\"]")
  sri_hash=$(nix-hash --type sha256 --to-sri "$raw_hash")
  sed -i "s#${system} = \"sha256-[^\"]*\"#${system} = \"${sri_hash}\"#" package.nix
done

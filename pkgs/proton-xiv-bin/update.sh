#!/usr/bin/env -S nix shell nixpkgs#npins nixpkgs#jq -c bash

REPO_OWNER="rankynbass"
REPO_NAME="proton-xiv"

# Get branch names
releases=$(curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases?per_page=10000" | grep -oP '(?<="name": ")[^"]+')

# Initialize variables
latest_major=0
latest_minor=0

# Find the latest version
for release in $releases; do
  if [[ $release =~ ^XIV-Proton([0-9]+)-([0-9]+)$ ]]; then
    major=${BASH_REMATCH[1]}
    minor=${BASH_REMATCH[2]}
    if (( major > latest_major )) || (( major == latest_major && minor > latest_minor )); then
      latest_major=$major
      latest_minor=$minor
      latest_release=$release
    fi
  fi
done

info="pkgs/proton-xiv-bin/info.json"
old_release=$(jq -r '.version' "$info")
url="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${latest_release}/${latest_release}.tar.xz"

if [ "$old_release" != "$latest_release" ]; then
  if output=$(nix store prefetch-file "$url" --json --unpack); then
    jq --arg version "$latest_release" '.version = $version' <<<"$output" >"$info"
  else
    echo "proton-xiv has a release without build artifacts"
  fi
else
  echo "proton-xiv is up to date"
fi

#!/usr/bin/env -S nix shell nixpkgs#npins nixpkgs#jq -c bash

REPO_OWNER="CachyOS"
REPO_NAME="proton-cachyos"

tags=$(curl -s "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases?per_page=10000" | grep -oP '(?<="tag_name": ")[^"]+')

latest_major=0
latest_minor=0
latest_date=0

for tag in $tags; do
  if [[ $tag =~ ^cachyos-([0-9]+)\.([0-9]+)-([0-9]+)-slr$ ]]; then
    major=${BASH_REMATCH[1]}
    minor=${BASH_REMATCH[2]}
    date_version=${BASH_REMATCH[3]}
    
    if (( major > latest_major )) || \
       (( major == latest_major && minor > latest_minor )) || \
       (( major == latest_major && minor == latest_minor && date_version > latest_date )); then
      latest_major=$major
      latest_minor=$minor
      latest_date=$date_version
      latest_tag=$tag
    fi
  fi
done

info="pkgs/proton-cachyos-bin/info.json"
old_tag=$(jq -r '.version' "$info")
url="https://github.com/CachyOS/proton-cachyos/releases/download/${latest_tag}/proton-${latest_tag}-x86_64_v3.tar.xz"

if [ "$old_tag" != "$latest_tag" ]; then
  if output=$(nix store prefetch-file "$url" --json --unpack); then
    jq --arg version "$latest_tag" '.version = $version' <<<"$output" >"$info"
  else
    echo "proton-cachyos has a release without build artifacts"
  fi
else
  echo "proton-cachyos is up to date"
fi

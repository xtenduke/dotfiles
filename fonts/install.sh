#!/bin/bash
set -e

# Installs JetBrainsMono Nerd Font (the patched build with powerline/devicon
# glyphs) into ~/.local/share/fonts. Needed by kitty, alacritty, ghostty and
# powerlevel10k, all of which name this family explicitly.
#
# Idempotent: skips the download if the family is already registered with
# fontconfig. Pass --force to reinstall.
#
# Pinned to a specific release + checksum rather than tracking "latest", so a
# fresh machine gets the same fonts this config was set up against. To bump:
# pick a tag from https://github.com/ryanoasis/nerd-fonts/releases and take the
# matching line out of that release's SHA-256.txt.

VERSION="v3.5.1"
FAMILY="JetBrainsMono Nerd Font"
ARCHIVE="JetBrainsMono.tar.xz"   # ~7MB; the .zip of the same fonts is ~134MB
SHA256="04d5e8f903693f9dd13e16f867e994834e681eb3c72c0d337a770dcda09010cf"
DEST="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
URL="https://github.com/ryanoasis/nerd-fonts/releases/download/$VERSION/$ARCHIVE"

if [ "$1" != "--force" ] && fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    echo "$FAMILY already installed (use --force to reinstall)"
    exit 0
fi

for tool in curl tar sha256sum fc-cache; do
    command -v "$tool" >/dev/null || { echo "Missing required tool: $tool" >&2; exit 1; }
done

echo "Installing $FAMILY $VERSION"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

curl -fL --retry 3 --progress-bar -o "$TMP/$ARCHIVE" "$URL"

echo "$SHA256  $TMP/$ARCHIVE" | sha256sum -c --quiet - || {
    echo "Checksum mismatch for $ARCHIVE - refusing to install" >&2
    exit 1
}

rm -rf "$DEST"
mkdir -p "$DEST"
tar -xJf "$TMP/$ARCHIVE" -C "$DEST" --wildcards '*.ttf'

fc-cache -f "$DEST" >/dev/null

if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    echo "Installed $(find "$DEST" -name '*.ttf' | wc -l) faces to $DEST"
else
    echo "Fonts unpacked to $DEST but fontconfig does not see them" >&2
    exit 1
fi

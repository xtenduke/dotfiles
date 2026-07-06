#!/bin/bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------------------------------------------------------------------------
# 1. Disable keyd if running (conflicts with Toshy)
# ---------------------------------------------------------------------------
if systemctl is-enabled --quiet keyd 2>/dev/null; then
    echo "Disabling keyd..."
    sudo systemctl disable --now keyd
fi

# ---------------------------------------------------------------------------
# 2. Install Toshy
# ---------------------------------------------------------------------------
if ! command -v toshy-services-restart &>/dev/null; then
    echo "Installing Toshy..."
    TOSHY_TMP=$(mktemp -d)
    git clone https://github.com/RedBearAK/toshy.git "$TOSHY_TMP"
    "$TOSHY_TMP/setup.py" install
    rm -rf "$TOSHY_TMP"
else
    echo "Toshy already installed, skipping."
fi

# ---------------------------------------------------------------------------
# 3. Install GNOME extensions required for Toshy window context on Wayland
# ---------------------------------------------------------------------------
EXTENSIONS_DIR="$HOME/.local/share/gnome-shell/extensions"
GNOME_VERSION=$(gnome-shell --version | grep -oP '\d+' | head -1)

install_extension() {
    local uuid="$1"
    local ext_id="$2"
    if [ -d "$EXTENSIONS_DIR/$uuid" ]; then
        echo "Extension $uuid already installed, skipping."
        return
    fi
    echo "Installing extension: $uuid..."
    local url="https://extensions.gnome.org/extension-data/${uuid//@/}.v$(
        curl -s "https://extensions.gnome.org/extension-info/?pk=${ext_id}&shell_version=${GNOME_VERSION}" \
        | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['shell_version_map']['${GNOME_VERSION}']['version'])" 2>/dev/null
    ).shell-extension.zip"
    local tmp=$(mktemp -d)
    curl -L -o "$tmp/ext.zip" "$url"
    mkdir -p "$EXTENSIONS_DIR/$uuid"
    unzip -q "$tmp/ext.zip" -d "$EXTENSIONS_DIR/$uuid"
    rm -rf "$tmp"
    gnome-extensions enable "$uuid" 2>/dev/null || true
}

# focused-window-dbus — provides window class to Toshy on GNOME Wayland
install_extension "focused-window-dbus@flexagoon.com" "5592"

# ---------------------------------------------------------------------------
# 4. Inject user_apps slice into Toshy config
# ---------------------------------------------------------------------------
TOSHY_CONFIG="$HOME/.config/toshy/toshy_config.py"
USER_APPS="$DIR/user_apps.py"
SLICE_START="###  SLICE_MARK_START: user_apps  ###"
SLICE_END="###  SLICE_MARK_END: user_apps  ###"

if [ ! -f "$TOSHY_CONFIG" ]; then
    echo "ERROR: Toshy config not found at $TOSHY_CONFIG"
    exit 1
fi

echo "Injecting user_apps slice into Toshy config..."

python3 - "$TOSHY_CONFIG" "$USER_APPS" "$SLICE_START" "$SLICE_END" <<'PYEOF'
import sys

config_path, user_apps_path, start_marker, end_marker = sys.argv[1:]

with open(config_path) as f:
    lines = f.readlines()

with open(user_apps_path) as f:
    user_apps_content = f.read()

out = []
inside = False
injected = False
for line in lines:
    if start_marker in line:
        out.append(line)
        out.append("\n")
        out.append(user_apps_content)
        out.append("\n")
        inside = True
        injected = True
        continue
    if end_marker in line:
        inside = False
    if not inside:
        out.append(line)

if not injected:
    print(f"ERROR: slice marker not found in {config_path}", file=sys.stderr)
    sys.exit(1)

with open(config_path, "w") as f:
    f.writelines(out)

print("Done.")
PYEOF

# ---------------------------------------------------------------------------
# 5. Restart Toshy
# ---------------------------------------------------------------------------
echo "Restarting Toshy..."
toshy-services-restart

echo ""
echo "Toshy setup complete."
echo "Log out and back in (or restart GNOME Shell) for extensions to take effect."

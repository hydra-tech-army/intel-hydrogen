#!/bin/bash

set -e

# === CONFIGURABLE VARIABLES ===
HYDROGEN_M_URL="https://0ai4bbbahf.ufs.sh/f/4fzhZqSSYIjmkWWMxFijXsk75A4zmbHYUciDGad6ul8oeE0f"
TMP_DIR="/tmp/hydrogen_m_install"
HYDROGEN_APP_PATH="/Applications/Hydrogen-M.app"
ROBLOX_PATH="/Applications/Roblox.app/Contents/MacOS"
ROBLOX_PLAYER="$ROBLOX_PATH/RobloxPlayer"
ROBLOX_PLAYER_COPY="$ROBLOX_PATH/RobloxPlayer.copy"

# === FUNCTIONS ===

error_exit() {
    echo "Error: $1"
    exit 1
}

info() {
    echo "[*] $1"
}

success() {
    echo "[✔] $1"
}

# === CHECKS ===

# 1. Check for existence of RobloxPlayer
if [ ! -f "$ROBLOX_PLAYER" ]; then
    error_exit "RobloxPlayer not found at $ROBLOX_PLAYER. Please install Roblox first."
fi


info "System and RobloxPlayer architecture are compatible (arm64)."

# 3. Download Hydrogen-M app
info "Downloading Hydrogen-M from $HYDROGEN_M_URL..."
mkdir -p "$TMP_DIR"
curl -L "$HYDROGEN_M_URL" -o "$TMP_DIR/Hydrogen-M.zip"
unzip -oq "$TMP_DIR/Hydrogen-M.zip" -d "$TMP_DIR"

info "Moving Hydrogen-M to /Applications..."
rm -rf "$HYDROGEN_APP_PATH"
mv "$TMP_DIR/Hydrogen-M.app" "$HYDROGEN_APP_PATH"

# 4. RobloxPlayer copy handling
if [ ! -f "$ROBLOX_PLAYER_COPY" ]; then
    info "Creating RobloxPlayer.copy..."
    cp "$ROBLOX_PLAYER" "$ROBLOX_PLAYER_COPY"
else
    info "Restoring original RobloxPlayer from copy..."
    rm -f "$ROBLOX_PLAYER"
    mv "$ROBLOX_PLAYER_COPY" "$ROBLOX_PLAYER"
    cp "$ROBLOX_PLAYER" "$ROBLOX_PLAYER_COPY"
fi

# 5. Inject dylib
info "Injecting Hydrogen-M dylib into RobloxPlayer..."
"$HYDROGEN_APP_PATH/Contents/MacOS/insert_dylib" \
    "$HYDROGEN_APP_PATH/Contents/MacOS/hydrogen-m.dylib" \
    "$ROBLOX_PLAYER_COPY" "$ROBLOX_PLAYER" --strip-codesig --all-yes

# 6. Resign Roblox app
info "Codesigning Roblox. Enter your password below (you won't be able to see it) to allow codesigning. Hydrogen will not work without this."
sudo codesign --force --deep --sign - "/Applications/Roblox.app"

# 7. Finish
success "Hydrogen-M installed successfully!"
echo "Enjoy the experience! Please provide feedback to help us improve."

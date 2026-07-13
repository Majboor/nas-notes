#!/bin/bash
# Compile Cherry from Sources/ into ~/Applications/Cherry.app, register it, seed the
# notes folder if empty, and launch it. Re-run any time to rebuild.
set -e
HERE="$(cd "$(dirname "$0")/.." && pwd)"
APP="$HOME/Applications/Cherry.app"
NOTES_DIR="${NAS_NOTES_DIR:-$HOME/.rpidrive/notes}"
LSREG="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

echo "› compiling…"
pkill -f "Cherry" 2>/dev/null || true; sleep 1
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
swiftc -O -o "$APP/Contents/MacOS/Cherry" "$HERE"/Sources/*.swift

cat > "$APP/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>Cherry</string>
  <key>CFBundleDisplayName</key><string>Cherry</string>
  <key>CFBundleIdentifier</key><string>com.hico.nasnotes</string>
  <key>CFBundleVersion</key><string>1.0.0</string>
  <key>CFBundleShortVersionString</key><string>1.0.0</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleExecutable</key><string>Cherry</string>
  <key>LSMinimumSystemVersion</key><string>11.0</string>
  <key>LSUIElement</key><true/>
  <key>CFBundleURLTypes</key><array><dict>
    <key>CFBundleURLName</key><string>com.hico.nasnotes.url</string>
    <key>CFBundleURLSchemes</key><array><string>nasnote</string></array>
  </dict></array>
</dict></plist>
EOF

codesign --force --deep -s - "$APP" >/dev/null 2>&1 || true
"$LSREG" -f "$APP" >/dev/null 2>&1 || true

# seed notes folder if empty
mkdir -p "$NOTES_DIR"
if [ -z "$(ls -A "$NOTES_DIR"/*.md 2>/dev/null)" ]; then
  cp "$HERE/examples/welcome.md" "$NOTES_DIR/welcome.md"
  echo "› seeded $NOTES_DIR/welcome.md"
fi

# install helper scripts next to the notes so the app can call them
cp "$HERE/Scripts/make-launchers.sh" "$HERE/Scripts/rebuild.sh" "$NOTES_DIR/"
chmod +x "$NOTES_DIR/make-launchers.sh" "$NOTES_DIR/rebuild.sh"
NAS_NOTES_DIR="$NOTES_DIR" "$NOTES_DIR/rebuild.sh" >/dev/null 2>&1 || true

open "$APP"
echo "✓ built + launched. Look for the note icon in your menu bar."

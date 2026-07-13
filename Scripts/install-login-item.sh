#!/bin/bash
# Start NAS Notes automatically at login via a LaunchAgent.
set -e
APP="$HOME/Applications/NAS Notes.app"
PLIST="$HOME/Library/LaunchAgents/com.hico.nasnotes.plist"
[ -d "$APP" ] || { echo "Build first: ./Scripts/build.sh"; exit 1; }

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.hico.nasnotes</string>
  <key>ProgramArguments</key><array><string>$APP/Contents/MacOS/NAS Notes</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><false/>
</dict></plist>
EOF

launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "✓ NAS Notes will start at login (and is running now)."

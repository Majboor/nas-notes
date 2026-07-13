#!/bin/bash
# Regenerate the README screenshots (docs/img/*.png) by rendering the REAL app UI offscreen
# with sanitized sample data, then rebuild the demo GIF. Requires ffmpeg + ImageMagick for the GIF.
set -e
HERE="$(cd "$(dirname "$0")/.." && pwd)"
IMG="$HERE/docs/img"; mkdir -p "$IMG"
B="$(mktemp -d)"; cp "$HERE/Scripts/snapshot.swift" "$B/main.swift"; cp "$HERE/Sources/html.swift" "$B/html.swift"
swiftc -O -o "$B/snap" "$B/main.swift" "$B/html.swift"
for p in home find note clips search fav toast; do "$B/snap" "$p" "$IMG/$p.png"; done

# optional GIF
if command -v ffmpeg >/dev/null && command -v magick >/dev/null; then
  for f in home find note clips search toast; do magick "$IMG/$f.png" -background '#232326' -gravity north -extent 1200x1360 "$IMG/pad_$f.png"; done
  L="$B/list.txt"
  { for f in home find note clips search toast; do echo "file '$IMG/pad_$f.png'"; echo "duration 1.6"; done; echo "file '$IMG/pad_toast.png'"; } > "$L"
  ffmpeg -y -f concat -safe 0 -i "$L" \
    -vf "fps=16,scale=560:-1:flags=lanczos,split[s0][s1];[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=bayer" \
    -loop 0 "$IMG/demo.gif"
  rm -f "$IMG"/pad_*.png
fi
rm -rf "$B"
echo "✓ screenshots + demo.gif regenerated in docs/img"

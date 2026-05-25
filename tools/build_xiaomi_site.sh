#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/xiaomi"

mkdir -p "$OUT/assets/generated" "$OUT/assets/fonts" "$OUT/assets/screenshots" "$OUT/game"

cp "$ROOT/website/index.html" "$OUT/index.html"
cp "$ROOT/website/styles.css" "$OUT/styles.css"
cp "$ROOT/website/app.js" "$OUT/app.js"

rsync -a --exclude='*.import' --exclude='rejected/' "$ROOT/assets/generated/" "$OUT/assets/generated/"
rsync -a "$ROOT/assets/fonts/" "$OUT/assets/fonts/"

if [[ -f "$ROOT/output/screenshots/prototype-private-collectibles-companion-final00000000.png" ]]; then
  cp "$ROOT/output/screenshots/prototype-private-collectibles-companion-final00000000.png" \
    "$OUT/assets/screenshots/prototype-private-collectibles-companion-final00000000.png"
fi

touch "$OUT/.nojekyll"
touch "$OUT/.gdignore"

perl -0pi -e 's#\.\./assets/#assets/#g; s#\.\./output/screenshots/#assets/screenshots/#g; s#\.\./xiaomi/game/#game/#g' \
  "$OUT/index.html" "$OUT/styles.css" "$OUT/app.js"

echo "Built $OUT"

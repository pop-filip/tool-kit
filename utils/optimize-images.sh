#!/bin/bash
# ============================================================
# optimize-images.sh — Konvertuj PNG/JPG u WebP
# Koristi: bash optimize-images.sh ./html/images
# Zahtijeva: cwebp (brew install webp)
# ============================================================

set -e

DIR="${1:-.}"
QUALITY="${2:-85}"
ERRORS=0

# Boje
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${CYAN}  optimize-images.sh  |  kvalitet: ${QUALITY}%${RESET}"
echo -e "${CYAN}  folder: ${DIR}${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Provjeri cwebp
if ! command -v cwebp &> /dev/null; then
  echo -e "${RED}GREŠKA: cwebp nije instaliran.${RESET}"
  echo "Instaliraj sa: brew install webp"
  exit 1
fi

# Provjeri folder
if [ ! -d "$DIR" ]; then
  echo -e "${RED}GREŠKA: Folder '$DIR' ne postoji.${RESET}"
  exit 1
fi

# --- Provjeri base64 u HTML fajlovima ---
echo -e "${YELLOW}[ PROVJERA ] Tražim base64 inline slike u HTML fajlovima...${RESET}"
HTML_FILES=$(find "$DIR/.." -maxdepth 2 -name "*.html" 2>/dev/null)
BASE64_FOUND=0
for htmlfile in $HTML_FILES; do
  COUNT=$(grep -c "data:image" "$htmlfile" 2>/dev/null || true)
  if [ "$COUNT" -gt 0 ]; then
    SIZE=$(wc -c < "$htmlfile" | awk '{printf "%.0f KB", $1/1024}')
    echo -e "${RED}  ⚠ UPOZORENJE: $htmlfile — ${COUNT}x base64 slika! Veličina: ${SIZE}${RESET}"
    BASE64_FOUND=1
    ERRORS=$((ERRORS + 1))
  fi
done
if [ "$BASE64_FOUND" -eq 0 ]; then
  echo -e "${GREEN}  ✓ Nema base64 inline slika${RESET}"
fi
echo ""

# --- Konvertuj PNG i JPG u WebP ---
echo -e "${YELLOW}[ KONVERZIJA ] Pretražujem PNG i JPG fajlove...${RESET}"
echo ""

CONVERTED=0
SKIPPED=0

find "$DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) | sort | while read -r img; do
  webp_file="${img%.*}.webp"
  orig_size=$(wc -c < "$img")
  orig_kb=$(echo "scale=1; $orig_size/1024" | bc)

  if [ -f "$webp_file" ]; then
    webp_size=$(wc -c < "$webp_file")
    webp_kb=$(echo "scale=1; $webp_size/1024" | bc)
    SAVINGS=$(echo "scale=0; (1 - $webp_size/$orig_size) * 100" | bc)
    echo -e "  ${CYAN}SKIP${RESET}  $(basename "$img") — webp već postoji (${orig_kb}KB → ${webp_kb}KB, -${SAVINGS}%)"
    continue
  fi

  if cwebp -q "$QUALITY" "$img" -o "$webp_file" 2>/dev/null; then
    webp_size=$(wc -c < "$webp_file")
    webp_kb=$(echo "scale=1; $webp_size/1024" | bc)
    SAVINGS=$(echo "scale=0; (1 - $webp_size/$orig_size) * 100" | bc)
    echo -e "  ${GREEN}OK${RESET}    $(basename "$img") — ${orig_kb}KB → ${webp_kb}KB (ušteda: ${SAVINGS}%)"
  else
    echo -e "  ${RED}GREŠKA${RESET} $(basename "$img")"
  fi
done

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}  ⚠ Pronađeni problemi — provjeri base64 upozorenja iznad!${RESET}"
else
  echo -e "${GREEN}  ✓ Gotovo — sve slike su optimizovane${RESET}"
fi
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

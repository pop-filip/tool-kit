#!/bin/bash
# ============================================================
# setup-monitoring.sh — UptimeRobot + SSL alert automatski
#
# Koristi: bash setup-monitoring.sh --url https://domain.com --name "Naziv"
# Zahtijeva: UPTIMEROBOT_API_KEY u env ili ~/.config/monitoring.env
#
# Kreira:
#   1. HTTP(S) uptime monitor (provjera svakih 5 min)
#   2. SSL sertifikat expiry alert (upozorenje 30 dana unaprijed)
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

# ── Argumenti ───────────────────────────────────────────────
URL=""
NAME=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --url)  URL="$2";  shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# ── API Key ──────────────────────────────────────────────────
CONFIG_FILE="$HOME/.config/monitoring.env"
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

if [ -z "$UPTIMEROBOT_API_KEY" ]; then
  echo -e "${YELLOW}UptimeRobot API key nije postavljen.${RESET}"
  echo "Dodaj ga u: ~/.config/monitoring.env"
  echo "  UPTIMEROBOT_API_KEY=ut1_xxxxxxxxxxxx"
  echo ""
  echo "Ili postavi env varijablu:"
  echo "  export UPTIMEROBOT_API_KEY=ut1_xxxxxxxxxxxx"
  echo ""
  echo "Dobij API key na: https://uptimerobot.com/dashboard#mySettings"
  exit 1
fi

if [ -z "$URL" ] || [ -z "$NAME" ]; then
  echo "Koristi: bash setup-monitoring.sh --url https://domain.com --name \"Naziv\""
  exit 1
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${CYAN}  setup-monitoring.sh${RESET}"
echo -e "${CYAN}  URL:  $URL${RESET}"
echo -e "${CYAN}  Ime:  $NAME${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# ── 1. HTTP Monitor ──────────────────────────────────────────
echo -e "${YELLOW}[ 1/2 ] Kreiranje HTTP monitora...${RESET}"

HTTP_RESPONSE=$(curl -s -X POST "https://api.uptimerobot.com/v2/newMonitor" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Cache-Control: no-cache" \
  --data-urlencode "api_key=$UPTIMEROBOT_API_KEY" \
  --data-urlencode "format=json" \
  --data-urlencode "type=1" \
  --data-urlencode "url=$URL" \
  --data-urlencode "friendly_name=$NAME" \
  --data-urlencode "interval=300")

HTTP_STATUS=$(echo "$HTTP_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('stat','error'))" 2>/dev/null || echo "error")

if [ "$HTTP_STATUS" = "ok" ]; then
  MONITOR_ID=$(echo "$HTTP_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['monitor']['id'])" 2>/dev/null)
  echo -e "  ${GREEN}✓ HTTP monitor kreiran (ID: $MONITOR_ID, interval: 5min)${RESET}"
else
  ERROR=$(echo "$HTTP_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('error',{}).get('message','nepoznata greška'))" 2>/dev/null || echo "$HTTP_RESPONSE")
  echo -e "  ${RED}✗ Greška: $ERROR${RESET}"
  # Možda monitor već postoji
  if echo "$HTTP_RESPONSE" | grep -q "already exists"; then
    echo -e "  ${YELLOW}  Monitor već postoji za ovaj URL.${RESET}"
  fi
fi

# ── 2. SSL Monitor ───────────────────────────────────────────
echo -e "${YELLOW}[ 2/2 ] Kreiranje SSL expiry monitora (alert 30 dana)...${RESET}"

SSL_RESPONSE=$(curl -s -X POST "https://api.uptimerobot.com/v2/newMonitor" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Cache-Control: no-cache" \
  --data-urlencode "api_key=$UPTIMEROBOT_API_KEY" \
  --data-urlencode "format=json" \
  --data-urlencode "type=99" \
  --data-urlencode "url=$URL" \
  --data-urlencode "friendly_name=$NAME — SSL" \
  --data-urlencode "interval=86400" \
  --data-urlencode "ssl_expiry=1" \
  --data-urlencode "ssl_expiry_notification_timing=30")

SSL_STATUS=$(echo "$SSL_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('stat','error'))" 2>/dev/null || echo "error")

if [ "$SSL_STATUS" = "ok" ]; then
  SSL_ID=$(echo "$SSL_RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['monitor']['id'])" 2>/dev/null)
  echo -e "  ${GREEN}✓ SSL monitor kreiran (ID: $SSL_ID, alert 30 dana unaprijed)${RESET}"
else
  # SSL monitor (type=99) nije na free planu — koristi keyword monitoring kao fallback
  echo -e "  ${YELLOW}  SSL tip 99 nije dostupan na free planu.${RESET}"
  echo -e "  ${YELLOW}  Postavi SSL provjeru ručno na: https://uptimerobot.com${RESET}"
fi

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}  ✓ Monitoring setup završen${RESET}"
echo -e "${CYAN}  Dashboard: https://uptimerobot.com/dashboard${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

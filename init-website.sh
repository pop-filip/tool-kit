#!/bin/bash
# ============================================================
# INIT WEBSITE — startup-premium-website-kit
#
# Koristiti:
#   bash init-website.sh
#
# Ili s argumentima:
#   bash init-website.sh --name "Moj Salon" --domain mojsalon.at \
#     --slug moj-salon --lang de --color "#c9a96e" --type static
# ============================================================

set -e

# ── Boje za output ──────────────────────────────────────────
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; NC='\033[0m'; BOLD='\033[1m'

KIT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  startup-premium-website-kit · Init${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ── Parse argumenti ─────────────────────────────────────────
SITE_NAME="" DOMAIN="" SLUG="" LANG="" COLOR="" TYPE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --name)        SITE_NAME="$2";   shift 2 ;;
    --domain)      DOMAIN="$2";      shift 2 ;;
    --slug)        SLUG="$2";        shift 2 ;;
    --lang)        LANG="$2";        shift 2 ;;
    --color)       COLOR="$2";       shift 2 ;;
    --type)        TYPE="$2";        shift 2 ;;
    --server-ip)   SERVER_IP="$2";   shift 2 ;;
    --server-user) SERVER_USER="$2"; shift 2 ;;
    --deploy-path) DEPLOY_PATH="$2"; shift 2 ;;
    --yes|-y)      CONFIRM="y";      shift ;;
    --dry-run)     DRY_RUN="1";      shift ;;
    *) shift ;;
  esac
done

# ── Interaktivni unos ako nema argumenata ───────────────────
if [ -z "$SITE_NAME" ]; then
  echo -e "${BLUE}▶ Naziv sajta${NC} (npr. Moj Salon, Frigo Đukić):"
  read -r SITE_NAME
fi

if [ -z "$DOMAIN" ]; then
  echo -e "${BLUE}▶ Domena${NC} (npr. mojsalon.at, frigodjukic.ba):"
  read -r DOMAIN
fi

if [ -z "$SLUG" ]; then
  # Auto-generisati slug iz naziva
  DEFAULT_SLUG=$(echo "$SITE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')
  echo -e "${BLUE}▶ Repo slug${NC} (Enter za: ${DEFAULT_SLUG}-website):"
  read -r SLUG
  SLUG="${SLUG:-${DEFAULT_SLUG}-website}"
fi

if [ -z "$LANG" ]; then
  echo -e "${BLUE}▶ Jezik${NC} [bs/de/en/hr/sr] (default: bs):"
  read -r LANG
  LANG="${LANG:-bs}"
fi

if [ -z "$COLOR" ]; then
  echo -e "${BLUE}▶ Primarna boja${NC} (hex, npr. #5aabcc, #c9a96e — default: #5aabcc):"
  read -r COLOR
  COLOR="${COLOR:-#5aabcc}"
fi

if [ -z "$TYPE" ]; then
  echo -e "${BLUE}▶ Tip projekta${NC} [static/nextjs] (default: static):"
  read -r TYPE
  TYPE="${TYPE:-static}"
fi

# ── Server info ─────────────────────────────────────────────
if [ -z "$SERVER_IP" ] && [ -z "$CONFIRM" ]; then
  echo ""
  echo -e "${BLUE}▶ Server IP${NC} (default: 157.180.67.68):"
  read -r SERVER_IP
fi
SERVER_IP="${SERVER_IP:-157.180.67.68}"

if [ -z "$SERVER_USER" ] && [ -z "$CONFIRM" ]; then
  echo -e "${BLUE}▶ Server user${NC} (default: root):"
  read -r SERVER_USER
fi
SERVER_USER="${SERVER_USER:-root}"

if [ -z "$DEPLOY_PATH" ] && [ -z "$CONFIRM" ]; then
  echo -e "${BLUE}▶ Deploy path${NC} (default: /var/www/${SLUG}/html):"
  read -r DEPLOY_PATH
fi
DEPLOY_PATH="${DEPLOY_PATH:-/var/www/${SLUG}/html}"

# ── Potvrda ─────────────────────────────────────────────────
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  Naziv:        ${BOLD}$SITE_NAME${NC}"
echo -e "  Domena:       ${BOLD}$DOMAIN${NC}"
echo -e "  GitHub repo:  ${BOLD}pop-filip/$SLUG${NC}"
echo -e "  Jezik:        ${BOLD}$LANG${NC}"
echo -e "  Boja:         ${BOLD}$COLOR${NC}"
echo -e "  Tip:          ${BOLD}$TYPE${NC}"
echo -e "  Server:       ${BOLD}$SERVER_USER@$SERVER_IP${NC}"
echo -e "  Deploy path:  ${BOLD}$DEPLOY_PATH${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
if [ -z "$CONFIRM" ]; then
  echo -e "Kreirati projekat? (y/n)"
  read -r CONFIRM
fi
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Otkazano."; exit 0
fi

# ── Kreiranje direktorija ────────────────────────────────────
PROJECTS_DIR="$(dirname "$KIT_DIR")"
PROJECT_DIR="$PROJECTS_DIR/$SLUG"

echo ""
echo -e "${GREEN}▶ Kreiranje projekta u $PROJECT_DIR...${NC}"

if [ -d "$PROJECT_DIR" ]; then
  echo -e "${RED}✗ Direktorij već postoji: $PROJECT_DIR${NC}"; exit 1
fi

mkdir -p "$PROJECT_DIR"

# ── Kopiranje template fajlova ───────────────────────────────
echo -e "${GREEN}▶ Kopiranje template fajlova iz kit-a...${NC}"

# Osnovna struktura
mkdir -p "$PROJECT_DIR/.github/workflows"
mkdir -p "$PROJECT_DIR/html/images"
mkdir -p "$PROJECT_DIR/html/logos"

# GitHub Actions deploy
cp "$KIT_DIR/ci-cd/deploy-static.yml" "$PROJECT_DIR/.github/workflows/deploy.yml"

# Kopirati nginx config
cp "$KIT_DIR/server/nginx-static.conf" "$PROJECT_DIR/nginx.conf"

# Kopirati checklist
cp "$KIT_DIR/website-checklist.html" "$PROJECT_DIR/checklist.html"

# ── Zamijeniti placeholdere u deploy.yml ────────────────────
sed -i.bak "s|DOMAIN.COM|$DOMAIN|g" "$PROJECT_DIR/nginx.conf" && rm "$PROJECT_DIR/nginx.conf.bak"
sed -i.bak "s|SITE-NAME|$SLUG|g" "$PROJECT_DIR/nginx.conf" && rm "$PROJECT_DIR/nginx.conf.bak"

# ── Kreirati index.html ──────────────────────────────────────
echo -e "${GREEN}▶ Kreiranje index.html...${NC}"
cat > "$PROJECT_DIR/html/index.html" << HTMLEOF
<!DOCTYPE html>
<html lang="$LANG">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$SITE_NAME</title>
  <meta name="description" content="$SITE_NAME — profesionalni web sajt">
  <link rel="canonical" href="https://$DOMAIN/">

  <!-- Open Graph -->
  <meta property="og:title" content="$SITE_NAME">
  <meta property="og:description" content="$SITE_NAME — profesionalni web sajt">
  <meta property="og:url" content="https://$DOMAIN/">
  <meta property="og:type" content="website">
  <meta property="og:image" content="https://$DOMAIN/images/og-image.jpg">

  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="$SITE_NAME">
  <meta name="twitter:image" content="https://$DOMAIN/images/og-image.jpg">

  <!-- Performance -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

  <!-- Favicon -->
  <link rel="icon" type="image/svg+xml" href="/images/favicon.svg">
  <link rel="icon" type="image/png" href="/images/favicon.png">
  <link rel="apple-touch-icon" href="/images/apple-touch-icon.png">

  <!-- PWA Manifest -->
  <link rel="manifest" href="/manifest.json">
  <meta name="theme-color" content="$COLOR">

  <!-- Schema.org -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "$SITE_NAME",
    "url": "https://$DOMAIN",
    "logo": "https://$DOMAIN/images/logo.svg"
  }
  </script>

  <!-- Google Analytics 4 — zamijeniti G-XXXXXXXXXX -->
  <!-- <script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'G-XXXXXXXXXX');
  </script> -->

  <style>
    :root { --primary: $COLOR; }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: sans-serif; background: #fff; color: #111; min-height: 100vh; display: flex; align-items: center; justify-content: center; }
    .placeholder { text-align: center; padding: 40px; }
    .placeholder h1 { font-size: 2rem; color: var(--primary); margin-bottom: 12px; }
    .placeholder p { color: #666; font-size: 1rem; }
    .dot { width: 10px; height: 10px; border-radius: 50%; background: var(--primary); display: inline-block; margin-bottom: 20px; animation: pulse 1.4s infinite; }
    @keyframes pulse { 0%,100%{opacity:1;transform:scale(1)} 50%{opacity:0.5;transform:scale(1.3)} }
  </style>
</head>
<body>
  <div class="placeholder">
    <div class="dot"></div>
    <h1>$SITE_NAME</h1>
    <p>Website u izradi · $DOMAIN</p>
  </div>
</body>
</html>
HTMLEOF

# ── Kreirati manifest.json ───────────────────────────────────
cat > "$PROJECT_DIR/html/manifest.json" << JSONEOF
{
  "name": "$SITE_NAME",
  "short_name": "$SITE_NAME",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "$COLOR",
  "icons": [
    { "src": "/images/icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/images/icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
JSONEOF

# ── Kreirati robots.txt ──────────────────────────────────────
cat > "$PROJECT_DIR/html/robots.txt" << ROBOTEOF
User-agent: *
Allow: /

Sitemap: https://$DOMAIN/sitemap.xml
ROBOTEOF

# ── Kreirati sitemap.xml ─────────────────────────────────────
TODAY=$(date +%Y-%m-%d)
cat > "$PROJECT_DIR/html/sitemap.xml" << SITEMAPEOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://$DOMAIN/</loc>
    <lastmod>$TODAY</lastmod>
    <changefreq>monthly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
SITEMAPEOF

# ── Kreirati README ──────────────────────────────────────────
cat > "$PROJECT_DIR/README.md" << READMEEOF
# $SITE_NAME

Website za **$DOMAIN**

## Stack
- Vanilla HTML/CSS/JS
- nginx na Hetzner VPS
- GitHub Actions auto-deploy

## Deploy
Push na \`main\` → automatski deploy na server.

## GitHub Secrets (Settings → Secrets → Actions)
| Secret | Vrijednost |
|--------|-----------|
| \`SSH_PRIVATE_KEY\` | Private SSH key za server |
| \`SSH_HOST\` | \`$SERVER_IP\` |
| \`SSH_USER\` | \`$SERVER_USER\` |
| \`DEPLOY_PATH\` | \`$DEPLOY_PATH\` |

## Server setup (jednom)
\`\`\`bash
bash nginx-setup.sh $DOMAIN $SLUG
\`\`\`

## Checklist
Otvoriti \`checklist.html\` u browseru.
READMEEOF

# ── Kreirati .gitignore ──────────────────────────────────────
cat > "$PROJECT_DIR/.gitignore" << GITEOF
.DS_Store
*.swp
*.swo
node_modules/
.env
.env.local
GITEOF

# ── Git init ─────────────────────────────────────────────────
if [ "$DRY_RUN" = "1" ]; then
  echo -e "${YELLOW}▶ [DRY RUN] Preskačem git init i GitHub repo kreiranje.${NC}"
else
  echo -e "${GREEN}▶ Inicijalizacija git repozitorija...${NC}"
  cd "$PROJECT_DIR"
  git init
  git add .
  git commit -m "Initial commit — $SITE_NAME ($DOMAIN)

Generated by startup-premium-website-kit

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"

  # ── GitHub repo ──────────────────────────────────────────────
  echo ""
  echo -e "${GREEN}▶ Kreiranje GitHub repozitorija pop-filip/$SLUG...${NC}"
  gh repo create "pop-filip/$SLUG" --private --source=. --remote=origin --push
fi

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}${BOLD}  ✅ Projekat kreiran!${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  📁 Lokacija:    ${BOLD}$PROJECT_DIR${NC}"
echo -e "  🐙 GitHub:      ${BOLD}https://github.com/pop-filip/$SLUG${NC}"
echo -e "  🌐 Domena:      ${BOLD}https://$DOMAIN${NC}"
echo ""
echo -e "${YELLOW}📋 Sljedeći koraci:${NC}"
echo -e "  1. Dodaj GitHub Secrets (SSH_PRIVATE_KEY, SSH_HOST, SSH_USER, DEPLOY_PATH)"
echo -e "  2. SSH na server → bash nginx.conf setup za $DOMAIN"
echo -e "  3. Reci Claudeu: 'Pravimo $SITE_NAME za $DOMAIN' i daj mu CLAUDE.md"
echo -e "  4. Otvori checklist.html i kreni s izradom"
echo ""

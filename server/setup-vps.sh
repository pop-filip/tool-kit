#!/bin/bash
# ============================================================
# VPS SETUP SCRIPT — Hetzner Ubuntu
# Pokrenuti jednom pri setup novog servera ili novog sajta
#
# Koristiti: bash setup-vps.sh DOMAIN.COM SITE-NAME
# Primjer:   bash setup-vps.sh veselko.at veselko
# ============================================================

DOMAIN=$1
SITE=$2

if [ -z "$DOMAIN" ] || [ -z "$SITE" ]; then
  echo "Koristiti: bash setup-vps.sh DOMAIN.COM SITE-NAME"
  exit 1
fi

echo "▶ Kreiranje web direktorija za $SITE..."
mkdir -p /var/www/$SITE/html
chown -R www-data:www-data /var/www/$SITE

echo "▶ Kopiranje nginx config..."
cp /path/to/nginx-static.conf /etc/nginx/sites-available/$SITE

# Zamijeniti placeholdere
sed -i "s/DOMAIN.COM/$DOMAIN/g" /etc/nginx/sites-available/$SITE
sed -i "s/SITE-NAME/$SITE/g" /etc/nginx/sites-available/$SITE

echo "▶ Aktiviranje nginx config..."
ln -sf /etc/nginx/sites-available/$SITE /etc/nginx/sites-enabled/$SITE

echo "▶ Test nginx config..."
nginx -t

echo "▶ Izdavanje SSL certifikata za $DOMAIN..."
certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN

echo "▶ Reload nginx..."
systemctl reload nginx

echo ""
echo "✅ Setup završen!"
echo "   Sajt: https://$DOMAIN"
echo "   Root: /var/www/$SITE/html"
echo "   Nginx config: /etc/nginx/sites-enabled/$SITE"
echo ""
echo "📋 Sljedeći koraci:"
echo "   1. Dodaj GitHub Secrets: SSH_PRIVATE_KEY, SSH_HOST, SSH_USER, DEPLOY_PATH"
echo "   2. DEPLOY_PATH = /var/www/$SITE/html"
echo "   3. Push na main → auto-deploy"

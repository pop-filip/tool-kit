# startup-premium-website-kit · Claude Instructions

Ovaj repozitorij je **osobni starter kit** za sve buduće web projekte.

## Kako koristiti

Kad korisnik kaže: **"Pravimo website [NAZIV] za [DOMENA]"**, uradi sljedeće:

### 1. Pokreni init script
```bash
bash /Users/filip/tool-kit/init-website.sh \
  --name "NAZIV" \
  --domain "DOMENA" \
  --slug "naziv-website" \
  --lang "bs|de|en" \
  --color "#HEX_BOJA" \
  --type "static|nextjs"
```

### 2. Što script automatski kreira
- GitHub repo `pop-filip/naziv-website` (private)
- `html/index.html` sa svim meta tagovima, OG, Schema.org, GA4 placeholder
- `html/manifest.json` (PWA)
- `html/robots.txt` + `html/sitemap.xml`
- `nginx.conf` (popunjen domenom)
- `.github/workflows/deploy.yml` (GitHub Actions → rsync na VPS)
- `checklist.html` (interaktivni checklist za projekat)
- `README.md` sa GitHub Secrets instrukcijama

### 3. Nakon init-a — pitaj korisnika
1. **Dizajn brief**: boje, font, stil (minimalistički/bold/elegantni)
2. **Sadržaj**: sekcije koje treba (hero, o nama, usluge, galerija, kontakt...)
3. **Jezik i tržište**: BS/HR/SR/DE/EN — prilagodi copy i SEO
4. **Slike**: ima li vlastite slike ili treba placeholdere
5. **Forma za kontakt**: Web3Forms (besplatno) ili email direktno

### 4. SEO podaci koje treba popuniti
- Title tag (50-60 znakova, ključna riječ)
- Meta description (150-160 znakova)
- Schema.org: LocalBusiness (adresa, tel, radno vrijeme)
- OG slika (1200×630px)

---

## Što je u kitu

| Folder | Sadržaj |
|--------|---------|
| `seo/` | seo-metadata.tsx, sitemap.ts, robots.txt |
| `security/` | nginx security headers, middleware |
| `components/` | cookie-consent (GDPR), analytics (GA4) |
| `accessibility/` | WCAG AA komponente i CSS |
| `pwa/` | manifest.json, service worker |
| `ci-cd/` | GitHub Actions (Next.js + static HTML) |
| `server/` | nginx config template, VPS setup script |
| `hooks/` | React hooks (media query, intersection, scroll...) |
| `utils/` | helpers (format, validate, slugify...) |
| `website-checklist.html` | Interaktivni master checklist |

---

## Pravila za svaki novi sajt

1. **SVG kao `<img>`** — nikad `<style>` blok unutar SVG fajla (iOS Safari bug)
2. **WebP slike** — uvijek `<picture>` element s PNG fallbackom za stari iOS
3. **Inline fill** na SVG atributima (ne CSS klase)
4. **GA4** — učitavati tek nakon cookie consent-a
5. **Schema.org** — Organization + LocalBusiness na svakoj stranici
6. **Security headers** — koristiti nginx.conf iz kita (već podešeno)
7. **Cache-Control** — slike 30d immutable, HTML no-cache
8. **Google Search Console** — registrovati odmah nakon go-live
9. **Uptime monitoring** — UptimeRobot za svaki sajt
10. **Backup** — automatski, dnevno

---

## Server info (Hetzner jebenko)

- **IP**: 157.180.67.68
- **User**: root
- **SSH**: `ssh root@157.180.67.68`
- **Web root**: `/var/www/[site-name]/html`
- **Nginx configs**: `/etc/nginx/sites-available/`

## Aktivni sajtovi

| Domena | Folder | Status |
|--------|--------|--------|
| frigodjukic.ba | /var/www/frigo-djukic/html | ✅ Live |
| veselko.at | /var/www/veselko/html | 🔧 Setup |

---

## Pokretanje novog projekta (TL;DR)

```
Korisnik: "Pravimo website za salon ljepote Bella u Linzu, domena bella-linz.at"

Claude:
1. Pokreće init-website.sh s parametrima
2. Pita za boje, stil, sekcije
3. Kreira HTML sa svim SEO/schema/GA4
4. Postavlja na server
5. Otvara checklist.html za tracking progresa
```

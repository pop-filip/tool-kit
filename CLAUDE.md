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
5. **Forma za kontakt**: uvijek koristi `https://digitalnature.at/api/leads.php` (POST, JSON: name, email, phone, message, source)

### 4. SEO podaci koje treba popuniti
- Title tag (50-60 znakova, ključna riječ)
- Meta description (150-160 znakova)
- Schema.org: LocalBusiness (adresa, tel, radno vrijeme)
- OG slika (1200×630px) — **obavezno kreirati**:
  ```bash
  python3 /Users/filip/tool-kit/utils/create-og-image.py \
    --name "NAZIV" --tagline "TAGLINE" --city "GRAD" \
    --domain "DOMENA" --phone "+387 XX XXX XXX" \
    --logo "./html/images/logo.png" \
    --output "./html/images/og-image.jpg"
  ```

### 5. Social share provjera (obavezno nakon go-live)
- OG URL mora biti ista domena kao `canonical` — nikad `.ba` ako je sajt na `.com`
- `og:image` mora biti apsolutna URL (ne `/images/og-image.jpg`)
- Testiraj na: https://www.opengraph.xyz ili Facebook debug tool

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

1. **SVG kao `<img>`** — nikad `<style>` blok unutar SVG fajla (iOS Safari bug); inline fill atributi
2. **WebP slike** — uvijek `<picture>` element s PNG fallbackom za stari iOS
   - Pokreni prije deploya: `bash /Users/filip/tool-kit/utils/optimize-images.sh ./html/images`
3. **NIKAD base64 inline slike u HTML-u** — čini HTML enormnim i blokira cijelo učitavanje
   - Logo, ikone, slike — uvijek snimiti kao vanjski fajl u `html/images/`
   - Brza provjera: `grep -c "data:image" html/index.html`
4. **OG slika** — uvijek kreirati `html/images/og-image.jpg` (1200×630px) koristeći `create-og-image.py`
5. **OG URL domena** — `og:url` mora biti ista domena kao `<link rel="canonical">` (ne miješati .ba/.com/.at)
6. **GA4** — učitavati tek nakon cookie consent-a
7. **prefers-reduced-motion** — uvijek dodati na kraju CSS animacija:
   ```css
   @media (prefers-reduced-motion: reduce) {
     *, *::before, *::after { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; scroll-behavior: auto !important; }
   }
   ```
8. **ARIA obavezno** — kopiraj iz `tool-kit/accessibility/aria-snippets.md`:
   - Skip-to-main link kao **prvo dijete `<body>`**
   - `<header role="banner">`, `<main id="main-content" tabindex="-1">`, `<footer role="contentinfo">`
   - `aria-expanded` + `aria-controls` na hamburger — JS toggle
   - `aria-label` na SVG ikonama bez teksta; `aria-hidden="true"` na dekorativnim SVG
   - `aria-labelledby` na svakom `<section>`
   - `role="alert"` + `aria-live="polite"` na form greškama
   - `:focus-visible` CSS vidljiv ring
9. **Service Worker** — kopirati `tool-kit/pwa/sw-static.js` → `html/sw.js`; registrirati u HTML prije `</body>`:
   ```html
   <script>if('serviceWorker'in navigator)window.addEventListener('load',()=>navigator.serviceWorker.register('/sw.js').catch(()=>{}));</script>
   ```
   Kopirati i prilagoditi `tool-kit/pwa/offline.html` → `html/offline.html`
10. **Schema.org** — Organization + LocalBusiness na svakoj stranici
11. **Security headers** — koristiti nginx.conf iz kita (već podešeno)
12. **Cache-Control** — slike 30d immutable, HTML no-cache
13. **Monitoring** — po deployu pokrenuti: `bash /Users/filip/tool-kit/utils/setup-monitoring.sh --url "https://domain.com" --name "Naziv"`
14. **Google Search Console** — registrovati odmah nakon go-live
15. **Backup** — automatski, dnevno

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

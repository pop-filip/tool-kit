# Social Share (Open Graph + Twitter Cards)

Kompletna dokumentacija za social media dijeljenje na vanilla HTML i Next.js projektima.

---

## Što se prikazuje kad neko podijeli link

WhatsApp, Facebook, LinkedIn, iMessage, Slack, Twitter/X — svi čitaju **Open Graph** meta tagove i prikazuju:
- **Naslov** — `og:title`
- **Opis** — `og:description`
- **Slika** — `og:image` (1200×630px)
- **Domena** — automatski iz URL-a

---

## Obavezni meta tagovi (vanilla HTML)

```html
<!-- Open Graph — obavezno -->
<meta property="og:type"        content="website">
<meta property="og:url"         content="https://yourdomain.com/">
<meta property="og:title"       content="Naziv Firme | Kratki opis">
<meta property="og:description" content="Šta radite, za koga, benefit. Max 160 znakova.">
<meta property="og:image"       content="https://yourdomain.com/images/og-image.jpg">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:image:alt"   content="Naziv Firme — Grad">
<meta property="og:locale"      content="bs_BA">
<meta property="og:site_name"   content="Naziv Firme">

<!-- Twitter/X Card -->
<meta name="twitter:card"        content="summary_large_image">
<meta name="twitter:title"       content="Naziv Firme | Kratki opis">
<meta name="twitter:description" content="Šta radite, za koga, benefit.">
<meta name="twitter:image"       content="https://yourdomain.com/images/og-image.jpg">
<meta name="twitter:image:alt"   content="Naziv Firme — Grad">
```

**Pravila:**
- `og:url` mora biti **ista domena** kao `<link rel="canonical">` — ne `.ba` ako je sajt na `.com`
- `og:image` mora biti **apsolutna URL** (ne relativna putanja `/images/...`)
- Isti `og:image` koristi se i za Twitter — nema potrebe za posebnim

---

## OG slika — specifikacije

| Parametar | Vrijednost |
|---|---|
| Dimenzije | **1200 × 630 px** |
| Format | **JPG** (bolji za WhatsApp/Facebook) |
| Veličina | **< 300 KB** (idealno < 100KB) |
| Tekst na slici | Ime firme + tagline + domena |
| Logo na slici | Da — u gornjem lijevom kutu |

---

## Kreiranje OG slike — Python skript

```bash
# Zahtijeva: pip3 install Pillow --break-system-packages
python3 /Users/filip/tool-kit/utils/create-og-image.py \
  --name "Naziv Firme" \
  --tagline "Kratki opis usluge" \
  --city "Grad" \
  --domain "yourdomain.com" \
  --phone "+387 XX XXX XXX" \
  --logo "./html/images/logo.png" \
  --output "./html/images/og-image.jpg"
```

Skript kreira branded sliku sa:
- Logo (gornji lijevi kut)
- Naziv firme (veliki naslov)
- ICE linija naglašavanja
- Tagline / opis usluge
- Tagovi usluga (opcionalno)
- Domena + telefon (donji desni kut)
- Brand boje + geometrijski dekor

---

## Najčešće greške

| Greška | Efekt | Rješenje |
|---|---|---|
| `og:image` je relativna putanja | Slika se ne prikazuje | Koristi apsolutnu URL |
| `og:url` ≠ `canonical` | SEO penalizacija | Kopiraj canonical URL u og:url |
| og-image.jpg ne postoji | Prazna preview kartica | Pokreni create-og-image.py |
| og-image je preširok tekst | Odrezan tekst na mobilnom | Max 2 reda, font > 48px |
| og-image > 5MB | Facebook ga ignoriše | Kompresuj na < 300KB |

---

## Testiranje

- **Facebook / WhatsApp / LinkedIn:** [developers.facebook.com/tools/debug](https://developers.facebook.com/tools/debug)
- **Twitter/X:** [cards-dev.twitter.com/validator](https://cards-dev.twitter.com/validator)
- **OpenGraph:** [opengraph.xyz](https://www.opengraph.xyz)

Uvijek testiraj nakon deploya — platforme kešuju OG podatke pa može trebati force-refresh.

---

## Next.js — Automatski (seo-metadata.tsx)

`generateSEOMetadata()` iz `seo/seo-metadata.tsx` automatski kreira sve OG i Twitter tagove:

```tsx
export const metadata = generateSEOMetadata({
  title: 'Naziv Firme',
  description: 'Šta radite, za koga, benefit.',
  path: '/',
  image: '/images/og-image.jpg',   // relativna putanja — Next.js automatski pravi apsolutnu
});
```

---

## Schema.org + OG sinergija

OG slika se koristi i u Schema.org `LocalBusiness`:

```json
{
  "@type": "LocalBusiness",
  "name": "Naziv Firme",
  "image": "https://yourdomain.com/images/og-image.jpg"
}
```

Isti fajl, isti URL — dosljednost pomaže Google rich results.

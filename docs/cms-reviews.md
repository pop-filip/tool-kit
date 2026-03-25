# CMS — Reviews & AggregateRating

## Šta je i zašto

Google čita `AggregateRating` Schema.org data iz JSON-LD bloka u `index.html`.
Ako ima dovoljno recenzija, može prikazati ★★★★★ direktno u search rezultatima:

```
Digital Nature — Websites Live in 24h | Linz
★★★★★ 5/5 · 5 reviews
digitalnature.at
```

## Implementacija (po sajtu)

### Fajlovi

| Fajl | Opis |
|------|------|
| `html/reviews.json` | Izvor podataka — lista recenzija |
| `html/admin/save-reviews.php` | PHP koji ažurira reviews.json + index.html JSON-LD |
| Admin panel → tab "Reviews" | UI za dodavanje/uređivanje/brisanje |

### reviews.json struktura

```json
{
  "reviews": [
    {
      "author": "Ime Prezime",
      "rating": 5,
      "body": "Tekst recenzije..."
    }
  ]
}
```

### Schema.org u index.html (auto-generisano)

```json
"aggregateRating": {
  "@type": "AggregateRating",
  "ratingValue": "5.0",
  "reviewCount": "4",
  "bestRating": "5",
  "worstRating": "1"
},
"review": [
  {
    "@type": "Review",
    "author": { "@type": "Person", "name": "Ime Prezime" },
    "reviewRating": { "@type": "Rating", "ratingValue": "5", "bestRating": "5" },
    "reviewBody": "Tekst recenzije..."
  }
]
```

**`ratingValue`** se automatski izračunava kao prosjek svih ocjena.
**`reviewCount`** je automatski `reviews.length`.

---

## Workflow — novi klijent ostavi recenziju

1. Klijent pošalje recenziju (WhatsApp, email, Google)
2. Otvori `/admin` → tab **Reviews**
3. Klikni **Add Review**
4. Unesi: ime, ocjena (1-5), tekst
5. Klikni **Save to Site**
6. Gotovo — JSON-LD u `index.html` je ažuriran, reviewCount++

---

## Kako dodati na novi sajt

### 1. Kreiraj reviews.json

```json
{
  "reviews": []
}
```

### 2. Dodaj save-reviews.php u admin/

Kopiraj iz `~/digital-nature-website/html/admin/save-reviews.php`.
Jedina prilagodba: PHP uzima `../index.html` — ostaje isto za svaki sajt.

### 3. Dodaj JSON-LD u index.html

U `<script type="application/ld+json">`, unutar Organization ili LocalBusiness objekta:

```json
"aggregateRating": {
  "@type": "AggregateRating",
  "ratingValue": "5",
  "reviewCount": "1",
  "bestRating": "5",
  "worstRating": "1"
},
"review": [
  {
    "@type": "Review",
    "author": { "@type": "Person", "name": "Ime" },
    "reviewRating": { "@type": "Rating", "ratingValue": "5", "bestRating": "5" },
    "reviewBody": "Tekst prve recenzije."
  }
]
```

### 4. Dodaj Reviews tab u admin panel

Kopiraj pattern iz `~/digital-nature-website/html/admin/index.html`:
- Nav item `nav-reviews`
- Page div `page-reviews`
- JS funkcije: `renderReviews`, `buildReviewsUI`, `updateReviewSummary`, `addReview`, `deleteReview`, `saveReviews`

### 5. Isključi reviews.json iz auto-deploya

U `.github/workflows/deploy.yml` dodaj:
```yaml
--exclude='html/reviews.json'
```

Bez ovoga, svaki git push bi prebrisao recenzije na serveru s praznom listom.

---

## Napomene

- **Minimum recenzija za Google zvjezdice**: Google ne garantuje prikaz, ali preporučuje 3+. Sa 5+ recenzija šanse su znatno veće.
- **Recenzije moraju biti realne** — Google penalizuje fake recenzije u Schema.org.
- **reviews.json se ne servira javno** (dodaj nginx deny ako treba), ali nije osjetljiv podatak.
- **Backup**: reviews.json je u gitu kao inicijalna verzija. Serverska verzija se razvija nezavisno.

---

## Validacija Schema.org

Nakon svakog save-a provjeri na:
**Google Rich Results Test**: https://search.google.com/test/rich-results

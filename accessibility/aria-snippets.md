# ARIA + prefers-reduced-motion — Snippets

Obavezni paterni za svaki generisani HTML. Copy-paste ready.

---

## 1. prefers-reduced-motion — CSS

Dodaj uvijek u globalni CSS, odmah nakon animacija:

```css
/* ── prefers-reduced-motion ─────────────────────────────── */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

---

## 2. Skip-to-main link (keyboard navigacija)

Prvo dijete `<body>` — nevidljivo dok nema fokus:

```html
<!-- Skip link — MORA biti prvo u body -->
<a href="#main-content" class="skip-link">Preskoči na sadržaj</a>
```

```css
.skip-link {
  position: absolute;
  top: -100%;
  left: 16px;
  background: var(--primary, #5aabcc);
  color: #fff;
  padding: 10px 20px;
  border-radius: 0 0 8px 8px;
  font-size: 14px;
  font-weight: 600;
  z-index: 9999;
  text-decoration: none;
  transition: top 0.2s;
}
.skip-link:focus {
  top: 0;
}
```

---

## 3. Navigacija — ARIA

```html
<header role="banner">
  <nav aria-label="Glavna navigacija">
    <button
      class="hamburger"
      aria-label="Otvori meni"
      aria-expanded="false"
      aria-controls="nav-menu"
    >
      <span class="hamburger-line"></span>
      <span class="hamburger-line"></span>
      <span class="hamburger-line"></span>
    </button>
    <ul id="nav-menu" role="list">
      <li><a href="#home" aria-current="page">Početna</a></li>
      <li><a href="#services">Usluge</a></li>
      <li><a href="#contact">Kontakt</a></li>
    </ul>
  </nav>
</header>
```

**JS — aria-expanded toggle:**
```javascript
const hamburger = document.querySelector('.hamburger');
const navMenu   = document.getElementById('nav-menu');

hamburger.addEventListener('click', () => {
  const isOpen = hamburger.getAttribute('aria-expanded') === 'true';
  hamburger.setAttribute('aria-expanded', String(!isOpen));
  hamburger.setAttribute('aria-label', isOpen ? 'Otvori meni' : 'Zatvori meni');
  navMenu.classList.toggle('open');
});
```

---

## 4. Glavne landmarks

```html
<body>
  <a href="#main-content" class="skip-link">Preskoči na sadržaj</a>

  <header role="banner">
    <nav aria-label="Glavna navigacija">...</nav>
  </header>

  <main id="main-content" tabindex="-1">
    <section aria-labelledby="hero-heading">
      <h1 id="hero-heading">Naziv firme</h1>
    </section>

    <section aria-labelledby="services-heading">
      <h2 id="services-heading">Naše usluge</h2>
    </section>

    <section aria-labelledby="contact-heading">
      <h2 id="contact-heading">Kontakt</h2>
    </section>
  </main>

  <footer role="contentinfo">...</footer>
</body>
```

---

## 5. Ikone bez teksta — aria-label

```html
<!-- Ikona bez vidljivog teksta -->
<button aria-label="Pretraži">
  <svg aria-hidden="true" focusable="false" ...>...</svg>
</button>

<!-- Link samo sa ikonom -->
<a href="tel:+38765888090" aria-label="Pozovi nas: +387 65 888 090">
  <svg aria-hidden="true" focusable="false">...</svg>
</a>

<!-- Dekorativna slika -->
<img src="decoration.webp" alt="" role="presentation">
```

---

## 6. Forma — kompletna ARIA

```html
<form novalidate aria-label="Kontakt forma">
  <div class="field">
    <label for="name">Ime i prezime <span aria-hidden="true">*</span></label>
    <input
      id="name" name="name" type="text"
      autocomplete="name"
      required
      aria-required="true"
      aria-describedby="name-error"
    >
    <span id="name-error" class="error" role="alert" aria-live="polite"></span>
  </div>

  <div class="field">
    <label for="email">E-mail adresa <span aria-hidden="true">*</span></label>
    <input
      id="email" name="email" type="email"
      autocomplete="email"
      required
      aria-required="true"
      aria-describedby="email-error"
    >
    <span id="email-error" class="error" role="alert" aria-live="polite"></span>
  </div>

  <div class="field">
    <label for="message">Poruka</label>
    <textarea id="message" name="message" rows="5" autocomplete="off"></textarea>
  </div>

  <!-- Success poruka -->
  <div role="status" aria-live="polite" id="form-success" hidden>
    Poruka je uspješno poslana. Kontaktiraćemo vas uskoro.
  </div>

  <button type="submit">Pošalji poruku</button>
</form>
```

---

## 7. Accordion / FAQ — ARIA

```html
<div class="faq">
  <div class="faq-item">
    <button
      class="faq-question"
      aria-expanded="false"
      aria-controls="faq-answer-1"
      id="faq-btn-1"
    >
      Kako zakazati servis?
      <svg class="faq-icon" aria-hidden="true">...</svg>
    </button>
    <div
      id="faq-answer-1"
      role="region"
      aria-labelledby="faq-btn-1"
      hidden
    >
      <p>Odgovor na pitanje...</p>
    </div>
  </div>
</div>
```

```javascript
document.querySelectorAll('.faq-question').forEach(btn => {
  btn.addEventListener('click', () => {
    const expanded = btn.getAttribute('aria-expanded') === 'true';
    btn.setAttribute('aria-expanded', String(!expanded));
    const answer = document.getElementById(btn.getAttribute('aria-controls'));
    answer.hidden = expanded;
  });
});
```

---

## 8. Focus vidljiv na svim elementima

```css
/* Osiguraj da focus ring bude vidljiv u svim browserima */
:focus-visible {
  outline: 2px solid var(--primary, #5aabcc);
  outline-offset: 3px;
  border-radius: 4px;
}

/* Ukloni outline za mouse korisnike, zadrži za keyboard */
:focus:not(:focus-visible) {
  outline: none;
}
```

---

## Kontrast — minimalni omjeri (WCAG AA)

| Tekst | Pozadina | Min. omjer |
|---|---|---|
| Normalni tekst (< 18px) | Pozadina | **4.5 : 1** |
| Veliki tekst (≥ 18px bold ili ≥ 24px) | Pozadina | **3 : 1** |
| UI komponente (ikone, borderi) | Pozadina | **3 : 1** |

Provjeri na: https://webaim.org/resources/contrastchecker/

**Frigo-djukic paleta (Ice Tech):**
- `#5aabcc` na `#0b0f14` → omjer **5.8:1** ✅
- `rgba(255,255,255,0.65)` na `#0b0f14` → omjer **8.2:1** ✅

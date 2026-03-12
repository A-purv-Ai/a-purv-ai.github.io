# ISRO Mission Dashboard — Full Rebuild Documentation

> Use this file to rebuild the page from scratch. It documents every structural, styling, and scripting decision made in this project.

---

## 1. File Structure

```
isro-analysis/
├── index.html        ← All markup, content, JS (inline at bottom)
├── styles.css        ← All styling, animations, responsive rules
├── milkyway-bg.jpg   ← Full-resolution Milky Way background image (must exist)
└── claude.md         ← This file
```

**No external JavaScript libraries. No build tools. No npm.**
Deploy by dropping the folder onto any static host (GitHub Pages, Netlify, etc.).

---

## 2. Head & Asset Imports (index.html)

```html
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ISRO Launch Success Prediction | Apurva Upadhyay</title>
<meta name="description" content="Data-driven launch risk assessment for India's space program — ML-powered mission success prediction using Random Forest and SMOTE.">

<!-- Google Fonts (NO preconnect for gstatic — just one link) -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@800&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<!-- IMPORTANT: preload the background image so it's ready before the intro animation ends -->
<link rel="preload" as="image" href="milkyway-bg.jpg">
<link rel="stylesheet" href="styles.css">
```

> **Note:** The `<body>` tag is never explicitly written. The `<head>` closes and the body starts directly with `<div id="starfield">`.

---

## 3. Design System (CSS Variables)

```css
:root {
    --dark-bg: #0a1628;
    --card-bg: rgba(16, 30, 52, 0.82);
    --panel-bg: rgba(12, 24, 44, 0.9);
    --border-color: rgba(0, 209, 255, 0.2);
    --border-glow: rgba(0, 209, 255, 0.35);
    --text-primary: #e0e6f0;
    --text-secondary: #8fadd4;
    --accent: #00d1ff;           /* Cyan — used everywhere */
    --accent-glow: rgba(0, 209, 255, 0.45);
    --success-green: #00e676;
    --failure-red: #ff5252;
    --warning-amber: #ffc107;
    --rocket-body: #EAEAEA;
    --rocket-accent: #c0392b;    /* Brick red for rocket fins/nose */
}
```

Body font stack: `'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif`
Heading/accent font: `'Orbitron'` (only weight 800)

---

## 4. Background Layer System

Three stacked layers (all `position: fixed`, covering 100vw × 100vh):

| Layer | Element | CSS `z-index` | What it does |
|---|---|---|---|
| 1 (bottom) | `body::before` | `-2` | `milkyway-bg.jpg` — `background-size: cover`, `no-repeat fixed center center` |
| 2 | `body::after` | `-1` | Dark gradient overlay `rgba(10,22,40, 0.45→0.65)` for readability |
| 3 | `#starfield` | `0` | JS-generated twinkling `.star` dots, `opacity: 0.4` |

---

## 5. Phase 1 — Intro Splash Screen

### HTML Structure
```html
<div id="starfield"></div>

<div id="intro-splash">
    <!-- GSLV — positioned LEFT -->
    <div class="intro-rocket-3d r-left">
        <div class="rocket-label">GSLV</div>
        <div class="rocket-3d">
            <div class="nc3d"></div>  <!-- nose cone -->
            <div class="rb3d">       <!-- cylindrical body -->
                <div class="rb-stripe top"></div>
                <div class="rb-logo">ISRO</div>
                <div class="rb-type">GSLV</div>
                <div class="rb-window"></div>
                <div class="rb-stripe bot"></div>
            </div>
            <div class="rf3d left"></div>    <!-- fin left -->
            <div class="rf3d right"></div>   <!-- fin right -->
            <div class="engine-nozzle"></div>
            <div class="exhaust-group">
                <div class="exhaust-glow"></div>
                <div class="exhaust-outer"></div>
                <div class="exhaust-core"></div>
                <div class="smoke-puff"></div>
                <div class="smoke-puff"></div>
                <div class="smoke-puff"></div>
            </div>
        </div>
    </div>

    <!-- LVM3 — positioned CENTER (biggest, 1.6× scale) -->
    <!-- Same structure as GSLV but class="intro-rocket-3d r-center" -->
    <!-- Inside .rb3d also includes a .rb-stripe.mid -->
    <!-- .exhaust-group has 4 smoke-puffs (not 3) -->
    <!-- rb-type text = "LVM3" -->

    <!-- PSLV — positioned RIGHT (smallest, 0.85× scale) -->
    <!-- Same structure as GSLV but class="intro-rocket-3d r-right" -->
    <!-- rb-type text = "PSLV" -->

    <button class="launch-btn" id="launchBtn">Launch</button>
</div>
```

> **GSLV & PSLV:** No `.rb-stripe.mid` in body. **LVM3 only** has the mid stripe.
> **LVM3:** 4 smoke-puffs. **GSLV & PSLV:** 3 smoke-puffs.

### CSS: Rocket Sizing & Position

| Rocket | Class | CSS Scale | z-index | Horizontal position |
|---|---|---|---|---|
| LVM3 | `.r-center` | `scale(1.6) rotateY(-10deg)` | 5 | Centered |
| GSLV | `.r-left` | `scale(1.1) rotateY(-12deg)` | 3 | left: 25% |
| PSLV | `.r-right` | `scale(0.85) rotateY(-12deg)` | 3 | left: auto, right: 25% |

All `.intro-rocket-3d` elements: `position: absolute; bottom: 80px`  
Wrapper `.rocket-3d`: `width: 50px; height: 170px; transform-style: preserve-3d`

**Rocket Component Key Dimensions:**
- Nose cone (`.nc3d`): CSS triangle `border-bottom: 48px` of `#c0392b`
- Body (`.rb3d`): `width: 50px; height: 100px; top: 44px` — metallic radial gradient
- Fins (`.rf3d`): `position: absolute; bottom: -4px` — CSS border triangles, `#c0392b`
- Nozzle (`.engine-nozzle`): `bottom: 12px; width: 24px; height: 14px` — flush with body bottom
- Exhaust group (`.exhaust-group`): `bottom: -60px` — starts below nozzle
- Flame (`.exhaust-core`): `border-radius: 50% 50% 50% 50% / 20% 20% 80% 80%` — teardrop shape
- Glow (`.exhaust-glow`): `width: 110px; height: 120px; radial-gradient ellipse at center 40%`

### CSS: Launch Trigger (`.launching` class)

When JS adds class `.launching` to `#intro-splash`:

```css
/* Exhaust makes visible */
#intro-splash.launching .intro-rocket-3d .exhaust-group { opacity: 1; }

/* Animations start */
#intro-splash.launching .intro-rocket-3d.r-center {
    animation: rocket-ascend 4s cubic-bezier(0.32, 0, 0.67, 0.2) forwards;
}
#intro-splash.launching .intro-rocket-3d.r-left {
    animation: rocket-ascend-left 4s cubic-bezier(0.32, 0, 0.67, 0.2) forwards;
    animation-delay: 0.2s;
}
#intro-splash.launching .intro-rocket-3d.r-right {
    animation: rocket-ascend-right 4s cubic-bezier(0.32, 0, 0.67, 0.2) forwards;
    animation-delay: 0.2s;
}

/* Button hides */
#intro-splash.launching .launch-btn { opacity: 0; pointer-events: none; }
```

**Keyframes** (simple `from`/`to` — the cubic-bezier handles acceleration):
```css
@keyframes rocket-ascend {
    from { bottom: 80px; }
    to   { bottom: 150vh; }
}
@keyframes rocket-ascend-left {
    from { bottom: 80px; transform: translateX(0); }
    to   { bottom: 150vh; transform: translateX(-120px); }
}
@keyframes rocket-ascend-right {
    from { bottom: 80px; transform: translateX(0); }
    to   { bottom: 150vh; transform: translateX(120px); }
}
```

### CSS: Launch Button (`.launch-btn`)

Glassmorphism style: `position: fixed; bottom: 36px; left: 50%; transform: translateX(-50%)`  
Background: `rgba(0, 209, 255, 0.07)` with `backdrop-filter: blur(12px)`  
Border: `1.5px solid rgba(0, 209, 255, 0.32)` with glowing `box-shadow`  
Font: `'Orbitron'`, `text-transform: uppercase`, bright cyan `color: var(--accent)`

### JS: Launch Sequence

```javascript
const launchBtn = document.getElementById('launchBtn');
const splash = document.getElementById('intro-splash');

launchBtn.addEventListener('click', function() {
    // Request fullscreen
    document.documentElement.requestFullscreen().catch(() => {});
    
    // Start rockets
    splash.classList.add('launching');
    
    // After 3.7s — fade splash, reveal content
    setTimeout(() => {
        splash.style.opacity = '0';
        setTimeout(() => splash.remove(), 800); // remove after fade
        document.body.classList.add('intro-complete');
    }, 3700);
});
```

---

## 6. Phase 2 — Mission Control Layout

### HTML Skeleton
```html
<a href="https://a-purv-ai.github.io" class="portfolio-tab" target="_blank">
    <span>🌌</span> My Portfolio
</a>

<div class="mission-control">
    <main class="narrative-column">
        <header class="page-header">
            <div class="version-badge">
                <span class="badge-v1">v1.0</span>
                <span class="badge-text">Capstone Project — IIT Ropar, Major in AI</span>
            </div>
            <h1>ISRO Launch Success Prediction</h1>
            <p class="subtitle">...</p>
        </header>

        <!-- 6 narrative sections, each with data-panel attribute -->
        <section class="narrative-section" data-panel="problem">...</section>
        <section class="narrative-section" data-panel="approach">...</section>
        <section class="narrative-section" data-panel="tools">...</section>
        <section class="narrative-section" data-panel="results">...</section>
        <section class="narrative-section" data-panel="demo">...</section>
        <section class="narrative-section" data-panel="roadmap">...</section>

        <div class="notebook-section">...</div>  <!-- Project structure list -->
    </main>

    <aside class="dashboard-panel">
        <!-- 6 panels matching data-panel values above -->
        <div class="panel active" data-for="problem">Mission Timeline</div>
        <div class="panel" data-for="approach">Pipeline Flow</div>
        <div class="panel" data-for="tools">Tech Stack Grid</div>
        <div class="panel" data-for="results">Model Performance</div>
        <div class="panel" data-for="demo">Prediction Example</div>
        <div class="panel" data-for="roadmap">Roadmap v1→v2</div>
    </aside>
</div>
```

### CSS: Layout

```css
.mission-control {
    max-width: 1400px;
    margin: 0 auto;
    padding: 3rem 2rem 4rem;
    display: grid;
    grid-template-columns: 1fr 420px;
    gap: 2.5rem;
    align-items: start;
}
.dashboard-panel {
    position: sticky;
    top: 120px;
    height: 580px;  /* fixed height, panels inside are absolute */
    width: 420px;
}
```

### Right Panel: Switching Logic

All `.panel` elements are `position: absolute; top: 0; left: 0; right: 0` within `.dashboard-panel`.  
Only the `.active` panel has `opacity: 1; pointer-events: auto`.  
Inactive panels: `opacity: 0; transform: translateX(16px)`.  
Transition: `0.5s cubic-bezier(.22, 1, .36, 1)`.

---

## 7. Content — The 6 Narrative Sections & Matching Dashboard Panels

### Panel 1 — `data-panel="problem"` ↔ `data-for="problem"`
- **Narrative:** Problem / Motivation (commercial satellite risk, PSLV-C61/C62 failures)
- **Dashboard:** Mission Timeline — 8 `.timeline-item` entries (1993-2026), each with `.timeline-dot` class: `success` (green), `failure` (pulsing red), or `partial` (amber)
- **Timeline entries:** PSLV-D1 (1993), Chandrayaan-1 (2008), Mars Orbiter (2013), GSLV-F09 failure (2017), Chandrayaan-2 (2019), Chandrayaan-3 (2023), PSLV-C61 failure (2025), PSLV-C62 failure (2026)

### Panel 2 — `data-panel="approach"` ↔ `data-for="approach"`
- **Narrative:** Data/Approach (Wikipedia scraping, SMOTE, Random Forest)
- **Dashboard:** ML Pipeline flow — `.pipe-step` items with emoji icons and two lines of text (`.pipe-text`, `.pipe-sub`). Steps: Data Collection → Preprocessing → Feature Engineering → SMOTE Balancing → Random Forest Training → GridSearchCV → Deployment

### Panel 3 — `data-panel="tools"` ↔ `data-for="tools"`
- **Narrative:** Tools & Technologies (Python, BeautifulSoup, scikit-learn, etc.)
- **Dashboard:** Tech badge grid — `.tech-badge` items each with `.tech-badge-icon` (emoji), `.tech-badge-name`, `.tech-badge-role`. Badges: Python, Pandas, scikit-learn, SMOTE, BeautifulSoup, Matplotlib, Streamlit, Jupyter

### Panel 4 — `data-panel="results"` ↔ `data-for="results"`
- **Narrative:** Key Insights / Results
- **Dashboard:** Model Performance — two `.stat-ring` circles (for accuracy %, CV score %) with `data-target` attributes. Feature importance horizontal bars with `data-width` attributes for animated fills.
  - Accuracy: 85% (`data-target="85"`)
  - CV Score: 82% (`data-target="82"`)
  - Vehicle Family: 42% bar, Payload Mass: 31%, Orbit Type: 16%, Launch Site: 11%

### Panel 5 — `data-panel="demo"` ↔ `data-for="demo"`
- **Narrative:** Visuals / Demo (links to GitHub, README, Presentation, Demo Video)
- **Dashboard:** Prediction Example — Shows sample input params in a grid (Vehicle: PSLV, Orbit: SSO, Payload: 1200kg, Site: SDSC), then predicted output of `91%` (`data-target="91"`). Mini bar chart showing success rates by vehicle: PSLV 92%, GSLV 60%, LVM3 100%.

### Panel 6 — `data-panel="roadmap"` ↔ `data-for="roadmap"`
- **Narrative:** Reflection / Next Steps (v2.0 physics-aware constraints)
- **Dashboard:** Roadmap Progress — v1.0 completed steps (`.roadmap-step.completed`) and v2.0 planned steps (`.roadmap-step.planned`). Each has a `.roadmap-step-dot`, `.roadmap-step-title` (with ✓ or ◯ span), and `.roadmap-step-desc`.

---

## 8. JavaScript — Scroll Logic & Animations

All JS is **inline** in a single `<script>` block at the bottom of `<body>`.

### Initialization (inside `DOMContentLoaded`):
1. `window.scrollTo(0, 0)` + `history.scrollRestoration = 'manual'` — always start at top on refresh
2. Portfolio link click → attempts `requestFullscreen()`
3. Launch button click handler (see Section 5)
4. Starfield generation: 150 random `.star` divs with random `width`, `top`, `left`, `animationDelay/Duration`
5. Entrance animations observer for `.narrative-section` and `.notebook-section`
6. Panel switching observer for `.narrative-section[data-panel]` elements
7. Initial timeline animation trigger: `setTimeout(() => animatePanel(...), 400)`

### Panel Switch Observer:
```javascript
const panelObserver = new IntersectionObserver(callback, {
    threshold: [0.2, 0.4, 0.6],
    rootMargin: '-80px 0px -30% 0px'
});
```
Uses "best ratio" logic: among all intersecting sections, picks the one with the highest `intersectionRatio`.

### Animation Functions:
| Panel | Function | What it animates |
|---|---|---|
| `problem` | `animateTimeline()` | Stagger-adds `.animate-in` to timeline items (120ms apart) |
| `approach` | `animatePipeline()` | Stagger-adds `.animate-in` to pipe steps (140ms apart) |
| `tools` | `animateTechGrid()` | Stagger-adds `.animate-in` to tech badges (90ms apart) |
| `results` | `animateResults()` | Animates stat ring `--pct` CSS var + count-up, then feature bar widths after 400ms delay |
| `demo` | `animateDemo()` | Count-up on prediction % value, then mini-bar widths after 500ms delay |
| `roadmap` | `animateRoadmap()` | Stagger-adds `.animate-in` to roadmap steps (150ms apart) |

### Count-Up Utility:
`countUp(el, targetNumber, duration, suffix='')` — Uses `requestAnimationFrame` with ease-out cubic formula: `eased = 1 - Math.pow(1 - progress, 3)`.

**Each animation runs only once** — tracked via `const animatedPanels = new Set()`.

---

## 9. Responsive Design

- **Below 900px:** Grid becomes `grid-template-columns: 1fr`. Right sticky panel hides (`display: none`).
- **Below 500px:** Mission control padding reduced, `h1` font-size reduced to 1.4rem.

---

## 10. HTML Content — Exact External Links

| Button | URL |
|---|---|
| Portfolio tab | `https://a-purv-ai.github.io` |
| View on GitHub | `https://github.com/A-purv-Ai/isro-analysis` |
| README | `https://github.com/A-purv-Ai/isro-analysis/blob/main/README.md` |
| Presentation | `https://docs.google.com/presentation/d/1lLUHOhOrWRVurLETg-D3nkYkDgNVBUIdCP-bEMWJIPE/` |
| Demo Video | `https://drive.google.com/file/d/1pCbkusrP7aP5FqsNZcxEj9tQdYB3m_u_/` |

---

## 11. Key Nuances / Things That Will Break Without Documentation

1. **`milkyway-bg.jpg` must be in the same directory as `styles.css`** — the `url('milkyway-bg.jpg')` is a relative path.
2. **The `<html>` and `<body>` tags are unconventional** — `<head>` closes on line 13, then body content starts immediately. No explicit `<body>` open tag.
3. **Splash screen removal is DOM-destructive** — `splash.remove()` fully removes `#intro-splash` from the DOM after `4.2s` (extended from `3.7s`). Do not rely on its existence after launch.
4. **`body.intro-complete` class gates content visibility** — `body:not(.intro-complete) .mission-control` has `opacity: 0`. Content is invisible until this class is added.
5. **Panel animations run exactly once** — `animatedPanels` Set prevents re-running them if you scroll back up and then down again.
6. **LVM3 differs from GSLV/PSLV** — it has an extra `.rb-stripe.mid` inside `.rb3d` AND 4 smoke-puffs (not 3).
7. **Nozzle flush math** — body ends at `top: 144px` in a `170px` container = `26px` from bottom. Nozzle `height: 14px` at `bottom: 12px` = nozzle top at `26px` = exactly flush. Don't blindly change these values.
8. **Progressive Background Nuances** — The `body` element must have `background-color: transparent`. A solid color here will hide the instant `blur(20px)` placeholder mapped to `body::before` at `z-index: -3`. The high-res image `div.bg-hi-res` fades in at `z-index: -2` over `3s`.

---

## 12. Glassmorphism Blur & Opacity Reference

These values were tuned iteratively for visual clarity. Rebuilding from scratch? Start here:

| Element | CSS Class | `backdrop-filter` | Background `rgba` alpha |
|---|---|---|---|
| Launch Button | `.launch-btn` | `blur(12px)` | `0.07` |
| Right Dashboard Panels | `.panel` | `blur(8px)` | `0.5` |
| Project Nav Section | `.notebook-section` | `blur(7px)` | `0.4` |

> **Tuning tip:** The `backdrop-filter` blur values control how "frosted" the glass looks. Lower values = more of the Milky Way starfield background shows through. Higher values = more legible on complex backgrounds. The current values (~7-12px) prioritise showing the background image while keeping text comfortably readable.

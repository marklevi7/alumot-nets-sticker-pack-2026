# MUI v5.14.0 ↔ Israeli Ministry of Education — Accessibility Compliance Gap Analysis

**Project:** alumot-nets-sticker-pack-2026
**Design system under review:** Material UI (MUI) **v5.14.0** (React) + MUI RTL setup
**Compliance target:** Israeli Ministry of Education (משרד החינוך) — Accessibility & Usability Technical Adjustments
**Date:** 2026-06-15

---

## 1. Sources reviewed

| # | Source | What it gives us |
|---|--------|------------------|
| 1 | Ministry of Education — Accessibility / Technical Adjustments | The legal + technical requirements (the "must-have" side) — https://sapakim.education.gov.il/accessibility/tech-adjustments/ |
| 2 | MUI — Right-to-left support (developer docs) | RTL setup, packages, caveats — https://mui.com/material-ui/customization/right-to-left/ |
| 3 | MUI for Figma v5.14.0 — RTL (community design kit) | The visual/design side — https://www.figma.com/community/file/1339536974199353550/mui-for-figma-v5-14-0-rtl |

### Requirement basis (the Ministry document)
The Ministry's requirements are anchored in:
- Equal Rights for Persons with Disabilities Law, 5758-1998
- Equal Rights Regulations (Service Accessibility), 5773-2013 — **Section 35 (תקנה 35)**
- **Israeli Standard SI 5568 Part 1** (Web Content Accessibility) — the Israeli adoption of **WCAG 2.0**
- **Israeli Standard SI 5568 Part 2** (Digital Document Accessibility)
- **WCAG 2.0 Levels A and AA**

> **Important scoping note:** The Ministry page (and SI 5568 Part 1) is built on **WCAG 2.0 A/AA** — *not* WCAG 2.1/2.2. Several MUI default failures (e.g. non-text/UI-component contrast 1.4.11, target size 2.5.5) belong to WCAG 2.1/2.2 and are therefore **not strictly mandatory** under the current Ministry baseline. They are flagged below as *recommended, not required* so you don't over- or under-scope the work.

---

## 2. Methodology & confidence

- **Code/theme behavior (high confidence):** Assessed against MUI v5.14.0 documented defaults and the RTL guide, cross-checked against open MUI GitHub issues for the failing items.
- **Version pinning (high confidence):** Confirmed that v5.14.0 shipped with the **original `stylis-plugin-rtl`** package, while the live docs page now reflects the newer **`@mui/stylis-plugin-rtl`** fork. This is a genuine doc/version mismatch (see §4.1).
- **Figma design kit (limited confidence):** The community file is a *visual* kit. I reviewed it at the level of "what MUI v5.14.0 renders by default"; I could **not** introspect private layer/token values inside the community file. Visual-token findings below are inferred from the matching code defaults, not read out of the Figma file directly. **Recommend a manual token audit of the Figma file** as a follow-up (see §6).

**Bottom-line verdict:** MUI v5.14.0 is a **solid, mostly-compliant** foundation — keyboard operability, semantics, labels/`aria` wiring, focus-visible, and rem-based scaling are good out of the box. It is **NOT 100% compliant out of the box.** There are a small number of **concrete default failures** (mostly color-contrast) and **RTL caveats** that you must fix at the theme/app level. None are blockers; all are fixable with theme overrides + disciplined component usage. Details and the "diff" follow.

---

## 3. Compliance matrix (requirement → MUI v5.14.0 status)

Legend: ✅ compliant out of the box · ⚠️ needs configuration · ❌ default fails, must override

| Ministry requirement | WCAG 2.0 ref | MUI v5.14.0 default | Status | Action needed |
|---|---|---|---|---|
| Text contrast ≥ 4.5:1 (normal), ≥ 3:1 (large) | 1.4.3 | Body text `rgba(0,0,0,.87)`, secondary `rgba(0,0,0,.6)` pass; **placeholder ~2.8:1 fails**; **filled-label-on-focus fails** | ❌ | Override `::placeholder` & filled label color (§4.2) |
| Resize text up to 200% without loss | 1.4.4 | Typography in `rem`, responsive | ✅ | Keep `rem`; avoid fixed `px` on text |
| Sans-serif font, web ≥ 15px | (Usability) | Roboto (sans-serif), body = 16px | ⚠️ | Roboto Hebrew coverage is weak — set a Hebrew sans-serif (Arial/Assistant/Rubik/Heebo) (§4.3) |
| Full keyboard operability, no traps | 2.1.1 / 2.1.2 | Buttons, Menu, Select, Autocomplete, Dialog all keyboard-driven | ✅ | Don't disable focus; keep `autoFocus`/focus-trap behavior |
| Logical tab order matching visual order | 2.4.3 | DOM order = visual order | ⚠️ | In **RTL**, ensure DOM source order matches the visual RTL order; avoid `tabIndex > 0` |
| Visible keyboard focus | 2.4.7 | `:focus-visible` ring on interactive components | ✅ | Don't remove `outline`; verify ring contrast on colored backgrounds |
| Form fields have programmatic labels | 1.3.1 / 4.1.2 | `TextField`/`InputLabel` wire `htmlFor`/`id` | ✅ | Always pass `label`; never rely on placeholder as the label |
| Errors identified & described programmatically | 3.3.1 / 3.3.3 | `error` sets `aria-invalid`; `helperText` linked via `aria-describedby` | ✅ | Use `error` + `helperText` together; don't convey error by color only (3.3.1) |
| Icon-only controls have a name | 4.1.2 | `IconButton` has **no** name by default | ❌ | Add `aria-label` to every icon-only control (§4.4) |
| Images have text alternatives | 1.1.1 | No enforcement; `Avatar`/`img` need `alt` | ⚠️ | Author `alt`; mark decorative images `alt=""` / `aria-hidden` |
| Headings hierarchical (H1→H2→…) | 1.3.1 / 2.4.6 | `Typography variant` ≠ semantic level | ⚠️ | Set `component="h2"` etc. — variant is visual only (§4.5) |
| Tables: identifiable header cells | 1.3.1 | `TableCell` in `TableHead` → `<th scope="col">` | ✅ | For row headers set `component="th" scope="row"` |
| No auto-playing motion; flashing ≤ 3/sec | 2.2.2 / 2.3.1 | `CircularProgress`/`LinearProgress`/`Skeleton` animate continuously | ⚠️ | Acceptable as status indicators; honor `prefers-reduced-motion`; no `autoPlay` carousels (§4.6) |
| Live text, not images of text | 1.4.5 | Text is real text | ✅ | Don't bake text into image/SVG assets |
| Color not sole information carrier | 1.4.1 | Status colors (error/success) used alone in some patterns | ⚠️ | Pair color with icon/text |
| **RTL / Hebrew layout** | (1.3.2 / usability) | Supported via plugin, **with caveats** | ⚠️ | See §4.1 + §5 — package pin, portals, icon flipping |

---

## 4. THE DIFF — items that are NOT good / not compliant at MUI v5.14.0

These are the actionable defects. Each has cause, impact, and a copy-pasteable fix.

### 4.1 ❌ RTL package mismatch between v5.14.0 and the current docs
**Problem.** The MUI RTL docs page you linked now instructs `@mui/stylis-plugin-rtl`. **MUI v5.14.0 shipped against the original `stylis-plugin-rtl`** (with `stylis`). If you copy today's docs verbatim onto a pinned v5.14.0 install you can hit peer/version mismatches and "Module not found" / unexpected-flip issues (cf. MUI issues #30688, #33563).

**Impact.** RTL styling may silently fail to flip, or the app fails to build — directly affecting Hebrew layout compliance.

**Fix (for pinned v5.14.0):**
```bash
npm install stylis stylis-plugin-rtl
```
```jsx
import { CacheProvider } from '@emotion/react';
import createCache from '@emotion/cache';
import { prefixer } from 'stylis';
import rtlPlugin from 'stylis-plugin-rtl';

const cacheRtl = createCache({
  key: 'muirtl',
  stylisPlugins: [prefixer, rtlPlugin],
});
```
> Use `stylis-plugin-rtl@^2` (built for stylis v4, which v5.14.0 uses). If/when you upgrade MUI past the cut-over release, switch to `@mui/stylis-plugin-rtl`. **Pin it either way** so the docs-vs-installed drift can't bite you again.

### 4.2 ❌ Color contrast — placeholder & filled-label (WCAG 1.4.3)
**Problem.** Two confirmed default failures in MUI's theme:
- **Input placeholder** renders at `opacity: 0.42` of the text color → roughly **~2.8:1** on white — fails the 4.5:1 requirement (MUI issues #24947, mui-x #20238).
- **Filled `TextField` label, when focused**, drops below 4.5:1 (MUI issue #40841).

**Impact.** Direct SI 5568 / WCAG 2.0 AA 1.4.3 failure on every form using defaults — and forms are explicitly called out in the Ministry document (forms must be accessible).

**Fix (theme override):**
```jsx
const theme = createTheme({
  direction: 'rtl',
  components: {
    MuiInputBase: {
      styleOverrides: {
        input: {
          '&::placeholder': {
            color: 'rgba(0,0,0,0.6)', // ~#666 ≈ 5.7:1 on white — passes
            opacity: 1,               // override the default 0.42
          },
        },
      },
    },
  },
});
```
> Then verify each input variant (filled/outlined/standard) with a contrast checker at default **and focused** states, on the actual background.

### 4.3 ⚠️ Font family — Roboto vs Hebrew
**Problem.** MUI's default `Roboto` has weak/inconsistent Hebrew glyph coverage at v5.14.0; the Ministry requires a clean sans-serif. Roboto satisfies "sans-serif" but not necessarily good Hebrew rendering.

**Fix.** Set a Hebrew-first sans-serif stack:
```jsx
typography: {
  fontFamily: ['Assistant', 'Rubik', 'Heebo', 'Arial', 'sans-serif'].join(','),
},
```
> Ministry usability guidance: web text **≥ 15px** (MUI body is 16px — fine). Keep `caption`/small variants (12px) out of essential reading flows.

### 4.4 ❌ Icon-only controls have no accessible name (WCAG 4.1.2)
**Problem.** `<IconButton>` renders no text — screen readers announce nothing. This is the single most common real-world MUI a11y defect.

**Fix.** Mandatory `aria-label` on every icon-only control:
```jsx
<IconButton aria-label="סגור">   {/* "close" */}
  <CloseIcon />
</IconButton>
```
> Add a lint rule (e.g. `eslint-plugin-jsx-a11y`) to enforce it project-wide.

### 4.5 ⚠️ Headings are visual-only by default (WCAG 1.3.1 / 2.4.6)
**Problem.** `<Typography variant="h1">` controls *appearance*, not the rendered tag — it's easy to ship visually-styled text that isn't a real heading, or to skip levels.

**Fix.** Decouple visual size from semantic level:
```jsx
<Typography variant="h4" component="h1">כותרת ראשית</Typography>
```
> Maintain a single H1 per page and no skipped levels.

### 4.6 ⚠️ Continuous motion (WCAG 2.2.2)
**Problem.** `CircularProgress`, `LinearProgress`, and `Skeleton` animate indefinitely. As genuine status indicators this is generally acceptable, but the Ministry requires no gratuitous auto-motion and honoring user motion preferences.

**Fix.** Respect reduced-motion and avoid decorative auto-animation:
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { animation-duration: .001ms !important; transition-duration: .001ms !important; }
}
```
> No `autoPlay` carousels/marquees. Any moving content that isn't essential status must have a stop/pause control.

---

## 5. RTL-specific caveats you MUST handle (Hebrew)

The stylis plugin flips **CSS** — it does **not** solve everything. These are documented MUI limitations and are the most likely RTL compliance gaps:

1. **Portaled components don't inherit `dir`.** `Dialog`, `Popover`, `Menu`, `Tooltip`, `Snackbar`, `Select` dropdown, Autocomplete listbox render outside the parent DOM and **do not** pick up `dir="rtl"` from an ancestor. Set `dir="rtl"` on `<html>` (global approach) **and** verify each portaled surface individually.
2. **Directional icons don't auto-flip.** Arrows, chevrons, back/forward, breadcrumb separators, send icons must be flipped manually (`sx={{ transform: 'scaleX(-1)' }}` or swap the icon). The plugin only transforms CSS, never SVG glyphs.
3. **Inline/physical styles bypass the flip.** Hard-coded `marginLeft`/`paddingRight`/`left` in inline `style` won't flip. Use `sx`/`styled` (which route through the plugin) or logical properties (`marginInlineStart`, etc.).
4. **`/* @noflip */` does not work inside the `sx` prop** at v5.14.0 (MUI issue #33563). If you need to opt a rule out of flipping, use `styled()` with the `/* @noflip */` comment, not `sx`.
5. **Tab order in RTL.** Confirm keyboard tab order still follows logical reading order after the flip; never use positive `tabIndex`.

---

## 6. Remediation checklist

- [ ] **Pin** `stylis` + `stylis-plugin-rtl@^2` for MUI v5.14.0 (not `@mui/stylis-plugin-rtl`) — §4.1
- [ ] Set `theme.direction = 'rtl'` **and** `dir="rtl"` on `<html>` — §5
- [ ] Override placeholder color/opacity to ≥ 4.5:1; re-test filled label on focus — §4.2
- [ ] Set Hebrew sans-serif font stack — §4.3
- [ ] `aria-label` on every `IconButton` / icon-only control; add `jsx-a11y` lint — §4.4
- [ ] Audit `Typography` usages: correct `component=` for every heading, one H1, no skipped levels — §4.5
- [ ] Add `prefers-reduced-motion` handling; remove any auto-playing decorative motion — §4.6
- [ ] Manually verify every **portaled** surface renders RTL — §5.1
- [ ] Flip all **directional icons** — §5.2
- [ ] Replace physical inline styles with `sx`/logical properties — §5.3
- [ ] Don't convey errors/status by color alone (add icon/text) — 1.4.1 / 3.3.1
- [ ] **Figma token audit:** verify the v5.14.0 RTL kit's color tokens meet 4.5:1 / 3:1 before handing to dev — §2 (not introspected here)
- [ ] Publish an **Accessibility Statement** (הצהרת נגישות) declaring SI 5568 Part 1 & 2 compliance level + contact, per the Ministry document
- [ ] Plan the **5-year periodic accessibility review** (Section 28)

---

## 7. Limitations of this review

- This is a **design-system capability assessment**, not an audit of a built application. Final compliance can only be confirmed with **automated testing (axe) + manual screen-reader testing (NVDA/VoiceOver) + keyboard testing** on the actual product, plus the SI 5568 conformance process.
- The **Figma community kit** was assessed at the level of MUI v5.14.0's matching code defaults; its internal token values were **not** read directly — a manual token audit is recommended (§6).
- The Ministry baseline used here is **WCAG 2.0 A/AA via SI 5568**. If the specific tender/contract for your project cites WCAG 2.1 AA, re-scope to add 1.4.11 (non-text contrast — note MUI's default input borders ~1.6:1 fail this) and 2.5.5/2.5.8 target size.

*Prepared as a compliance gap analysis. Treat the §4 "diff" items and §6 checklist as the actionable work.*

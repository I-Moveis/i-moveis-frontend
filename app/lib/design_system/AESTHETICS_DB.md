# 🇯🇵 Japanese Creative Web — Aesthetics Database

> This document stores the exact visual identity tokens extracted from the reference sites to ensure perfect replication of the Japanese creative web aesthetic within the Desafio Ciclo design system.

## 1. p5aholic (Keita Yamada)
**Source:** https://p5aholic.me/projects/
**Concept:** Clean, monochrome brutalism with massive typography and refined spacing.

*   **Color Scheme:** Light / Monochrome
*   **Primary Background:** `#E6E6E6`
*   **Primary Text:** `#111111` / `#000000`
*   **Typography:** [Neue Montreal](https://pangrampangram.com/products/neue-montreal)
    *   *Display:* 60px
    *   *Body:* 12px (Massive contrast between headings and body text)
*   **Spacing Base Unit:** 4px
*   **Border Radius:** 0px (Sharp, brutalist edges)
*   **Vibe:** Professional, Minimalist, Motion-heavy (canvas background effects typically).

## 2. LQVE
**Source:** https://lqve.jp/
**Concept:** Editorial precision mixed with vibrant singular accents.

*   **Color Scheme:** Light
*   **Primary Accent:** `#01FFEA` (Vibrant Cyan/Neon)
*   **Primary Background:** `#FFFFFF`
*   **Primary Text:** `#000000`
*   **Typography:**
    *   *Primary / UI:* Suisse Intl
    *   *Headings:* The Future
    *   *Japanese:* ten-mincho-antique
    *   *Paragraphs:* Suisse Works (Serif)
*   **Font Scaling:** Headings at 28px, subheadings at 16px, body at 12px.
*   **Border Radius:** 0px

## 3. obake.blue
**Source:** https://obake.blue/
**Concept:** Playful yet highly structured brutalism. Pastel and vivid colors mixed.

*   **Color Scheme:** Dark / Mixed
*   **Primary Background:** `#E5E5E5`
*   **Accent Color 1:** `#2B00FF` (Deep vivid blue)
*   **Accent Color 2:** `#ECACAC` (Pastel Pink)
*   **Typography:**
    *   *Heading:* PP Neue Machina (Technical/ink-trap feel)
    *   *Body / Japanese:* DNP Shuei Gothic Kin Std
*   **Font Scaling:** Extremely compact UI text (14px headings, 12px body).
*   **Border Radius:** 0px

## 4. Starpeggio (Midnight Grand Orchestra)
**Source:** https://midnight-grand-orchestra.jp/starpeggio/
**Concept:** Soft, dreamy, curved borders, cosmic pastel aesthetic.

*   **Color Scheme:** Light / Pastel
*   **Primary Background:** `#E8ECF2`
*   **Accent Color:** `#AEF1F5` (Pastel Cyan / Glassy)
*   **Primary Text:** `#000000`
*   **Typography:** [PP Neue Montreal](https://pangrampangram.com/products/neue-montreal)
*   **Font Scaling:** 28px headings, 12px body.
*   **Border Radius:** 18px (Noticeably rounded comparing to the brutalist 0px of others)

## 5. Overture (Midnight Grand Orchestra)
**Source:** https://midnight-grand-orchestra.jp/overture-bluray-dvd/
**Concept:** Dark, cinematic, high-impact display typography.

*   **Color Scheme:** Dark
*   **Primary Background:** `#070808` (Deep, almost-black grey)
*   **Accent Color:** `#054646` (Deep Emerald/Teal)
*   **Typography:**
    *   *Heading:* PP Fragment Glare (Elegant, sharp serif)
    *   *Monospace/Data:* PP Fraktion Mono
*   **Font Scaling:** Massive headings (80px+), very tight body (12px).
*   **Border Radius:** 0px

---

## Synthesis for the Design System (`lib/design_system/`)

### A. Typography Rules (`app_typography.dart`)
1.  **Massive Scale Contrast**: Headings should be scaled extremely large (e.g., 60px - 80px), while body text must remain very small and tight (11px - 14px).
2.  **Font Pairings**:
    *   Brutalist/Modern: *Neue Montreal / Suisse Intl*
    *   Display/Expressive: *PP Neue Machina* or *The Future*
    *   Serifs for cinematic tension: *PP Fragment Glare*
    *   Code/Data: *PP Fraktion Mono*

### B. Color Tokens (`app_colors.dart`)
*The system integrates the following extracted hex codes as specific thematic variants:*
*   **`#070808`**: The ultimate "True Dark" background.
*   **`#E6E6E6` / `#E5E5E5` / `#E8ECF2`**: The "Off-White" / "Cool Grey" backgrounds for light modes.
*   **`#01FFEA`**: Neon Cyan accent.
*   **`#2B00FF`**: Electric Blue accent.
*   **`#ECACAC`**: Pastel Pink accent.
*   **`#054646`**: Deep Teal accent.

### C. Visual Effects & Cursors (`effects/`, `components/custom_cursor.dart`)
*   **Custom Cursors**: Includes blend modes (difference) and magnetic snapping to links, derived directly from the p5aholic and obake.blue interaction styles.
*   **Border Radii**: Strict usage of either `0px` (Brutalist/p5aholic/obake) or heavily rounded `18px-24px` (Starpeggio) — avoid middle-ground values like 4px or 8px for major components.
*   **Backgrounds**: Noise overlays (grain) and WebGL-style distorted shaders.

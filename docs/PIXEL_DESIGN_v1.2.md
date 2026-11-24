# Battle Tap – Pixel UI Design v1.2

Approved concept references: three pixel-art images provided by the project owner on 24 November 2026.

## Palette
- Background: near-black forest green (#061709).
- Panels: deep green (#0C260E).
- Gameboy highlights: pale-lime (#C5FF87) and cream (#E8FFB7).
- Secondary outlines: forest sage (#76B65C).
- Golden Splash: pixel gold (#FFD74B).
- Normal skins have 5 distinct colour accents; Epic and Legend are brighter and individually illuminated.

## Components implemented
- RetroBackdrop: fixed pixel stars, mountainous bottom terrain, background gradient.
- RetroPanel: angular pixel-edge panels, corner highlights, hard shadows, glow.
- RetroAction: large arcade menu buttons.
- SkinEmblem: pixel-geometry CustomPainter drawing 16 different silhouettes (Classic + 15 buyable previews).
- GoldenRecordSplash: 3-second gold jets, droplets and pixel confetti.
- Local games and menus: Player can inspect Shop, Ranked placeholder, Friends placeholder and Profile.

## Skin performance
All emblems render directly in Flutter with a CustomPainter (no bitmap scaling artifact dependencies). Epic and Legendary emblems are animated only when the widget is visible. Normal accents do not pretend to be purchased. Every skin shares the same official 44% Ranked hit diameter.

## GDD limitations
The visual implementation is a working first pass, not an exact pixel-for-pixel copy of the reference art. In-app purchasing, use of the original branded logo art, official server Rank, audio packs, account login and richer sprite-sheet animations still require production integration.

The concept board's diamonds and currency values are *decorative mockup examples*, not a new premium-currency feature. The GDD continues to prescribe direct store purchases.

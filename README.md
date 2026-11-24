# BATTLE TAP – Pixel Arcade

Flutter Android/iOS **local test version** for Battle Tap 1.1.

## New visual direction (24 November 2026)

- Dark Gameboy-inspired pixel art UI: luminous sage/lime accents, deep forest-green panels, chunky framed arcade controls and backgrounds.
- Fifteen individual **procedurally drawn** button skins: 5 Normal (coloured), 5 Epic (animated tech / elemental motifs) and 5 Legend (animated mythic silhouettes).
- No plain circular epic/legend skins. The tap art changes, but the hit area does not.
- Animated full-screen Golden Splash on a new **local** Tap Battle best result.
- Both games retain their locked 1.1 rules.
- Local best scores and statistics are persisted through shared_preferences.
- Unverified online scores and paid skins are **not** falsely represented as live.

## Start the app

From this repo:

\`\`\`sh
flutter create --platforms=android,ios --project-name battle_tap --org ch.battletap .
flutter pub get
flutter test
flutter run
\`\`\`

A GitHub Actions workflow runs Flutter analysis, tests and a debug APK build.
Download the APK ZIP from the workflow's **Artifacts** section.

## Locked game rules

| Rule | Value |
| --- | --- |
| Tap Battle | 30 seconds |
| Tap target | Centrally fixed, exactly 44% of logical screen width |
| Random Hunt | Visible random 18–60 seconds timer |
| Random movement | After every hit; otherwise at ~1,000 ms |
| Wrong target | 0 points |
| Stop phase | 2 seconds after time expires |
| Late taps | −2 points each |
| Public rankings | Tap Battle ONLY (not live until backend verification) |

## Production work outstanding

Firebase Authentication, identity and country verification, server-verified Ranked leaderboards, friend requests/challenges, Apple/Google IAP purchase verification and skin ownership, Play Integrity/App Attest security, final game graphics/art direction and full real-device testing. **This is not yet a production-ready app or a Play Store release.**

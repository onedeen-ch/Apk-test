# BATTLE TAP

Competitive arcade / reaction mobile game.

## Current branch

This branch contains a playable Flutter **local prototype** with two game modes and a shop catalogue.

### Locked game rules

- **TAP BATTLE:** 30.00 seconds, centred immovable button at **44%** of the available screen width, +1 point for each valid touch.
- **RANDOM HUNT:** randomly chosen **18–60 seconds** with a visible countdown. Smaller target moves instantly on a hit, or automatically after **1.0 seconds** without a hit.
- Misses do not count. For the **2-second stop phase**, every late tap applies **−2 points**.
- Only TAP BATTLE should ever contribute to public ranked leaderboards.

### Build

Requires Flutter SDK. Run:

```bash
flutter create --platforms=android,ios --project-name battle_tap --org ch.battletap .
flutter pub get
flutter test
flutter run
```

A GitHub Actions debug-APK workflow is included.

### Incomplete production features

This is **not yet a release-ready product**. Firebase login, server-verified global/country/friends leaderboards, IAP purchase verification, actual paid skin unlocks, advanced golden-splash animation, and full anti-cheat safeguards remain to integrate. No fake rankings or unverified purchases are displayed. The 15 premium skins currently appear as locked catalogue entries.

See the original GDD v1.1 for all product requirements.

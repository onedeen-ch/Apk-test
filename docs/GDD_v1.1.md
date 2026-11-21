# Battle Tap – GDD v1.1 (locked specification)

Platforms: Android & iOS. Technology target: Flutter, Flame, Firebase. Business model: free game with cosmetic purchases.

## Ranked – TAP BATTLE
30.00 seconds; a fixed central button exactly 44% of logical screen width; +1 valid tap; no pause or points after the timer; server-verified scores and global/country/friends rankings (weekly & all-time).

## RANDOM HUNT
Random round duration 18–60 seconds with visible countdown. Smaller button changes position immediately after a valid hit, otherwise approximately every 1.0 seconds. A miss counts zero. When time expires the button disappears; a STOP indicator shows for two seconds, during which every tap anywhere in the arena subtracts two points. Final score may be negative. No public Random Hunt leaderboard.

## Accounts
Mandatory login with Google, Apple or email. Public nickname, country, friend tag, private email, account deletion. Friend requests, blocking, asynchronous score challenges.

## Shop
Free Classic skin. Five NORMAL skins: Red Strike, Ocean Blue, Toxic Green, Royal Purple, Golden Yellow (CHF 0.90 proposal each). Five EPIC: Neon Pulse, Inferno Core, Plasma Venom, Thunder Violet, Frozen Prism (CHF 2.90). Five LEGEND: Solar Deity, Void Dragon, Phoenix Heart, Celestial Crown, Cosmic Singularity (CHF 5.90). Cosmetics only, never change tap area. Real IAP via Apple/Google stores with server-side receipts.

## Effects
For a newly verified personal ranked record, a full-screen gold splash: sprays of liquid gold, gold droplets, rays, falling confetti, victory sound, skippable ~3 seconds.

## Technology & protection
Flutter + Flame, Firebase Authentication, Firestore, Cloud Functions, Play Integrity/App Attest. Signed server sessions, event plausibility checks, anti-spam, purchase validation. Clients cannot write verified leaderboard scores directly. Admin moderation and deletion flows are required.

## Release acceptance
The application cannot be called production-ready until all above features are implemented and validated on real Android and iOS devices.

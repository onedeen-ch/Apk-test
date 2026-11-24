import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gold_splash.dart';
import 'pixel_ui.dart';
import 'skins.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BattleTapApp());
}

/// Locked Battle Tap 1.1 rules. No skin or animation may modify scoring.
abstract final class BattleRules {
  static const int rankedSeconds = 30;
  static const double rankedButtonWidthRatio = .44;
  static const int randomMinSeconds = 18;
  static const int randomMaxSeconds = 60;
  static const int randomMoveMilliseconds = 1000;
  static const int stopSeconds = 2;
  static const int lateTapPenalty = 2;

  static int randomDuration(math.Random rng) =>
      randomMinSeconds +
      rng.nextInt(randomMaxSeconds - randomMinSeconds + 1);

  static int huntScore(int validTaps, int lateTaps) =>
      validTaps - lateTaps * lateTapPenalty;
}

class GameRecords extends ChangeNotifier {
  int rankedBest = 0;
  int huntBest = 0;
  int rounds = 0;
  int totalTaps = 0;
  bool vibrationsEnabled = false;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      rankedBest = prefs.getInt('battle_ranked_best') ?? 0;
      huntBest = prefs.getInt('battle_hunt_best') ?? 0;
      rounds = prefs.getInt('battle_rounds') ?? 0;
      totalTaps = prefs.getInt('battle_total_taps') ?? 0;
      vibrationsEnabled = prefs.getBool('battle_haptics') ?? false;
      notifyListeners();
    } catch (_) {
      // In widget tests or platforms without the preferences plugin, the
      // playable local prototype remains available with in-memory records.
    }
  }

  Future<void> record({required bool ranked, required int score, required int hits}) async {
    rounds += 1;
    totalTaps += hits;
    if (ranked) {
      rankedBest = math.max(rankedBest, score);
    } else {
      huntBest = math.max(huntBest, score);
    }
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt('battle_ranked_best', rankedBest);
      await p.setInt('battle_hunt_best', huntBest);
      await p.setInt('battle_rounds', rounds);
      await p.setInt('battle_total_taps', totalTaps);
    } catch (_) {}
  }

  Future<void> toggleVibration(bool value) async {
    vibrationsEnabled = value;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool('battle_haptics', value);
    } catch (_) {}
  }
}

class BattleTapApp extends StatefulWidget {
  const BattleTapApp({super.key});
  @override
  State<BattleTapApp> createState() => _BattleTapAppState();
}

class _BattleTapAppState extends State<BattleTapApp> {
  final GameRecords records = GameRecords();

  @override
  void initState() {
    super.initState();
    unawaited(records.load());
  }

  @override
  void dispose() {
    records.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Battle Tap',
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ArcadeColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ArcadeColors.neon,
        brightness: Brightness.dark,
      ),
      fontFamily: 'monospace',
      useMaterial3: true,
    ),
    home: ArcadeHome(records: records),
  );
}

class ArcadeHome extends StatefulWidget {
  const ArcadeHome({super.key, required this.records});
  final GameRecords records;

  @override
  State<ArcadeHome> createState() => _ArcadeHomeState();
}

class _ArcadeHomeState extends State<ArcadeHome> {
  void openPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void openGame(bool ranked) {
    openPage(BattleGamePage(
      ranked: ranked,
      skin: BattleSkins.at(0),
      best: ranked ? widget.records.rankedBest : widget.records.huntBest,
      vibrate: widget.records.vibrationsEnabled,
      onFinish: (score, hits) => widget.records.record(
        ranked: ranked, score: score, hits: hits),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: RetroBackground(
      child: SafeArea(child: AnimatedBuilder(
        animation: widget.records,
        builder: (context, _) => LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 35),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: math.max(0, c.maxHeight - 59)),
              child: Column(children: [
                const SizedBox(height: 13),
                const Icon(Icons.sports_martial_arts,
                  size: 36, color: ArcadeColors.neon),
                const SizedBox(height: 14),
                const _BattleLogo(),
                const SizedBox(height: 13),
                const RetroText('PIXEL ARCADE • REACTION BATTLE',
                  size: 11, color: ArcadeColors.muted, align: TextAlign.center),
                const SizedBox(height: 27),
                RetroPanel(child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const RetroText('LOCAL BEST', size: 11, color: ArcadeColors.muted),
                      const SizedBox(height: 5),
                      RetroText(widget.records.rankedBest.toString() + ' TAPS',
                        size: 21, color: ArcadeColors.neon),
                    ]),
                    const Icon(Icons.emoji_events, size: 32, color: ArcadeColors.gold),
                  ],
                )),
                const SizedBox(height: 26),
                RetroAction(label: 'PLAY', icon: Icons.play_arrow,
                  primary: true, onTap: () => openPage(ModeSelectPage(onPlay: openGame))),
                const SizedBox(height: 17),
                RetroAction(label: 'RANKS', icon: Icons.emoji_events,
                  onTap: () => openPage(const RankingsPage())),
                const SizedBox(height: 14),
                RetroAction(label: 'SHOP', icon: Icons.storefront,
                  onTap: () => openPage(const BattleShopPage())),
                const SizedBox(height: 14),
                RetroAction(label: 'FRIENDS', icon: Icons.people,
                  onTap: () => openPage(const FriendsPage())),
                const SizedBox(height: 14),
                RetroAction(label: 'PROFILE', icon: Icons.person,
                  onTap: () => openPage(ProfilePage(records: widget.records))),
                const SizedBox(height: 20),
                const RetroText('PREVIEW BUILD • LOCAL SCORES',
                  size: 10, color: ArcadeColors.muted, align: TextAlign.center),
              ]),
            ),
          ),
        ),
      )),
    ),
  );
}

class _BattleLogo extends StatelessWidget {
  const _BattleLogo();
  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -.015,
    child: RetroPanel(glow: true, highlight: true,
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 18),
      child: const Column(children: [
        RetroText('BATTLE', size: 41, color: ArcadeColors.dark, spacing: -1.5,
          align: TextAlign.center),
        RetroText('TAP', size: 58, color: ArcadeColors.dark, spacing: 1,
          align: TextAlign.center),
        Icon(Icons.touch_app, color: ArcadeColors.dark, size: 32),
      ]),
    ),
  );
}

class ModeSelectPage extends StatelessWidget {
  const ModeSelectPage({super.key, required this.onPlay});
  final ValueChanged<bool> onPlay;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: RetroBackground(child: SafeArea(child: Column(children: [
      RetroHeader(title: 'SELECT MODE', onBack: () => Navigator.pop(context)),
      Expanded(child: ListView(padding: const EdgeInsets.all(20), children: [
        RetroPanel(glow: true, child: Column(children: [
          const Icon(Icons.ads_click, color: ArcadeColors.neon, size: 48),
          const SizedBox(height: 10),
          const RetroText('TAP BATTLE', size: 26, color: ArcadeColors.neon),
          const SizedBox(height: 9),
          const RetroText('30 SECONDS • FIXED TARGET • 44% WIDTH',
            size: 11, align: TextAlign.center, color: ArcadeColors.muted),
          const SizedBox(height: 15),
          RetroAction(label: 'START BATTLE', icon: Icons.play_arrow,
            primary: true, onTap: () => onPlay(true)),
        ])),
        const SizedBox(height: 20),
        RetroPanel(child: Column(children: [
          const Icon(Icons.track_changes, color: ArcadeColors.neon, size: 48),
          const SizedBox(height: 10),
          const RetroText('RANDOM HUNT', size: 26, color: ArcadeColors.neon),
          const SizedBox(height: 9),
          const RetroText('18–60 SEC • MOVING TARGET • −2 LATE TAP',
            size: 11, align: TextAlign.center, color: ArcadeColors.muted),
          const SizedBox(height: 15),
          RetroAction(label: 'START HUNT', icon: Icons.play_arrow,
            onTap: () => onPlay(false)),
        ])),
        const SizedBox(height: 20),
        const RetroText('Online ranked sessions will be activated after '
          'secure server verification is connected.',
          size: 10, color: ArcadeColors.muted, align: TextAlign.center),
      ])),
    ]))),
  );
}

class RankingsPage extends StatefulWidget {
  const RankingsPage({super.key});
  @override
  State<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  int selected = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: RetroBackground(child: SafeArea(child: Column(children: [
      RetroHeader(title: 'RANKINGS', onBack: () => Navigator.pop(context)),
      Padding(padding: const EdgeInsets.all(16), child: Row(
        children: List.generate(3, (i) => Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: RetroAction(
            compact: true,
            label: const ['GLOBAL', 'COUNTRY', 'FRIENDS'][i],
            icon: const [Icons.public, Icons.flag, Icons.people][i],
            primary: selected == i,
            onTap: () => setState(() => selected = i),
          ),
        ))),
      )),
      const Spacer(),
      const Icon(Icons.emoji_events_outlined, size: 92, color: ArcadeColors.border),
      const SizedBox(height: 18),
      const RetroText('ONLINE RANKS', size: 25, color: ArcadeColors.neon),
      const SizedBox(height: 10),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 35),
        child: RetroText('Requires Firebase, verified game sessions and '
          'anti-cheat checks. No fake rankings will be shown.',
          size: 13, color: ArcadeColors.muted, align: TextAlign.center),
      ),
      const Spacer(),
      const Padding(
        padding: EdgeInsets.all(20),
        child: RetroText('WEEKLY  •  ALL TIME',
          color: ArcadeColors.muted, size: 12, align: TextAlign.center),
      ),
    ]))),
  );
}

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: RetroBackground(child: SafeArea(child: Column(children: [
      RetroHeader(title: 'FRIENDS', onBack: () => Navigator.pop(context)),
      const Spacer(),
      const Icon(Icons.group_add, color: ArcadeColors.neon, size: 95),
      const SizedBox(height: 18),
      const RetroText('FRIEND BATTLES', color: ArcadeColors.neon, size: 23),
      const SizedBox(height: 12),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 34),
        child: RetroText('Player tags, friend requests and challenges '
          'will unlock after Firebase integration.',
          color: ArcadeColors.muted, size: 13, align: TextAlign.center)),
      const Spacer(),
    ]))),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.records});
  final GameRecords records;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: RetroBackground(child: SafeArea(child: Column(children: [
      RetroHeader(title: 'PROFILE', onBack: () => Navigator.pop(context)),
      Expanded(child: AnimatedBuilder(
        animation: records,
        builder: (context, _) => ListView(padding: const EdgeInsets.all(20), children: [
          const RetroPanel(glow: true, child: Column(children: [
            Icon(Icons.account_circle, color: ArcadeColors.neon, size: 60),
            SizedBox(height: 10),
            RetroText('LOCAL PLAYER', size: 23, color: ArcadeColors.neon),
            SizedBox(height: 5),
            RetroText('Account registration is not connected yet.',
              size: 11, color: ArcadeColors.muted, align: TextAlign.center),
          ])),
          const SizedBox(height: 22),
          _stat('TAP BATTLE BEST', records.rankedBest.toString()),
          _stat('RANDOM HUNT BEST', records.huntBest.toString()),
          _stat('ROUNDS PLAYED', records.rounds.toString()),
          _stat('VALID TAPS', records.totalTaps.toString()),
          const SizedBox(height: 15),
          RetroPanel(child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const RetroText('VIBRATION', size: 14),
            value: records.vibrationsEnabled,
            onChanged: records.toggleVibration,
          )),
        ]),
      )),
    ]))),
  );

  Widget _stat(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: RetroPanel(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(child: RetroText(label, size: 13, color: ArcadeColors.muted)),
      RetroText(value, size: 23, color: ArcadeColors.neon),
    ])),
  );
}

class BattleShopPage extends StatefulWidget {
  const BattleShopPage({super.key});
  @override
  State<BattleShopPage> createState() => _BattleShopPageState();
}

class _BattleShopPageState extends State<BattleShopPage> {
  SkinTier tier = SkinTier.legend;

  @override
  Widget build(BuildContext context) {
    final collection = BattleSkins.all.where((s) =>
      s.tier == tier || (tier == SkinTier.normal && s.tier == SkinTier.classic)).toList();
    return Scaffold(
      body: RetroBackground(
        child: SafeArea(child: Column(children: [
          RetroHeader(title: 'BATTLE SHOP',
            onBack: () => Navigator.pop(context),
            trailing: const Icon(Icons.diamond, color: ArcadeColors.neon)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Row(children: [
              for (final choice in const [SkinTier.normal, SkinTier.epic, SkinTier.legend])
                Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: RetroAction(
                    compact: true,
                    label: choice.name.toUpperCase(),
                    icon: choice == SkinTier.legend ? Icons.auto_awesome :
                      choice == SkinTier.epic ? Icons.bolt : Icons.star_border,
                    primary: tier == choice,
                    onTap: () => setState(() => tier = choice),
                  ),
                )),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 5),
            child: RetroText('TAP ANY SKIN TO PREVIEW ITS EFFECTS',
              color: ArcadeColors.muted, size: 10, align: TextAlign.center),
          ),
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            const gap = 12.0;
            const padding = 16.0;
            final width = (constraints.maxWidth - padding * 2 - gap) / 2;
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(padding, 12, padding, 30),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: gap,
                mainAxisSpacing: gap,
                mainAxisExtent: math.max(202, width + 72),
              ),
              itemCount: collection.length,
              itemBuilder: (_, i) => _SkinShopTile(skin: collection[i]),
            );
          })),
        ])),
      ),
    );
  }
}

class _SkinShopTile extends StatelessWidget {
  const _SkinShopTile({required this.skin});
  final BattleSkin skin;

  void preview(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: ArcadeColors.bg,
      insetPadding: const EdgeInsets.all(22),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          RetroText(skin.name, size: 21,
            color: skin.accent, align: TextAlign.center),
          const SizedBox(height: 9),
          RetroText(skin.tierName, size: 13,
            color: ArcadeColors.muted),
          const SizedBox(height: 20),
          SkinEmblem(skin: skin, size: 240),
          const SizedBox(height: 17),
          if (skin.id != 0)
            RetroText('CHF ' + skin.price.toStringAsFixed(2) + ' • PREVIEW ONLY',
              size: 12, color: ArcadeColors.gold),
          const SizedBox(height: 10),
          RetroText(skin.id == 0 ? 'FREE STANDARD SKIN' :
            'Store purchases not connected in this test build.',
            size: 11, color: ArcadeColors.muted, align: TextAlign.center),
          const SizedBox(height: 18),
          RetroAction(label: 'CLOSE', icon: Icons.close,
            compact: true, onTap: () => Navigator.pop(dialogContext)),
        ]),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => preview(context),
      child: RetroPanel(glow: skin.tier == SkinTier.legend,
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
        child: Column(children: [
          Expanded(child: FittedBox(
            fit: BoxFit.contain,
            child: SkinEmblem(skin: skin, size: 133),
          )),
          const SizedBox(height: 4),
          RetroText(skin.name, size: 11, align: TextAlign.center, maxLines: 2,
            color: skin.accent),
          const SizedBox(height: 4),
          RetroText(skin.id == 0 ? 'EQUIPPED' :
            'CHF ' + skin.price.toStringAsFixed(2),
            size: 10, align: TextAlign.center,
            color: skin.id == 0 ? ArcadeColors.neon : ArcadeColors.gold),
        ]),
      ),
    );
  }
}

enum GamePhase { ready, countdown, active, stop, finished, interrupted }

class BattleGamePage extends StatefulWidget {
  const BattleGamePage({
    super.key,
    required this.ranked,
    required this.skin,
    required this.best,
    required this.vibrate,
    required this.onFinish,
  });
  final bool ranked;
  final BattleSkin skin;
  final int best;
  final bool vibrate;
  final void Function(int score, int hits) onFinish;

  @override
  State<BattleGamePage> createState() => _BattleGamePageState();
}

class _BattleGamePageState extends State<BattleGamePage> with WidgetsBindingObserver {
  final math.Random _rng = math.Random.secure();
  final Stopwatch _clock = Stopwatch();
  Timer? _frameTimer;
  Timer? _countdownTimer;
  GamePhase _phase = GamePhase.ready;
  int _countdown = 3;
  int _duration = BattleRules.rankedSeconds;
  int _score = 0, _hits = 0, _misses = 0, _lateTaps = 0;
  int _lastMovedMs = 0;
  int _best = 0;
  int? _pointer;
  double _secondsLeft = 30;
  Offset _target = const Offset(.5, .5);
  bool _pressed = false, _showSplash = false, _newRecord = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _best = widget.best;
    _duration = widget.ranked
      ? BattleRules.rankedSeconds : BattleRules.randomDuration(_rng);
    _secondsLeft = _duration.toDouble();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed &&
        (_phase == GamePhase.active || _phase == GamePhase.countdown ||
         _phase == GamePhase.stop)) {
      _countdownTimer?.cancel();
      _frameTimer?.cancel();
      _clock.stop();
      if (mounted) setState(() {
        _phase = GamePhase.interrupted;
        _showSplash = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _frameTimer?.cancel();
    _countdownTimer?.cancel();
    _clock.stop();
    super.dispose();
  }

  void _start() {
    _frameTimer?.cancel();
    _countdownTimer?.cancel();
    _clock..stop()..reset();
    setState(() {
      _countdown = 3;
      _score = 0;
      _hits = 0;
      _misses = 0;
      _lateTaps = 0;
      _target = const Offset(.5, .5);
      _duration = widget.ranked
        ? BattleRules.rankedSeconds : BattleRules.randomDuration(_rng);
      _secondsLeft = _duration.toDouble();
      _lastMovedMs = 0;
      _pointer = null;
      _pressed = false;
      _showSplash = false;
      _newRecord = false;
      _phase = GamePhase.countdown;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _phase != GamePhase.countdown) {
        timer.cancel();
        return;
      }
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        _clock.start();
        setState(() => _phase = GamePhase.active);
        _frameTimer = Timer.periodic(
          const Duration(milliseconds: 16), (_) => _tick());
      }
    });
  }

  void _tick() {
    if (!mounted) return;
    final elapsed = _clock.elapsedMilliseconds;
    if (_phase == GamePhase.active) {
      final remaining = math.max(0, _duration * 1000 - elapsed);
      if (remaining == 0) {
        setState(() {
          _secondsLeft = 0;
          _pressed = false;
          _phase = widget.ranked ? GamePhase.finished : GamePhase.stop;
        });
        if (widget.ranked) _finish();
        return;
      }
      if (!widget.ranked &&
          elapsed - _lastMovedMs >= BattleRules.randomMoveMilliseconds) {
        _move(elapsed);
      }
      setState(() => _secondsLeft = remaining / 1000);
    } else if (_phase == GamePhase.stop &&
        elapsed >= (_duration + BattleRules.stopSeconds) * 1000) {
      _finish();
    }
  }

  void _move(int nowMs) {
    Offset next = _target;
    var attempts = 0;
    do {
      next = Offset(_rng.nextDouble(), _rng.nextDouble());
      attempts++;
    } while ((next - _target).distance < .25 && attempts < 25);
    _target = next;
    _lastMovedMs = nowMs;
  }

  void _finish() {
    if (_phase == GamePhase.interrupted ||
        (_phase == GamePhase.finished && _frameTimer == null)) return;
    _frameTimer?.cancel();
    _frameTimer = null;
    _clock.stop();
    _newRecord = widget.ranked && _score > _best;
    if (_newRecord) _best = _score;
    widget.onFinish(_score, _hits);
    if (mounted) setState(() {
      _phase = GamePhase.finished;
      _showSplash = _newRecord;
    });
  }

  Offset _center(Size area, double diameter) {
    if (widget.ranked) {
      return Offset(area.width / 2, area.height / 2);
    }
    final inset = diameter / 2 + 8;
    return Offset(
      inset + _target.dx * math.max(0, area.width - inset * 2),
      inset + _target.dy * math.max(0, area.height - inset * 2),
    );
  }

  void _pointerDown(PointerDownEvent e, Size area, double diameter) {
    if (_pointer != null) return; // One concurrent touch maximum.
    _pointer = e.pointer;
    if (_phase == GamePhase.stop && !widget.ranked) {
      // Every new tap anywhere in the arena after STOP costs two points.
      setState(() {
        _lateTaps++;
        _score = BattleRules.huntScore(_hits, _lateTaps);
      });
      if (widget.vibrate) HapticFeedback.selectionClick();
      return;
    }
    if (_phase != GamePhase.active) return;
    if (_clock.elapsedMilliseconds >= _duration * 1000) {
      _tick();
      if (_phase == GamePhase.stop) {
        setState(() {
          _lateTaps++;
          _score = BattleRules.huntScore(_hits, _lateTaps);
        });
      }
      return;
    }
    final inTarget = (e.localPosition - _center(area, diameter)).distance
        <= diameter / 2;
    if (inTarget) {
      setState(() {
        _hits++;
        _score++;
        _pressed = true;
        if (!widget.ranked) _move(_clock.elapsedMilliseconds);
      });
      if (widget.vibrate && _hits % 5 == 0) HapticFeedback.selectionClick();
    } else if (!widget.ranked) {
      setState(() => _misses++);
    }
  }

  void _pointerEnd(int id) {
    if (_pointer == id) {
      _pointer = null;
      if (_pressed && mounted) setState(() => _pressed = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(children: [
      RetroBackground(showLand: false, child: SafeArea(child: Column(children: [
        RetroHeader(
          title: widget.ranked ? 'TAP BATTLE' : 'RANDOM HUNT',
          onBack: () => Navigator.pop(context),
          trailing: const Icon(Icons.bolt, color: ArcadeColors.neon)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Row(children: [
            _metric('BEST', _best.toString(), 1),
            const SizedBox(width: 7),
            _metric('SCORE', _score.toString(), 1.25),
            const SizedBox(width: 7),
            _metric('TIME', _secondsLeft.toStringAsFixed(2), 1.1),
          ]),
        ),
        Expanded(child: LayoutBuilder(builder: (context, constraints) {
          final area = Size(constraints.maxWidth, constraints.maxHeight);
          final diameter = widget.ranked
            ? area.width * BattleRules.rankedButtonWidthRatio
            : math.min(area.width * .215, math.max(62.0, area.height * .18));
          final center = _center(area, diameter);
          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) => _pointerDown(e, area, diameter),
            onPointerUp: (e) => _pointerEnd(e.pointer),
            onPointerCancel: (e) => _pointerEnd(e.pointer),
            child: Stack(children: [
              if (_phase == GamePhase.active)
                Positioned(
                  left: center.dx - diameter / 2,
                  top: center.dy - diameter / 2,
                  width: diameter,
                  height: diameter,
                  child: RepaintBoundary(child: SkinEmblem(
                    skin: widget.skin, size: diameter, pressed: _pressed)),
                ),
              if (_phase != GamePhase.active)
                Center(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _phaseContent(),
                )),
            ]),
          );
        })),
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 9, 8, 15),
          child: RetroText('LOCAL TEST • NO ONLINE RANKING',
            size: 10, color: ArcadeColors.muted, align: TextAlign.center)),
      ]))),
      if (_showSplash)
        GoldenRecordSplash(
          score: _score,
          onDone: () {
            if (mounted) setState(() => _showSplash = false);
          },
        ),
    ]),
  );

  Widget _metric(String label, String value, double flex) => Expanded(
    flex: (flex * 100).round(),
    child: RetroPanel(padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
      child: Column(children: [
        RetroText(label, size: 11, color: ArcadeColors.muted, align: TextAlign.center),
        const SizedBox(height: 4),
        RetroText(value, size: 21, color: ArcadeColors.neon, align: TextAlign.center,
          maxLines: 1, spacing: -.8),
      ]),
    ),
  );

  Widget _phaseContent() {
    switch (_phase) {
      case GamePhase.ready:
        return Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.touch_app, size: 80, color: ArcadeColors.neon),
          const SizedBox(height: 20),
          const RetroText('READY?', size: 34, color: ArcadeColors.neon),
          const SizedBox(height: 17),
          RetroText(widget.ranked
            ? '30 SECONDS • HIT THE FIXED TARGET'
            : 'FOLLOW THE TARGET • STOP AT ZERO!',
            size: 12, color: ArcadeColors.muted, align: TextAlign.center),
          const SizedBox(height: 27),
          RetroAction(label: 'START', icon: Icons.play_arrow,
            primary: true, onTap: _start),
        ]);
      case GamePhase.countdown:
        return RetroText(_countdown.toString(), size: 88, color: ArcadeColors.neon);
      case GamePhase.stop:
        return const Column(mainAxisSize: MainAxisSize.min, children: [
          RetroText('STOP!', size: 51, color: Color(0xFFFF6359)),
          SizedBox(height: 9),
          RetroText('−2 PER EXTRA TAP', size: 18, color: Color(0xFFFFA59B)),
        ]);
      case GamePhase.finished:
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(_newRecord ? Icons.emoji_events : Icons.check_circle_outline,
            size: 74, color: _newRecord ? ArcadeColors.gold : ArcadeColors.neon),
          const SizedBox(height: 15),
          RetroText(_newRecord ? 'NEW LOCAL RECORD!' : 'BATTLE COMPLETE',
            size: 23, color: _newRecord ? ArcadeColors.gold : ArcadeColors.neon,
            align: TextAlign.center),
          const SizedBox(height: 16),
          RetroText(_score.toString() + ' POINTS',
            size: 37, color: ArcadeColors.cream, align: TextAlign.center),
          const SizedBox(height: 12),
          if (!widget.ranked)
            RetroText(_hits.toString() + ' HITS  •  ' +
              _misses.toString() + ' MISSES  •  ' +
              _lateTaps.toString() + ' LATE',
              size: 11, color: ArcadeColors.muted, align: TextAlign.center),
          const SizedBox(height: 25),
          RetroAction(label: 'PLAY AGAIN', icon: Icons.replay,
            primary: true, onTap: _start),
          const SizedBox(height: 12),
          RetroAction(label: 'BACK', icon: Icons.arrow_back,
            compact: true, onTap: () => Navigator.pop(context)),
        ]);
      case GamePhase.interrupted:
        return Column(mainAxisSize: MainAxisSize.min, children: [
          const RetroText('ROUND INTERRUPTED',
            size: 23, color: ArcadeColors.gold, align: TextAlign.center),
          const SizedBox(height: 14),
          const RetroText('The app was paused. This local score was not saved.',
            size: 12, color: ArcadeColors.muted, align: TextAlign.center),
          const SizedBox(height: 24),
          RetroAction(label: 'RESTART', icon: Icons.replay,
            primary: true, onTap: _start),
        ]);
      case GamePhase.active:
        return const SizedBox.shrink();
    }
  }
}

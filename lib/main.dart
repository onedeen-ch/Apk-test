import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const BattleTapApp());

class BattleRules {
  static const rankedSeconds = 30;
  static const rankedButtonWidthRatio = 0.44;
  static const randomMinSeconds = 18;
  static const randomMaxSeconds = 60;
  static const randomMoveMilliseconds = 1000;
  static const stopSeconds = 2;
  static const lateTapPenalty = 2;
  static int randomDuration(Random rng) =>
      randomMinSeconds + rng.nextInt(randomMaxSeconds - randomMinSeconds + 1);
  static int huntScore(int validTaps, int lateTaps) =>
      validTaps - lateTaps * lateTapPenalty;
}

class BattleSkin {
  const BattleSkin(this.name, this.color, this.rarity, this.price);
  final String name;
  final Color color;
  final String rarity;
  final double price;
}

const skins = <BattleSkin>[
  BattleSkin('Classic', Color(0xFFDA2D4B), 'FREE', 0),
  BattleSkin('Red Strike', Color(0xFFE83E50), 'NORMAL', 0.90),
  BattleSkin('Ocean Blue', Color(0xFF1689F7), 'NORMAL', 0.90),
  BattleSkin('Toxic Green', Color(0xFF39DB6B), 'NORMAL', 0.90),
  BattleSkin('Royal Purple', Color(0xFF914CEB), 'NORMAL', 0.90),
  BattleSkin('Golden Yellow', Color(0xFFFFCE36), 'NORMAL', 0.90),
  BattleSkin('Neon Pulse', Color(0xFF02EFDF), 'EPIC', 2.90),
  BattleSkin('Inferno Core', Color(0xFFFF5B32), 'EPIC', 2.90),
  BattleSkin('Plasma Venom', Color(0xFF6FFF24), 'EPIC', 2.90),
  BattleSkin('Thunder Violet', Color(0xFFB254FF), 'EPIC', 2.90),
  BattleSkin('Frozen Prism', Color(0xFFB1EDFF), 'EPIC', 2.90),
  BattleSkin('Solar Deity', Color(0xFFFFD05A), 'LEGEND', 5.90),
  BattleSkin('Void Dragon', Color(0xFF7932C9), 'LEGEND', 5.90),
  BattleSkin('Phoenix Heart', Color(0xFFFF542D), 'LEGEND', 5.90),
  BattleSkin('Celestial Crown', Color(0xFFFFE9AF), 'LEGEND', 5.90),
  BattleSkin('Cosmic Singularity', Color(0xFF6262F2), 'LEGEND', 5.90),
];

class BattleTapApp extends StatelessWidget {
  const BattleTapApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Battle Tap',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0C101D),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFD466), brightness: Brightness.dark),
      useMaterial3: true,
    ),
    home: const BattleHome(),
  );
}

class BattleHome extends StatefulWidget {
  const BattleHome({super.key});
  @override
  State<BattleHome> createState() => _BattleHomeState();
}

class _BattleHomeState extends State<BattleHome> {
  int tab = 0;
  int equipped = 0;
  int best = 0;
  int huntBest = 0;
  final owned = <int>{0};
  void play(bool ranked) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) =>
      BattleGame(ranked: ranked, skin: skins[equipped], best: ranked ? best : huntBest,
        onFinish: (score) { if (mounted) setState(() {
          if (ranked && score > best) best = score;
          if (!ranked && score > huntBest) huntBest = score;
        }); })));
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 25),
        const Center(child: Text('⚡ BATTLE TAP', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900, color: Color(0xFFFFD466)))),
        const SizedBox(height: 32),
        _panel('YOUR PERSONAL BEST', '$best TAPS', 'Local practice record'),
        const SizedBox(height: 22),
        _mode('TAP BATTLE', '30 SECONDS  •  44% FIXED BUTTON', Icons.touch_app, () => play(true)),
        const SizedBox(height: 16),
        _mode('RANDOM HUNT', '18–60 SECONDS  •  MOVING TARGET', Icons.track_changes, () => play(false)),
        const SizedBox(height: 20),
        const Center(child: Text('LOCAL TEST BUILD • ONLINE FEATURES NOT CONNECTED', style: TextStyle(fontSize: 10, color: Colors.white54))),
      ]),
      ListView(padding: const EdgeInsets.all(20), children: [
        const Text('LEADERBOARDS', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _panel('GLOBAL / COUNTRY / FRIENDS', 'Coming with Firebase', 'Ranked scores must be verified server-side. Local scores are not published.'),
      ]),
      ListView(padding: const EdgeInsets.all(16), children: [
        const Text('BATTLE SHOP', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const Text('15 cosmetic skins. Payment activation requires store configuration.', style: TextStyle(color: Colors.white60)),
        const SizedBox(height: 15),
        ...List.generate(skins.length, (i) {
          final s = skins[i];
          return Card(child: ListTile(
            leading: Container(width: 43, height: 43, decoration: BoxDecoration(
              shape: BoxShape.circle, color: s.color, boxShadow: [BoxShadow(color: s.color.withValues(alpha: 0.5), blurRadius: s.rarity == 'NORMAL' ? 5 : 20)])),
            title: Text(s.name),
            subtitle: Text('${s.rarity}  •  ${s.price == 0 ? 'FREE' : 'CHF ${s.price.toStringAsFixed(2)}'}'),
            trailing: TextButton(
              onPressed: owned.contains(i) ? () => setState(() => equipped = i) : null,
              child: Text(owned.contains(i) ? (equipped == i ? 'EQUIPPED' : 'EQUIP') : 'LOCKED'),
            ),
          ));
        }),
      ]),
      ListView(padding: const EdgeInsets.all(20), children: [
        const Text('FRIENDS', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _panel('FRIEND CHALLENGES', 'Firebase required', 'Friend requests and online score challenges are not yet enabled.'),
      ]),
      ListView(padding: const EdgeInsets.all(20), children: [
        const Text('PROFILE', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _panel('TAP BATTLE', '$best', 'Local personal best'),
        _panel('RANDOM HUNT', '$huntBest', 'Local personal best'),
        _panel('ACCOUNT', 'Not connected', 'Firebase authentication still needs configuration.'),
      ]),
    ];
    return Scaffold(body: SafeArea(child: pages[tab]), bottomNavigationBar: NavigationBar(
      selectedIndex: tab, onDestinationSelected: (index) => setState(() => tab = index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.sports_esports), label: 'PLAY'),
        NavigationDestination(icon: Icon(Icons.leaderboard), label: 'RANKS'),
        NavigationDestination(icon: Icon(Icons.shopping_bag), label: 'SHOP'),
        NavigationDestination(icon: Icon(Icons.people), label: 'FRIENDS'),
        NavigationDestination(icon: Icon(Icons.person), label: 'PROFILE'),
      ],
    ));
  }

  Widget _panel(String title, String value, String subtitle) => Card(
    child: Padding(padding: const EdgeInsets.all(18), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(title, style: const TextStyle(color: Color(0xFFFFD466), fontWeight: FontWeight.bold)),
        const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white60))],
    )),
  );
  Widget _mode(String title, String subtitle, IconData icon, VoidCallback onTap) => Card(
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16),
      child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
        Icon(icon, size: 38, color: const Color(0xFFFFD466)), const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4), Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white60)),
        ])), const Icon(Icons.arrow_forward_ios),
      ]))),
  );
}

class BattleGame extends StatefulWidget {
  const BattleGame({super.key, required this.ranked, required this.skin, required this.best, required this.onFinish});
  final bool ranked;
  final BattleSkin skin;
  final int best;
  final ValueChanged<int> onFinish;
  @override
  State<BattleGame> createState() => _BattleGameState();
}

enum RoundPhase { ready, countdown, playing, stop, finished }

class _BattleGameState extends State<BattleGame> with SingleTickerProviderStateMixin {
  final _rng = Random.secure();
  final _watch = Stopwatch();
  Timer? _ticker;
  RoundPhase phase = RoundPhase.ready;
  int countdown = 3, score = 0, hits = 0, misses = 0, lateTaps = 0;
  int duration = BattleRules.rankedSeconds;
  int _lastMove = 0;
  Offset target = const Offset(0.5, 0.5);
  int? _activePointer;
  double secondsLeft = 30;
  late final AnimationController glow;

  @override
  void initState() {
    super.initState();
    duration = widget.ranked ? BattleRules.rankedSeconds : BattleRules.randomDuration(_rng);
    secondsLeft = duration.toDouble();
    glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 950))..repeat(reverse: true);
  }

  @override
  void dispose() { _ticker?.cancel(); _watch.stop(); glow.dispose(); super.dispose(); }

  void _start() {
    _ticker?.cancel();
    _watch.reset();
    setState(() { score = 0; hits = 0; misses = 0; lateTaps = 0; countdown = 3; phase = RoundPhase.countdown;
      duration = widget.ranked ? BattleRules.rankedSeconds : BattleRules.randomDuration(_rng);
      secondsLeft = duration.toDouble(); target = const Offset(0.5, 0.5); });
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (countdown > 1) { setState(() => countdown--); }
      else {
        timer.cancel(); _watch.start(); _lastMove = 0;
        setState(() { countdown = 0; phase = RoundPhase.playing; });
        _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
      }
    });
  }

  void _tick() {
    if (!mounted || (phase != RoundPhase.playing && phase != RoundPhase.stop)) return;
    final elapsed = _watch.elapsedMilliseconds;
    if (phase == RoundPhase.playing) {
      final remaining = max(0, duration * 1000 - elapsed);
      if (remaining == 0) {
        setState(() { secondsLeft = 0; phase = widget.ranked ? RoundPhase.finished : RoundPhase.stop; });
        if (widget.ranked) _finish();
        return;
      }
      if (!widget.ranked && elapsed - _lastMove >= BattleRules.randomMoveMilliseconds) {
        _moveTarget(elapsed);
      }
      setState(() => secondsLeft = remaining / 1000);
    } else if (elapsed >= (duration + BattleRules.stopSeconds) * 1000) {
      _finish();
    }
  }

  void _moveTarget(int elapsed) {
    Offset next;
    var tries = 0;
    do { next = Offset(0.14 + _rng.nextDouble() * 0.72, 0.14 + _rng.nextDouble() * 0.72); tries++; }
    while ((next - target).distance < 0.22 && tries < 24);
    setState(() { target = next; _lastMove = elapsed; });
  }

  void _finish() {
    if (phase == RoundPhase.finished && _ticker == null) return;
    _ticker?.cancel(); _ticker = null; _watch.stop();
    if (mounted) setState(() => phase = RoundPhase.finished);
    widget.onFinish(score);
  }

  void _tapDown(PointerDownEvent event, Size arena, double diameter) {
    if (_activePointer != null) return;
    _activePointer = event.pointer;
    if (phase == RoundPhase.stop && !widget.ranked) {
      setState(() { lateTaps++; score -= BattleRules.lateTapPenalty; });
      return;
    }
    if (phase != RoundPhase.playing) return;
    final center = widget.ranked ? Offset(arena.width / 2, arena.height / 2)
      : Offset(target.dx * arena.width, target.dy * arena.height);
    final isHit = (event.localPosition - center).distance <= diameter / 2;
    if (isHit) {
      setState(() { hits++; score++; });
      if (!widget.ranked) _moveTarget(_watch.elapsedMilliseconds);
    } else if (!widget.ranked) {
      setState(() => misses++);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.ranked ? 'TAP BATTLE' : 'RANDOM HUNT')),
    body: SafeArea(child: Column(children: [
      const SizedBox(height: 12),
      Text('TIME LEFT: ${secondsLeft.toStringAsFixed(2)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
      Text('SCORE: $score', style: const TextStyle(fontSize: 34, color: Color(0xFFFFD466), fontWeight: FontWeight.bold)),
      Expanded(child: LayoutBuilder(builder: (context, constraints) {
        final area = Size(constraints.maxWidth, constraints.maxHeight);
        final d = widget.ranked ? area.width * BattleRules.rankedButtonWidthRatio : min(area.width * 0.20, area.height * 0.18);
        final px = widget.ranked ? area.width / 2 : target.dx * area.width;
        final py = widget.ranked ? area.height / 2 : target.dy * area.height;
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) => _tapDown(e, area, d),
          onPointerUp: (e) { if (_activePointer == e.pointer) _activePointer = null; },
          onPointerCancel: (e) { if (_activePointer == e.pointer) _activePointer = null; },
          child: Stack(children: [
            if (phase == RoundPhase.playing) Positioned(
              left: px - d / 2, top: py - d / 2, width: d, height: d,
              child: AnimatedBuilder(animation: glow, builder: (context, child) =>
                DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [widget.skin.color, widget.skin.color.withValues(alpha: 0.7), const Color(0xFF181821)]),
                  border: Border.all(color: widget.skin.color.withValues(alpha: 0.9), width: 4),
                  boxShadow: [BoxShadow(color: widget.skin.color.withValues(alpha: widget.skin.rarity == 'FREE' ? 0.2 : (0.2 + glow.value * 0.65)), blurRadius: 15 + glow.value * 24, spreadRadius: 4)]),
                  child: const Center(child: Text('TAP!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 23, color: Colors.white))))),
            ),
            if (phase != RoundPhase.playing)
              Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(switch (phase) {
                  RoundPhase.ready => 'READY?',
                  RoundPhase.countdown => '$countdown',
                  RoundPhase.stop => 'STOP!  −2 PER TAP',
                  RoundPhase.finished => score > widget.best && widget.ranked ? '🏆 NEW RECORD!' : 'BATTLE COMPLETE',
                  _ => '',
                }, textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900,
                  color: phase == RoundPhase.stop ? Colors.redAccent : const Color(0xFFFFD466))),
                if (phase == RoundPhase.finished) ...[
                  const SizedBox(height: 12), Text('$score POINTS', style: const TextStyle(fontSize: 30)),
                  if (!widget.ranked) Text('$hits hits · $misses misses · $lateTaps late taps'),
                  const SizedBox(height: 24), FilledButton(onPressed: _start, child: const Text('PLAY AGAIN')),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('BACK TO MENU')),
                ],
                if (phase == RoundPhase.ready) ...[
                  const SizedBox(height: 20), FilledButton(onPressed: _start, child: const Text('START')),
                ],
              ])),
          ]),
        );
      })),
      const SizedBox(height: 8),
      Text('PERSONAL BEST: ${widget.best}', style: const TextStyle(color: Colors.white60)),
      const SizedBox(height: 12),
    ])),
  );
}

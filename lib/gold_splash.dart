import 'dart:math' as math;
import 'package:flutter/material.dart';

class GoldenRecordSplash extends StatefulWidget {
  const GoldenRecordSplash({super.key, required this.score, this.onDone});
  final int score;
  final VoidCallback? onDone;

  @override
  State<GoldenRecordSplash> createState() => _GoldenRecordSplashState();
}

class _GoldenRecordSplashState extends State<GoldenRecordSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDone?.call();
    });
    _controller.forward();
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final p = _controller.value;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onDone,
          child: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: GoldSprayPainter(p))),
            Center(child: Opacity(
              opacity: (p * 5).clamp(0.0, 1.0) *
                  ((1.0 - p) * 6).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: .7 + math.min(p * 2, .4),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xE60F1F06),
                    border: Border.all(color: const Color(0xFFFFEB90), width: 4),
                    boxShadow: const [
                      BoxShadow(color: Color(0xAAFFC741), blurRadius: 35),
                    ],
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('✦ NEW RECORD ✦',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'monospace',
                        fontWeight: FontWeight.w900, fontSize: 24,
                        color: Color(0xFFFFEC8B))),
                    const SizedBox(height: 12),
                    Text(widget.score.toString() + ' TAPS',
                      style: const TextStyle(fontFamily: 'monospace',
                        fontWeight: FontWeight.w900, fontSize: 34,
                        color: Color(0xFFFFF8BF))),
                    const SizedBox(height: 10),
                    const Text('TAP TO SKIP',
                      style: TextStyle(fontSize: 11, color: Color(0xFFD1BD7A))),
                  ]),
                ),
              ),
            )),
          ]),
        );
      },
    ),
  );
}

class GoldSprayPainter extends CustomPainter {
  GoldSprayPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(984);
    final fading = (1 - math.max(0, progress - .7) / .3).clamp(0.0, 1.0);
    final spray = (progress * 5).clamp(0.0, 1.0);
    const shades = [
      Color(0xFFFFD74B), Color(0xFFFFF0A0),
      Color(0xFFDA9D13), Color(0xFFFFFADE),
    ];
    final paint = Paint()..isAntiAlias = false;

    // Liquid gold jets enter from screen edges, then droplets fall down.
    for (var i = 0; i < 135; i++) {
      final fromLeft = i.isEven;
      final originX = fromLeft ? -14.0 : size.width + 14;
      final baseY = size.height * (.12 + rng.nextDouble() * .78);
      final travel = (size.width * (.2 + rng.nextDouble() * .56)) * spray;
      final y = baseY +
          math.sin((i * 2.3) + progress * 13) * 12 +
          progress * progress * 65;
      final x = originX + (fromLeft ? travel : -travel);
      final h = 2.0 + rng.nextInt(5);
      final w = (4 + rng.nextInt(16)).toDouble();
      paint.color = shades[i % shades.length].withValues(alpha: fading * .87);
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);
    }

    for (var i = 0; i < 100; i++) {
      final x = rng.nextDouble() * size.width;
      final initial = rng.nextDouble() * size.height;
      final y = (initial + progress * size.height * (.5 + rng.nextDouble())) %
          size.height;
      final side = i % 6 == 0 ? 7.0 : 3.0;
      paint.color = shades[i % shades.length].withValues(alpha: fading);
      canvas.drawRect(Rect.fromLTWH(x, y, side, side), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GoldSprayPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

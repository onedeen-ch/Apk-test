import 'dart:math' as math;
import 'package:flutter/material.dart';

abstract final class ArcadeColors {
  static const bg = Color(0xFF061709);
  static const midnight = Color(0xFF0C260E);
  static const card = Color(0xFF103618);
  static const border = Color(0xFF76B65C);
  static const neon = Color(0xFFC5FF87);
  static const cream = Color(0xFFE8FFB7);
  static const dark = Color(0xFF041309);
  static const muted = Color(0xFF91BD7D);
  static const gold = Color(0xFFFFDB76);
}

class RetroText extends StatelessWidget {
  const RetroText(this.text, {
    super.key,
    this.size = 15,
    this.color = ArcadeColors.cream,
    this.bold = true,
    this.align = TextAlign.left,
    this.spacing = 0.7,
    this.maxLines,
  });

  final String text;
  final double size;
  final Color color;
  final bool bold;
  final TextAlign align;
  final double spacing;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: align,
    maxLines: maxLines,
    overflow: maxLines == null ? null : TextOverflow.ellipsis,
    style: TextStyle(
      color: color,
      fontSize: size,
      height: 1.13,
      fontFamily: 'monospace',
      fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
      letterSpacing: spacing,
      shadows: const [Shadow(color: Color(0x773B7E2F), offset: Offset(2, 2))],
    ),
  );
}

class RetroPanel extends StatelessWidget {
  const RetroPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.glow = false,
    this.highlight = false,
  });
  final Widget child;
  final EdgeInsets padding;
  final bool glow;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: highlight ? const Color(0xFF1D4E1D) : ArcadeColors.midnight,
      border: Border.all(
        width: 3,
        color: highlight ? ArcadeColors.cream : ArcadeColors.border,
      ),
      boxShadow: [
        const BoxShadow(color: ArcadeColors.dark, offset: Offset(4, 5)),
        if (glow) const BoxShadow(
          color: Color(0x9959FF4B), blurRadius: 14, spreadRadius: 1),
      ],
    ),
    child: Stack(children: [
      child,
      const Positioned(top: 0, right: 0, child: _PixelCorner()),
      const Positioned(bottom: 0, left: 0, child: _PixelCorner()),
    ]),
  );
}

class _PixelCorner extends StatelessWidget {
  const _PixelCorner();
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 9,
    height: 9,
    child: CustomPaint(painter: _CornerPainter()),
  );
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = ArcadeColors.cream..isAntiAlias = false;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 5, 3), paint);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 3, 5), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RetroAction extends StatelessWidget {
  const RetroAction({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.primary = false,
    this.compact = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool primary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? .55 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: RetroPanel(
            glow: primary,
            highlight: primary,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 18,
              vertical: compact ? 10 : 15,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: compact ? 20 : 27,
                color: primary ? ArcadeColors.dark : ArcadeColors.cream),
              const SizedBox(width: 9),
              Flexible(child: RetroText(label,
                size: compact ? 13 : (primary ? 24 : 19),
                color: primary ? ArcadeColors.dark : ArcadeColors.cream,
                align: TextAlign.center,
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

class RetroBackground extends StatelessWidget {
  const RetroBackground({super.key, required this.child, this.showLand = true});
  final Widget child;
  final bool showLand;
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      DecoratedBox(decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.5),
          radius: 1.1,
          colors: [
            const Color(0xFF195321),
            ArcadeColors.bg,
            ArcadeColors.dark,
          ],
        ),
      )),
      IgnorePointer(child: CustomPaint(painter: _LandscapePainter(showLand))),
      child,
    ],
  );
}

class _LandscapePainter extends CustomPainter {
  _LandscapePainter(this.showLand);
  final bool showLand;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(81);
    final p = Paint()..isAntiAlias = false;
    for (var i = 0; i < 70; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * .93;
      final edge = i.isEven ? 2.0 : 3.0;
      p.color = i % 5 == 0
          ? const Color(0x7778FF65)
          : const Color(0x447AB75E);
      canvas.drawRect(Rect.fromLTWH(x.roundToDouble(),
          y.roundToDouble(), edge, edge), p);
    }
    if (showLand) {
      final px = size.width / 28;
      final terrain = Path()..moveTo(0, size.height);
      for (var i = 0; i <= 28; i++) {
        final h = 16.0 + (math.sin(i * .72) + 1) * 9 +
            (math.cos(i * .37) + 1) * 12;
        terrain.lineTo(i * px, size.height - h);
      }
      terrain..lineTo(size.width, size.height)..close();
      canvas.drawPath(terrain, Paint()..color = const Color(0xFF244D25));
      for (var i = 0; i < 28; i++) {
        final x = i * px;
        final y = size.height - (16 + (math.sin(i * .72) + 1) * 9 +
            (math.cos(i * .37) + 1) * 12);
        p.color = ArcadeColors.border;
        canvas.drawRect(Rect.fromLTWH(x, y, px, 4), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LandscapePainter oldDelegate) =>
      oldDelegate.showLand != showLand;
}

class RetroHeader extends StatelessWidget {
  const RetroHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 13, 16, 12),
    child: Row(children: [
      if (onBack != null) ...[
        IconButton.filledTonal(
          onPressed: onBack, icon: const Icon(Icons.arrow_back),
          style: IconButton.styleFrom(
            backgroundColor: ArcadeColors.midnight,
            foregroundColor: ArcadeColors.cream,
            shape: const BeveledRectangleBorder(),
            side: const BorderSide(color: ArcadeColors.border, width: 2),
          ),
        ),
        const SizedBox(width: 12),
      ],
      Expanded(child: RetroText(title, size: 23, color: ArcadeColors.neon)),
      if (trailing != null) trailing!,
    ]),
  );
}

class PixelMeter extends StatelessWidget {
  const PixelMeter({super.key, required this.ratio});
  final double ratio;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(12, (i) => Container(
      width: 13, height: 16, margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: (i / 12) < ratio ? ArcadeColors.neon : ArcadeColors.midnight,
        border: Border.all(color: ArcadeColors.border, width: 1),
      ),
    )),
  );
}

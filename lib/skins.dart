import 'dart:math' as math;
import 'package:flutter/material.dart';

enum SkinTier { classic, normal, epic, legend }

class BattleSkin {
  const BattleSkin({
    required this.id,
    required this.name,
    required this.tier,
    required this.accent,
    required this.motif,
    required this.price,
  });

  final int id;
  final String name;
  final SkinTier tier;
  final Color accent;
  final String motif;
  final double price;

  bool get isAnimated => tier == SkinTier.epic || tier == SkinTier.legend;
  String get tierName => tier.name.toUpperCase();
}

class BattleSkins {
  static const all = <BattleSkin>[
    BattleSkin(id: 0, name: 'CLASSIC', tier: SkinTier.classic, accent: Color(0xFFA3DB79), motif: 'arcade', price: 0),
    BattleSkin(id: 1, name: 'RED STRIKE', tier: SkinTier.normal, accent: Color(0xFFFF6660), motif: 'strike', price: 0.90),
    BattleSkin(id: 2, name: 'OCEAN BLUE', tier: SkinTier.normal, accent: Color(0xFF4ACBFF), motif: 'wave', price: 0.90),
    BattleSkin(id: 3, name: 'TOXIC GREEN', tier: SkinTier.normal, accent: Color(0xFF90F45D), motif: 'toxic', price: 0.90),
    BattleSkin(id: 4, name: 'ROYAL PURPLE', tier: SkinTier.normal, accent: Color(0xFFC48CFF), motif: 'royal', price: 0.90),
    BattleSkin(id: 5, name: 'GOLDEN YELLOW', tier: SkinTier.normal, accent: Color(0xFFFFDB66), motif: 'sun', price: 0.90),
    BattleSkin(id: 6, name: 'NEON PULSE', tier: SkinTier.epic, accent: Color(0xFF4EFFF1), motif: 'reactor', price: 2.90),
    BattleSkin(id: 7, name: 'INFERNO CORE', tier: SkinTier.epic, accent: Color(0xFFFFA04B), motif: 'inferno', price: 2.90),
    BattleSkin(id: 8, name: 'PLASMA VENOM', tier: SkinTier.epic, accent: Color(0xFFB0FF5D), motif: 'venom', price: 2.90),
    BattleSkin(id: 9, name: 'THUNDER VIOLET', tier: SkinTier.epic, accent: Color(0xFFD194FF), motif: 'thunder', price: 2.90),
    BattleSkin(id: 10, name: 'FROZEN PRISM', tier: SkinTier.epic, accent: Color(0xFFC5F5FF), motif: 'frost', price: 2.90),
    BattleSkin(id: 11, name: 'SOLAR DEITY', tier: SkinTier.legend, accent: Color(0xFFFFE27A), motif: 'solar', price: 5.90),
    BattleSkin(id: 12, name: 'VOID DRAGON', tier: SkinTier.legend, accent: Color(0xFFB791FF), motif: 'dragon', price: 5.90),
    BattleSkin(id: 13, name: 'PHOENIX HEART', tier: SkinTier.legend, accent: Color(0xFFFF955C), motif: 'phoenix', price: 5.90),
    BattleSkin(id: 14, name: 'CELESTIAL CROWN', tier: SkinTier.legend, accent: Color(0xFFD6FFC2), motif: 'crown', price: 5.90),
    BattleSkin(id: 15, name: 'COSMIC SINGULARITY', tier: SkinTier.legend, accent: Color(0xFF83B8FF), motif: 'cosmic', price: 5.90),
  ];

  static BattleSkin at(int id) => all[id.clamp(0, all.length - 1)];
}

// Every style draws in the SAME square bounds. Decorative wings/particles do not
// increase the physical hit area or grant competitive advantages.
class SkinEmblem extends StatefulWidget {
  const SkinEmblem({
    super.key,
    required this.skin,
    this.size = 170,
    this.animate = true,
    this.pressed = false,
  });

  final BattleSkin skin;
  final double size;
  final bool animate;
  final bool pressed;

  @override
  State<SkinEmblem> createState() => _SkinEmblemState();
}

class _SkinEmblemState extends State<SkinEmblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1750),
    );
    _sync();
  }

  void _sync() {
    if (widget.skin.isAnimated && widget.animate) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
    }
  }

  @override
  void didUpdateWidget(covariant SkinEmblem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate ||
        oldWidget.skin.id != widget.skin.id) {
      _sync();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) => Transform.scale(
        scale: widget.pressed ? 0.945 : 1,
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _EmblemPainter(widget.skin, _pulse.value),
        ),
      ),
    );
  }
}

class _EmblemPainter extends CustomPainter {
  _EmblemPainter(this.skin, this.motion);
  final BattleSkin skin;
  final double motion;

  static const dark = Color(0xFF061609);
  static const light = Color(0xFFEDFFBA);
  static const deep = Color(0xFF244A2A);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) / 128;
    canvas.save();
    canvas.translate(
      (size.width - 128 * scale) / 2,
      (size.height - 128 * scale) / 2,
    );
    canvas.scale(scale);
    final accent = skin.accent;
    final strength = skin.tier == SkinTier.legend ? 1.0 : skin.tier == SkinTier.epic ? 0.72 : 0.22;

    // Soft outer aura, underneath sharp nearest-neighbour style pixel outlines.
    if (strength > .3) {
      canvas.drawCircle(
        const Offset(64, 64),
        49 + motion * 3,
        Paint()
          ..color = accent.withValues(alpha: (0.13 + motion * .12) * strength)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
      );
    }

    void rect(double x, double y, double w, double h, Color color) {
      canvas.drawRect(
        Rect.fromLTWH(x.roundToDouble(), y.roundToDouble(),
            w.roundToDouble(), h.roundToDouble()),
        Paint()..color = color..isAntiAlias = false,
      );
    }

    void line(double x1, double y1, double x2, double y2, Color color,
        [double thickness = 3]) {
      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        Paint()
          ..color = color
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.square
          ..isAntiAlias = false,
      );
    }

    void poly(List<Offset> points, Color color, {bool fill = true, double stroke = 3}) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..isAntiAlias = false
          ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeJoin = StrokeJoin.bevel,
      );
    }

    void ring(double radius, Color color, [double stroke = 2]) {
      canvas.drawCircle(
        const Offset(64, 64),
        radius,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..isAntiAlias = false,
      );
    }

    void diamond(double x, double y, double radius, Color color) {
      poly([
        Offset(x, y - radius),
        Offset(x + radius, y),
        Offset(x, y + radius),
        Offset(x - radius, y),
      ], color);
    }

    // Base gadget outline: straight sides, stepped pixel corners.
    final base = <Offset>[
      const Offset(24, 18), const Offset(104, 18),
      const Offset(114, 28), const Offset(114, 100),
      const Offset(104, 110), const Offset(24, 110),
      const Offset(14, 100), const Offset(14, 28),
    ];
    poly(base, dark);
    poly(base, deep, fill: false, stroke: 9);
    poly(base, accent, fill: false, stroke: 4);
    poly([
      const Offset(30, 28), const Offset(98, 28),
      const Offset(104, 34), const Offset(104, 94),
      const Offset(98, 100), const Offset(30, 100),
      const Offset(24, 94), const Offset(24, 34),
    ], dark);
    rect(32, 32, 64, 3, accent.withValues(alpha: .35));
    rect(32, 93, 64, 3, accent.withValues(alpha: .35));

    for (final x in <double>[18, 105]) {
      for (final y in <double>[26, 95]) {
        rect(x, y, 6, 6, light);
        rect(x + 1, y + 1, 4, 4, deep);
      }
    }

    // Rarity is conveyed by silhouette + decoration + motion, not only hue.
    if (skin.tier == SkinTier.epic || skin.tier == SkinTier.legend) {
      for (var i = 0; i < 4; i++) {
        final yy = 40.0 + i * 13;
        rect(7, yy, 6, 5, i.isEven ? accent : light);
        rect(115, yy, 6, 5, i.isOdd ? accent : light);
      }
      for (var i = 0; i < 8; i++) {
        final angle = i * math.pi / 4 + (motion * .16);
        final xx = 64 + 43 * math.cos(angle);
        final yy = 64 + 43 * math.sin(angle);
        diamond(xx, yy, i.isEven ? 2 : 3, accent.withValues(alpha: .6 + motion * .35));
      }
      ring(28 + motion * 2, accent.withValues(alpha: .38 + motion * .36), 2);
    }

    if (skin.tier == SkinTier.legend) {
      // Wing-shaped feather stacks on both sides, large crown/halo silhouette.
      for (var side in <int>[-1, 1]) {
        for (var i = 0; i < 4; i++) {
          final xx = side == -1 ? 15 - i * 3.5 : 113 + i * 3.5;
          final yy = 34 + i * 12.0;
          diamond(xx, yy, 8 - i * 1.0, i.isEven ? accent : light);
        }
      }
      ring(51, accent.withValues(alpha: .75), 2);
      for (var i = 0; i < 12; i++) {
        final a = i * math.pi / 6 - math.pi / 2;
        final x = 64 + 51 * math.cos(a);
        final y = 64 + 51 * math.sin(a);
        diamond(x, y, i.isEven ? 3.8 : 2.2, i.isEven ? light : accent);
      }
    }

    // Individual artwork for all 16 emblems.
    switch (skin.motif) {
      case 'arcade':
        for (var i = 0; i < 6; i++) {
          line(64, 64, 64 + 24 * math.cos(i * math.pi / 3),
              64 + 24 * math.sin(i * math.pi / 3), accent, 2);
        }
      case 'strike':
        poly([const Offset(65, 29), const Offset(51, 53),
          const Offset(62, 53), const Offset(53, 86),
          const Offset(83, 48), const Offset(67, 51)], accent);
      case 'wave':
        for (var i = 0; i < 3; i++) {
          final y = 46 + i * 13.0;
          line(34, y, 49, y - 5, accent, 3);
          line(49, y - 5, 64, y + 5, light, 3);
          line(64, y + 5, 82, y - 4, accent, 3);
        }
      case 'toxic':
        diamond(64, 46, 12, accent);
        diamond(46, 68, 10, accent);
        diamond(82, 68, 10, accent);
        ring(11, light, 3);
      case 'royal':
        poly([const Offset(33, 54), const Offset(44, 43),
          const Offset(55, 55), const Offset(64, 37),
          const Offset(73, 55), const Offset(84, 43),
          const Offset(95, 54), const Offset(88, 68),
          const Offset(40, 68)], accent);
        rect(40, 72, 48, 5, light);
      case 'sun':
        for (var i = 0; i < 9; i++) {
          final angle = i * math.pi * 2 / 9;
          line(64 + math.cos(angle) * 18, 64 + math.sin(angle) * 18,
              64 + math.cos(angle) * 31, 64 + math.sin(angle) * 31,
              i.isEven ? accent : light, 4);
        }
        ring(13, accent, 4);
      case 'reactor':
        for (var i = 0; i < 4; i++) {
          final a = i * math.pi / 2;
          final x = 64 + math.cos(a) * 32;
          final y = 64 + math.sin(a) * 32;
          diamond(x, y, 8, accent);
        }
        ring(22 + motion * 3, light, 4);
        ring(13, accent, 3);
      case 'inferno':
        for (var i = 0; i < 6; i++) {
          final x = 32 + i * 12.0;
          poly([Offset(x - 6, 79), Offset(x - 3, 57 + (i % 3) * 6),
            Offset(x + 5, 32 + (i % 2) * 13), Offset(x + 8, 76)],
            i.isEven ? accent : light);
        }
      case 'venom':
        line(45, 41, 74, 43, accent, 7);
        line(74, 43, 82, 61, light, 7);
        line(82, 61, 56, 86, accent, 7);
        diamond(79, 40, 9, accent);
        rect(74, 38, 3, 3, dark);
        rect(82, 38, 3, 3, dark);
        rect(39, 82, 8, 4, light);
      case 'thunder':
        poly([const Offset(72, 29), const Offset(49, 59),
          const Offset(61, 59), const Offset(54, 94),
          const Offset(84, 51), const Offset(69, 54)],
          light);
        for (var i = 0; i < 4; i++) {
          line(31 + i * 19, 36, 26 + i * 19 + motion * 4, 46, accent, 2);
        }
      case 'frost':
        for (var i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          line(64, 64, 64 + math.cos(a) * 34,
              64 + math.sin(a) * 34, light, 3);
          diamond(64 + math.cos(a) * 33, 64 + math.sin(a) * 33, 6, accent);
        }
        diamond(64, 64, 11, accent);
      case 'solar':
        for (var i = 0; i < 12; i++) {
          final a = i * math.pi / 6;
          line(64 + math.cos(a) * 25, 64 + math.sin(a) * 25,
              64 + math.cos(a) * (39 + motion * 5),
              64 + math.sin(a) * (39 + motion * 5), accent, 3);
        }
        diamond(64, 36, 12, light);
        diamond(64, 91, 9, accent);
      case 'dragon':
        poly([const Offset(36, 39), const Offset(50, 31),
          const Offset(67, 41), const Offset(80, 30),
          const Offset(91, 47), const Offset(84, 53),
          const Offset(74, 48), const Offset(62, 56),
          const Offset(51, 50), const Offset(35, 63)], accent);
        line(38, 66, 49, 82, accent, 6);
        line(49, 82, 82, 81, accent, 6);
        diamond(79, 31, 7, light);
      case 'phoenix':
        for (final side in <int>[-1, 1]) {
          for (var i = 0; i < 4; i++) {
            final x = side == -1 ? 64.0 - i * 11.0 : 64.0 + i * 11.0;
            final y = 53 - i * 3.0;
            poly([Offset(64, 76), Offset(x, y + 14),
              Offset(x + side * 9, y - 8 - motion * 5),
              Offset(x + side * 4, y + 5)], i.isEven ? accent : light);
          }
        }
        diamond(64, 49, 11, accent);
      case 'crown':
        poly([const Offset(34, 66), const Offset(36, 40),
          const Offset(49, 53), const Offset(64, 29),
          const Offset(79, 53), const Offset(92, 40),
          const Offset(94, 66)], accent);
        poly([const Offset(41, 65), const Offset(49, 59),
          const Offset(64, 65), const Offset(79, 59),
          const Offset(87, 65)], light);
        rect(38, 73, 52, 8, accent);
        diamond(64, 43, 7, light);
      case 'cosmic':
        canvas.save();
        canvas.translate(64, 64);
        canvas.rotate(motion * .28);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 79, height: 32),
          Paint()..color = accent..style = PaintingStyle.stroke..strokeWidth = 4,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 37, height: 78),
          Paint()..color = light..style = PaintingStyle.stroke..strokeWidth = 2,
        );
        canvas.restore();
        ring(13, accent, 4);
        diamond(92, 48, 7, light);
    }

    // Central pixel hand. Small enough not to erase the distinctive motif.
    rect(58, 57, 11, 17, dark);
    rect(60, 55, 7, 14, light);
    rect(62, 45, 5, 19, light);
    rect(54, 60, 6, 11, light);
    rect(68, 59, 5, 12, light);
    rect(56, 71, 18, 5, light);
    rect(55, 76, 17, 3, deep);
    diamond(51, 43, 5, light);

    if (skin.isAnimated) {
      final shimmer = 0.35 + motion * .65;
      for (var i = 0; i < (skin.tier == SkinTier.legend ? 10 : 5); i++) {
        final a = i * 2.399963 + skin.id;
        final orbit = 46 + (i % 3) * 7.0;
        final x = 64 + orbit * math.cos(a + motion * .12);
        final y = 64 + orbit * math.sin(a + motion * .12);
        diamond(x, y, i.isEven ? 2.5 : 1.5,
            light.withValues(alpha: shimmer));
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EmblemPainter oldDelegate) =>
      oldDelegate.skin.id != skin.id || oldDelegate.motion != motion;
}

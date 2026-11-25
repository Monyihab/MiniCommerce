import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Path _starPath(Offset c, double r, double rotation) {
  final path = Path();
  for (var i = 0; i < 8; i++) {
    final radius = i.isEven ? r : r * 0.2;
    final a = rotation + i * math.pi / 4 - math.pi / 2;
    final p = Offset(
      c.dx + radius * math.cos(a),
      c.dy + radius * math.sin(a),
    );
    if (i == 0) {
      path.moveTo(p.dx, p.dy);
    } else {
      path.lineTo(p.dx, p.dy);
    }
  }
  return path..close();
}

class ShinyLogo extends StatefulWidget {
  final String asset;
  final double height;
  final double fallbackSize;
  final Duration interval;
  final Color glowColor;
  final Color glowCoreColor;
  final double glowScale;

  const ShinyLogo({
    super.key,
    this.asset = 'assets/AAST.png',
    required this.height,
    this.fallbackSize = 56,
    this.interval = const Duration(milliseconds: 1500),
    this.glowColor = const Color(0xFF1F5BFF),
    this.glowCoreColor = const Color(0xFF5C9DFF),
    this.glowScale = 1.0,
  });

  @override
  State<ShinyLogo> createState() => _ShinyLogoState();
}

class _ShinyLogoState extends State<ShinyLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const double _sweepEnd = 0.55;

  static const ColorFilter _removeWhite = ColorFilter.matrix(<double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    -0.6, -0.6, -0.6, 1.8, 0,
  ]);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.interval,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Shader _shine(Rect bounds, double slide) {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.white.withValues(alpha: 0),
        Colors.white.withValues(alpha: 0.95),
        Colors.white.withValues(alpha: 0),
      ],
      stops: const [0.35, 0.5, 0.65],
      transform: _SlideGradient(slide),
    ).createShader(bounds);
  }

  Widget _logoImage() {
    return Image.asset(
      widget.asset,
      height: widget.height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.school,
          color: Colors.white,
          size: widget.fallbackSize,
        );
      },
    );
  }

  Widget _glowLayer({
    required Color color,
    required double sigma,
    required double opacity,
  }) {
    final s = math.max(0.6, sigma * widget.glowScale);

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0).toDouble(),
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: s,
          sigmaY: s,
          tileMode: TileMode.decal,
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          child: ColorFiltered(
            colorFilter: _removeWhite,
            child: _logoImage(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final sweep = Curves.easeInOut.transform(
            (t / _sweepEnd).clamp(0.0, 1.0).toDouble(),
          );
          final slide = -1 + 2 * sweep;

          final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
          final flare = t < _sweepEnd ? math.sin(t / _sweepEnd * math.pi) : 0.0;
          final glow = (0.55 + 0.2 * pulse + 0.25 * flare).clamp(0.0, 1.0);

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              _glowLayer(
                color: widget.glowColor,
                sigma: 16,
                opacity: glow * 0.7,
              ),
              _glowLayer(
                color: widget.glowColor,
                sigma: 8,
                opacity: glow * 0.9,
              ),
              _glowLayer(
                color: widget.glowCoreColor,
                sigma: 3,
                opacity: glow,
              ),
              ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (bounds) => _shine(bounds, slide),
                child: ColorFiltered(
                  colorFilter: _removeWhite,
                  child: _logoImage(),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _LineStarsPainter(
                      u: t / _sweepEnd,
                      color: widget.glowCoreColor,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _SparklePainter(t)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SlideGradient extends GradientTransform {
  final double slide;

  const _SlideGradient(this.slide);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slide, 0, 0);
  }
}

class _LineStar {
  final double x;
  final double y;
  final double size;
  final double spin;

  const _LineStar(this.x, this.y, this.size, this.spin);
}

class _LineStarsPainter extends CustomPainter {
  final double u;
  final Color color;

  const _LineStarsPainter({required this.u, required this.color});

  static const double _life = 0.55;

  static const List<_LineStar> _stars = [
    _LineStar(0.06, 0.20, 11, 1.0),
    _LineStar(0.14, 0.78, 14, -1.0),
    _LineStar(0.22, 0.45, 10, 1.0),
    _LineStar(0.31, 0.10, 15, -1.0),
    _LineStar(0.40, 0.88, 12, 1.0),
    _LineStar(0.48, 0.35, 16, -1.0),
    _LineStar(0.56, 0.68, 11, 1.0),
    _LineStar(0.64, 0.15, 14, -1.0),
    _LineStar(0.72, 0.55, 12, 1.0),
    _LineStar(0.80, 0.90, 15, -1.0),
    _LineStar(0.88, 0.30, 11, 1.0),
    _LineStar(0.95, 0.62, 13, -1.0),
  ];

  static double _triggerU(double x) {
    final target = (x + 0.5) / 2;
    var lo = 0.0;
    var hi = 1.0;
    for (var i = 0; i < 20; i++) {
      final mid = (lo + hi) / 2;
      if (Curves.easeInOut.transform(mid) < target) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return (lo + hi) / 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / 70;

    for (final s in _stars) {
      final p = (u - _triggerU(s.x)) / _life;
      if (p <= 0 || p >= 1) {
        continue;
      }

      final base = math.sin(p * math.pi);
      final strength = math.pow(base, 0.6).toDouble() *
          (0.8 + 0.2 * math.sin(p * math.pi * 5));
      final center = Offset(size.width * s.x, size.height * s.y);
      final r = s.size * scale * (0.4 + 0.9 * base);
      final rotation = p * math.pi * s.spin;

      final halo = Paint()
        ..color = color.withValues(alpha: 0.9 * strength)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 7 * scale);
      canvas.drawPath(_starPath(center, r * 1.7, rotation), halo);

      final edge = Paint()
        ..color = color.withValues(alpha: strength)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 * scale);
      canvas.drawPath(_starPath(center, r * 1.2, rotation), edge);

      final fill = Paint()..color = Colors.white.withValues(alpha: strength);
      canvas.drawPath(_starPath(center, r, rotation), fill);
    }
  }

  @override
  bool shouldRepaint(covariant _LineStarsPainter oldDelegate) {
    return oldDelegate.u != u || oldDelegate.color != color;
  }
}

class _Sparkle {
  final double x;
  final double y;
  final double size;
  final double start;

  const _Sparkle(this.x, this.y, this.size, this.start);
}

class _SparklePainter extends CustomPainter {
  final double t;

  const _SparklePainter(this.t);

  static const double _length = 0.35;

  static const List<_Sparkle> _sparkles = [
    _Sparkle(0.16, 0.22, 9, 0.50),
    _Sparkle(0.58, 0.10, 7, 0.62),
    _Sparkle(0.88, 0.68, 10, 0.70),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / 70;

    for (final s in _sparkles) {
      final local = (t - s.start) / _length;
      if (local <= 0 || local >= 1) {
        continue;
      }

      final strength = math.sin(local * math.pi);
      final center = Offset(size.width * s.x, size.height * s.y);
      final r = s.size * scale * strength;
      final rotation = local * math.pi / 2;

      final glow = Paint()
        ..color = Colors.white.withValues(alpha: 0.55 * strength)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * scale);
      canvas.drawPath(_starPath(center, r * 1.3, rotation), glow);

      final fill = Paint()..color = Colors.white.withValues(alpha: strength);
      canvas.drawPath(_starPath(center, r, rotation), fill);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
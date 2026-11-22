import 'dart:math' as math;
import 'package:flutter/material.dart';

class FoxAvatar extends StatefulWidget {
  final double lookX;
  final double lookY;
  final double width;

  const FoxAvatar({
    super.key,
    required this.lookX,
    required this.lookY,
    this.width = 170,
  });

  static const double imageWidth = 528;
  static const double imageHeight = 720;

  static double heightFor(double width) => width * imageHeight / imageWidth;

  @override
  State<FoxAvatar> createState() => _FoxAvatarState();
}

class _FoxAvatarState extends State<FoxAvatar>
    with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _blink;

  static const Color _lidColor = Color(0xFFFD8002);
  static const Color _lashColor = Color(0xFF461C06);
  static const double _lidGrow = 4.5;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _idle.dispose();
    _blink.dispose();
    super.dispose();
  }

  double _twitch(double t, double start, double length, double amp) {
    if (t < start || t > start + length) {
      return 0;
    }
    final p = (t - start) / length;
    return math.sin(p * 2 * math.pi * 2) * (1 - p) * amp;
  }

  double get _blinkCover {
    final t = _blink.value;
    if (t > 0.90 && t < 0.96) {
      return math.sin((t - 0.90) / 0.06 * math.pi);
    }
    return 0;
  }

  Widget _eye({
    required double s,
    required double w,
    required double h,
    required String asset,
    required double spriteX,
    required double spriteY,
    required double spriteSize,
    required double cx,
    required double cy,
    required double major,
    required double minor,
    required double ext,
    required double angleDeg,
    required Offset shift,
    required double cover,
  }) {
    final angle = angleDeg * math.pi / 180;
    final lidTop = cy - ext - _lidGrow;
    final lidHeight = cover * 2 * (ext + _lidGrow);

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        children: [
          ClipPath(
            clipper: _EllipseClipper(
              cx: cx * s,
              cy: cy * s,
              rx: major * s,
              ry: minor * s,
              angle: angle,
            ),
            child: SizedBox(
              width: w,
              height: h,
              child: Stack(
                children: [
                  Positioned(
                    left: (spriteX + shift.dx) * s,
                    top: (spriteY + shift.dy) * s,
                    width: spriteSize * s,
                    height: spriteSize * s,
                    child: Image.asset(asset, fit: BoxFit.fill),
                  ),
                ],
              ),
            ),
          ),
          if (cover > 0.01)
            ClipPath(
              clipper: _EllipseClipper(
                cx: cx * s,
                cy: cy * s,
                rx: (major + _lidGrow) * s,
                ry: (minor + _lidGrow) * s,
                angle: angle,
              ),
              child: SizedBox(
                width: w,
                height: h,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: lidTop * s,
                      height: lidHeight * s,
                      child: const ColoredBox(color: _lidColor),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: (lidTop + lidHeight - 2) * s,
                      height: 3 * s,
                      child: const ColoredBox(color: _lashColor),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    final h = FoxAvatar.heightFor(w);
    final s = w / FoxAvatar.imageWidth;

    return SizedBox(
      width: w,
      height: h,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idle, _blink]),
        builder: (context, _) {
          final t = _idle.value;
          final wag = math.sin(t * 2 * math.pi * 3) * 0.16;
          final sway = math.sin(t * 2 * math.pi) * 0.015;
          final earLeft = _twitch(t, 0.10, 0.25, 0.12) + sway;
          final earRight = _twitch(t, 0.55, 0.25, 0.12) - sway;
          final cover = _blinkCover;

          return TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(
              begin: Offset.zero,
              end: Offset(widget.lookX, widget.lookY),
            ),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            builder: (context, look, _) {
              final shift = Offset(look.dx * 7, (look.dy - 0.2) * 6);

              return Transform.rotate(
                angle: look.dx * 0.02,
                alignment: Alignment.bottomCenter,
                child: Stack(
                  children: [
                    Transform.rotate(
                      angle: wag,
                      alignment: const Alignment(-0.136, 0.667),
                      child: Image.asset(
                        'assets/fox_tail.png',
                        width: w,
                        height: h,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Transform.rotate(
                      angle: earLeft,
                      alignment: const Alignment(-0.148, -0.5),
                      child: Image.asset(
                        'assets/fox_ear_left.png',
                        width: w,
                        height: h,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Transform.rotate(
                      angle: earRight,
                      alignment: const Alignment(0.686, -0.583),
                      child: Image.asset(
                        'assets/fox_ear_right.png',
                        width: w,
                        height: h,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Image.asset(
                      'assets/fox_body.png',
                      width: w,
                      height: h,
                      fit: BoxFit.fill,
                    ),
                    _eye(
                      s: s,
                      w: w,
                      h: h,
                      asset: 'assets/iris_left.png',
                      spriteX: 304,
                      spriteY: 195,
                      spriteSize: 55,
                      cx: 341.7,
                      cy: 213.3,
                      major: 31.3,
                      minor: 27.6,
                      ext: 30,
                      angleDeg: 143.4,
                      shift: shift,
                      cover: cover,
                    ),
                    _eye(
                      s: s,
                      w: w,
                      h: h,
                      asset: 'assets/iris_right.png',
                      spriteX: 426,
                      spriteY: 185,
                      spriteSize: 41,
                      cx: 450.6,
                      cy: 201.0,
                      major: 25.3,
                      minor: 16.4,
                      ext: 25.5,
                      angleDeg: 71.2,
                      shift: shift,
                      cover: cover,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EllipseClipper extends CustomClipper<Path> {
  final double cx;
  final double cy;
  final double rx;
  final double ry;
  final double angle;

  const _EllipseClipper({
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
    required this.angle,
  });

  @override
  Path getClip(Size size) {
    const n = 48;
    final points = <Offset>[];
    for (var i = 0; i < n; i++) {
      final a = 2 * math.pi * i / n;
      final ex = rx * math.cos(a);
      final ey = ry * math.sin(a);
      points.add(
        Offset(
          cx + ex * math.cos(angle) - ey * math.sin(angle),
          cy + ex * math.sin(angle) + ey * math.cos(angle),
        ),
      );
    }
    return Path()..addPolygon(points, true);
  }

  @override
  bool shouldReclip(covariant _EllipseClipper oldClipper) {
    return oldClipper.cx != cx ||
        oldClipper.cy != cy ||
        oldClipper.rx != rx ||
        oldClipper.ry != ry ||
        oldClipper.angle != angle;
  }
}
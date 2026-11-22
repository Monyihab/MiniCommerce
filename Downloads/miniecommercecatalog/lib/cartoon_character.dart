import 'dart:math' as math;
import 'package:flutter/material.dart';

/// One eye, described in the pixel space of the character image.
class CharacterEye {
  final double cx;
  final double cy;
  final double rx;
  final double ry;
  final double angleDeg;

  const CharacterEye({
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
    this.angleDeg = 0,
  });
}

/// A cartoon picture that blinks and (optionally) waves with one arm.
///
/// [bodyAsset] is the full picture (without the arm if [armAsset] is used).
/// [armAsset] must have the same pixel size as [bodyAsset]; it is drawn behind
/// the body and rotated around [armPivot] (in image pixels) to make it wave.
class CartoonCharacter extends StatefulWidget {
  final String bodyAsset;
  final String? armAsset;
  final double imageWidth;
  final double imageHeight;
  final double height;
  final List<CharacterEye> eyes;
  final Color lidColor;
  final Color lashColor;
  final Offset armPivot;
  final double blinkPhase;

  const CartoonCharacter({
    super.key,
    required this.bodyAsset,
    required this.imageWidth,
    required this.imageHeight,
    required this.height,
    required this.eyes,
    required this.lidColor,
    this.armAsset,
    this.armPivot = Offset.zero,
    this.lashColor = const Color(0xFF5A2E12),
    this.blinkPhase = 0,
  });

  double get width => height * imageWidth / imageHeight;

  @override
  State<CartoonCharacter> createState() => _CartoonCharacterState();
}

class _CartoonCharacterState extends State<CartoonCharacter>
    with TickerProviderStateMixin {
  static const double _lidGrow = 2.5;

  late final AnimationController _blink;
  late final AnimationController _wave;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
      value: widget.blinkPhase,
    )..repeat();

    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    if (widget.armAsset != null) {
      _wave.repeat();
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    _wave.dispose();
    super.dispose();
  }

  // 0 = eyes open, 1 = eyes closed. A quick blink once per cycle.
  double get _blinkCover {
    final t = _blink.value;
    if (t > 0.90 && t < 0.96) {
      return math.sin((t - 0.90) / 0.06 * math.pi);
    }
    return 0;
  }

  // Waves for the first part of every cycle, then rests.
  double get _waveAngle {
    final t = _wave.value;
    const active = 0.65;
    if (t >= active) {
      return 0;
    }
    final p = t / active;
    return math.sin(p * 2 * math.pi * 3) * 0.2 * math.sin(p * math.pi);
  }

  Widget _eyelid(CharacterEye eye, double s, double w, double h, double cover) {
    final angle = eye.angleDeg * math.pi / 180;
    final lidTop = eye.cy - eye.ry - _lidGrow;
    final lidHeight = cover * 2 * (eye.ry + _lidGrow);

    return ClipPath(
      clipper: _EllipseClipper(
        cx: eye.cx * s,
        cy: eye.cy * s,
        rx: (eye.rx + _lidGrow) * s,
        ry: (eye.ry + _lidGrow) * s,
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
              child: ColoredBox(color: widget.lidColor),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: (lidTop + lidHeight - 1.5) * s,
              height: 2.5 * s,
              child: ColoredBox(color: widget.lashColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;
    final w = widget.width;
    final s = h / widget.imageHeight;
    final pivot = Alignment(
      widget.armPivot.dx / widget.imageWidth * 2 - 1,
      widget.armPivot.dy / widget.imageHeight * 2 - 1,
    );

    return SizedBox(
      width: w,
      height: h,
      child: AnimatedBuilder(
        animation: Listenable.merge([_blink, _wave]),
        builder: (context, _) {
          final cover = _blinkCover;

          return Stack(
            children: [
              if (widget.armAsset != null)
                Transform.rotate(
                  angle: _waveAngle,
                  alignment: pivot,
                  child: Image.asset(
                    widget.armAsset!,
                    width: w,
                    height: h,
                    fit: BoxFit.fill,
                  ),
                ),
              Image.asset(
                widget.bodyAsset,
                width: w,
                height: h,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person, color: Colors.white, size: 48);
                },
              ),
              if (cover > 0.01)
                for (final eye in widget.eyes) _eyelid(eye, s, w, h, cover),
            ],
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
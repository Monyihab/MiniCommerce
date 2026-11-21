import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class FoxAvatar extends StatefulWidget {
  final double lookX;
  final double lookY;
  final double size;

  const FoxAvatar({
    super.key,
    required this.lookX,
    required this.lookY,
    this.size = 300,
  });

  @override
  State<FoxAvatar> createState() => _FoxAvatarState();
}

class _FoxAvatarState extends State<FoxAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idle;
  Timer? _blinkTimer;
  bool _blinking = false;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _blinkTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      setState(() => _blinking = true);
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      setState(() => _blinking = false);
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.size * 140 / 340;

    return AnimatedBuilder(
      animation: _idle,
      builder: (context, _) {
        final t = _idle.value;

        return TweenAnimationBuilder<Offset>(
          tween: Tween<Offset>(
            begin: Offset.zero,
            end: Offset(widget.lookX, widget.lookY),
          ),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          builder: (context, look, _) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1, end: _blinking ? 0.1 : 1.0),
              duration: const Duration(milliseconds: 100),
              builder: (context, eyeOpen, _) {
                return CustomPaint(
                  size: Size(widget.size, height),
                  painter: _FoxPainter(
                    look: look,
                    eyeOpen: eyeOpen,
                    t: t,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _FoxPainter extends CustomPainter {
  final Offset look;
  final double eyeOpen;
  final double t;

  const _FoxPainter({
    required this.look,
    required this.eyeOpen,
    required this.t,
  });

  static const Color _orange = Color(0xFFF28C28);
  static const Color _darkOrange = Color(0xFFC9600A);
  static const Color _haunch = Color(0xFFE67E17);
  static const Color _cream = Color(0xFFFFF3E0);
  static const Color _dark = Color(0xFF2B1B12);

  Paint get _outline => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeJoin = StrokeJoin.round
    ..color = _darkOrange;

  void _fillAndStroke(Canvas canvas, Path path, Color color) {
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(path, _outline);
  }

  void _drawTail(Canvas canvas) {
    final wag = -0.15 + math.sin(t * 2 * math.pi * 4) * 0.32;

    canvas.save();
    canvas.translate(240, 108);
    canvas.rotate(wag);

    final tail = Path()
      ..moveTo(0, -10)
      ..cubicTo(30, -42, 72, -44, 92, -22)
      ..cubicTo(88, 6, 48, 18, 0, 10)
      ..close();

    canvas.drawPath(tail, Paint()..color = _orange);

    canvas.save();
    canvas.clipPath(tail);
    final tip = Path()
      ..moveTo(66, -60)
      ..quadraticBezierTo(78, -15, 64, 40)
      ..lineTo(130, 40)
      ..lineTo(130, -60)
      ..close();
    canvas.drawPath(tip, Paint()..color = _cream);
    canvas.restore();

    canvas.drawPath(tail, _outline);
    canvas.restore();
  }

  void _drawBody(Canvas canvas) {
    final body = Path()
      ..addOval(
        Rect.fromCenter(
          center: const Offset(150, 104),
          width: 210,
          height: 60,
        ),
      );

    canvas.drawPath(body, Paint()..color = _orange);

    canvas.save();
    canvas.clipPath(body);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(140, 128),
        width: 160,
        height: 28,
      ),
      Paint()..color = _cream,
    );
    canvas.restore();

    canvas.drawPath(body, _outline);

    final haunch = Path()
      ..addOval(
        Rect.fromCenter(
          center: const Offset(188, 108),
          width: 72,
          height: 54,
        ),
      );
    _fillAndStroke(canvas, haunch, _haunch);

    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(208, 128),
        width: 34,
        height: 13,
      ),
      Paint()..color = _dark,
    );
  }

  void _drawLegs(Canvas canvas) {
    for (final x in [52.0, 90.0]) {
      final leg = Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(x, 117),
            width: 22,
            height: 32,
          ),
        );
      _fillAndStroke(canvas, leg, _orange);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, 128),
          width: 26,
          height: 12,
        ),
        Paint()..color = _dark,
      );
    }
  }

  void _drawEye(Canvas canvas, Offset center) {
    final rect = Rect.fromCenter(
      center: center,
      width: 22,
      height: 24 * eyeOpen,
    );

    canvas.drawOval(rect, Paint()..color = Colors.white);

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    final pupilCenter = center + Offset(look.dx * 4.5, look.dy * 5);
    canvas.drawCircle(pupilCenter, 6, Paint()..color = _dark);
    canvas.drawCircle(
      pupilCenter + const Offset(-2, -2),
      1.8,
      Paint()..color = Colors.white,
    );
    canvas.restore();

    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _dark,
    );
  }

  void _drawEar(
    Canvas canvas,
    Path outer,
    Path inner,
    Offset pivot,
    double angle,
  ) {
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(angle);
    canvas.translate(-pivot.dx, -pivot.dy);
    canvas.drawPath(outer, Paint()..color = _orange);
    canvas.drawPath(inner, Paint()..color = _dark);
    canvas.restore();
  }

  void _drawHead(Canvas canvas) {
    final bob = math.sin(t * 2 * math.pi) * 1.5;

    canvas.save();
    canvas.translate(68 + look.dx * 3, 80 + bob + look.dy * 2);
    canvas.rotate(look.dx * 0.09);
    canvas.scale(0.7);
    canvas.translate(-80, -70);

    final fill = Paint()..style = PaintingStyle.fill;

    final leftEar = Path()
      ..moveTo(22, 56)
      ..lineTo(30, 0)
      ..lineTo(72, 32)
      ..close();
    final rightEar = Path()
      ..moveTo(138, 56)
      ..lineTo(130, 0)
      ..lineTo(88, 32)
      ..close();
    final leftInner = Path()
      ..moveTo(34, 40)
      ..lineTo(36, 14)
      ..lineTo(58, 30)
      ..close();
    final rightInner = Path()
      ..moveTo(126, 40)
      ..lineTo(124, 14)
      ..lineTo(102, 30)
      ..close();

    final wiggle = math.sin(t * 2 * math.pi * 2) * 0.10;
    final perk = look.dy > 0.5 ? -0.06 : 0.0;

    _drawEar(
      canvas,
      leftEar,
      leftInner,
      const Offset(34, 50),
      wiggle + perk,
    );
    _drawEar(
      canvas,
      rightEar,
      rightInner,
      const Offset(126, 50),
      -wiggle - perk,
    );

    final head = Path()
      ..moveTo(80, 112)
      ..cubicTo(55, 112, 25, 80, 8, 62)
      ..cubicTo(20, 40, 45, 28, 80, 28)
      ..cubicTo(115, 28, 140, 40, 152, 62)
      ..cubicTo(135, 80, 105, 112, 80, 112)
      ..close();
    canvas.drawPath(head, fill..color = _orange);

    final cheeks = Path()
      ..moveTo(80, 112)
      ..cubicTo(60, 112, 30, 85, 8, 62)
      ..cubicTo(40, 70, 60, 66, 80, 76)
      ..cubicTo(100, 66, 120, 70, 152, 62)
      ..cubicTo(130, 85, 100, 112, 80, 112)
      ..close();
    canvas.drawPath(cheeks, fill..color = _cream);

    canvas.drawPath(
      head,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..color = _darkOrange,
    );

    final blush = Paint()..color = const Color(0x33E53935);
    canvas.drawCircle(const Offset(38, 78), 7, blush);
    canvas.drawCircle(const Offset(122, 78), 7, blush);

    _drawEye(canvas, const Offset(54, 58));
    _drawEye(canvas, const Offset(106, 58));

    final nose = Path()
      ..moveTo(72, 84)
      ..lineTo(88, 84)
      ..lineTo(80, 94)
      ..close();
    canvas.drawPath(nose, fill..color = _dark);

    final mouth = Path()
      ..moveTo(80, 94)
      ..lineTo(80, 99)
      ..moveTo(80, 99)
      ..quadraticBezierTo(74, 104, 68, 100)
      ..moveTo(80, 99)
      ..quadraticBezierTo(86, 104, 92, 100);
    canvas.drawPath(
      mouth,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = _dark,
    );

    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 340);
    _drawTail(canvas);
    _drawBody(canvas);
    _drawLegs(canvas);
    _drawHead(canvas);
  }

  @override
  bool shouldRepaint(covariant _FoxPainter oldDelegate) {
    return oldDelegate.look != look ||
        oldDelegate.eyeOpen != eyeOpen ||
        oldDelegate.t != t;
  }
}
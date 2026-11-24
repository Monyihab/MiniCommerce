import 'dart:math' as math;
import 'package:flutter/material.dart';

class _TransitionStar {
  final double x;
  final double y;
  final double size;
  final double spin;

  const _TransitionStar(this.x, this.y, this.size, this.spin);
}

final List<_TransitionStar> _transitionStars = _buildStars();

List<_TransitionStar> _buildStars() {
  const count = 220;
  final random = math.Random(11);
  return List.generate(count, (i) {
    return _TransitionStar(
      (i + random.nextDouble()) / count,
      random.nextDouble(),
      9 + random.nextDouble() * 12,
      i.isEven ? 1 : -1,
    );
  });
}

class _TransitionStarsPainter extends CustomPainter {
  final double u;
  final bool movesRight;

  const _TransitionStarsPainter({required this.u, required this.movesRight});

  static const double _lineSpan = 0.6;
  static const double _life = 0.45;

  Path _star(Offset c, double r, double rotation) {
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

  @override
  void paint(Canvas canvas, Size size) {
    if (u <= 0 || u >= 1) {
      return;
    }

    final lineProgress = (u / _lineSpan).clamp(0.0, 1.0).toDouble();
    if (u < _lineSpan) {
      final lineX =
          size.width * (movesRight ? lineProgress : 1 - lineProgress);
      final lineAlpha = math.sin(lineProgress * math.pi);
      final rect = Rect.fromLTWH(lineX - 1.5, 0, 3, size.height);
      final linePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.85 * lineAlpha),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRect(rect, linePaint);
    }

    final haloPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final fillPaint = Paint();

    for (final s in _transitionStars) {
      final position = movesRight ? s.x : 1 - s.x;
      final p = (u - _lineSpan * position) / _life;
      if (p <= 0 || p >= 1) {
        continue;
      }

      final base = math.sin(p * math.pi);
      final strength = math.pow(base, 0.6).toDouble() *
          (0.8 + 0.2 * math.sin(p * math.pi * 5));
      final center = Offset(size.width * s.x, size.height * s.y);
      final r = s.size * (0.4 + 0.9 * base);
      final rotation = p * math.pi * s.spin;

      haloPaint.color = Colors.white.withValues(alpha: 0.75 * strength);
      canvas.drawPath(_star(center, r * 1.6, rotation), haloPaint);

      fillPaint.color = Colors.white.withValues(alpha: strength);
      canvas.drawPath(_star(center, r, rotation), fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TransitionStarsPainter oldDelegate) {
    return oldDelegate.u != u || oldDelegate.movesRight != movesRight;
  }
}

PageRouteBuilder<T> slideFadeRoute<T>({
  required Widget page,
  RouteSettings? settings,
  bool fromLeft = false,
  Duration duration = const Duration(milliseconds: 600),
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final slide = Tween<Offset>(
        begin: Offset(fromLeft ? -0.25 : 0.25, 0),
        end: Offset.zero,
      ).animate(curved);

      final outgoingSlide = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(fromLeft ? 0.15 : -0.15, 0),
      ).animate(CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOutCubic,
      ));

      final outgoingFade = Tween<double>(begin: 1, end: 0.0).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
      );

      return Stack(
        fit: StackFit.passthrough,
        children: [
          FadeTransition(
            opacity: outgoingFade,
            child: SlideTransition(
              position: outgoingSlide,
              child: FadeTransition(
                opacity: curved,
                child: SlideTransition(position: slide, child: child),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  final reversing =
                      animation.status == AnimationStatus.reverse;
                  return CustomPaint(
                    painter: _TransitionStarsPainter(
                      u: reversing ? 1 - animation.value : animation.value,
                      movesRight: reversing ? !fromLeft : fromLeft,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    },
  );
}
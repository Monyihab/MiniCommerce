import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';
import 'glass_scrollbar.dart';

// Shared look & feel, taken directly from the home page.

const Color kPink = Color(0xFFFF1744);
const Color kDeepRed = Color(0xFFB30B27);
const Color kNavRed = Color(0xFFC5102F);
const Color kSoftGreen = Color(0xFFB9F6CA);
const Color kSoftPink = Color(0xFFFFE3E8);

BoxDecoration glassDecoration({double radius = 24, double alpha = 0.18}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    color: Colors.white.withValues(alpha: alpha),
    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

/// Shared clock: every page shows the sky at the same moment of its
/// animation, so nothing jumps when you move between pages.
final Stopwatch _bgClock = Stopwatch()..start();

class _TinyStar {
  final double x, y, radius, period, phase, maxAlpha;
  final bool pink;

  const _TinyStar(
    this.x,
    this.y,
    this.radius,
    this.period,
    this.phase,
    this.maxAlpha,
    this.pink,
  );
}

class _BigStar {
  final double x, y, baseLen, peakLen, period, offset, phase;

  const _BigStar(
    this.x,
    this.y,
    this.baseLen,
    this.peakLen,
    this.period,
    this.offset,
    this.phase,
  );
}

/// Tiny stars that twinkle all the time (positions are fractions 0..1).
final List<_TinyStar> _tinyStars = () {
  final r = math.Random(11);
  return List<_TinyStar>.generate(130, (i) {
    final size = r.nextDouble();
    return _TinyStar(
      r.nextDouble(),
      r.nextDouble(),
      0.5 + size * size * 1.2,
      1.6 + r.nextDouble() * 3.2,
      r.nextDouble() * math.pi * 2,
      0.35 + r.nextDouble() * 0.55,
      r.nextDouble() < 0.3,
    );
  });
}();

/// Larger stars that flash into a neon starburst now and then.
final List<_BigStar> _bigStars = () {
  final r = math.Random(5);
  const cols = 3;
  const rows = 6;
  final list = <_BigStar>[];
  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      list.add(
        _BigStar(
          (col + 0.15 + r.nextDouble() * 0.7) / cols,
          (row + 0.15 + r.nextDouble() * 0.7) / rows,
          6 + r.nextDouble() * 5, // resting ray length
          34 + r.nextDouble() * 26, // ray length at full flash
          5 + r.nextDouble() * 4, // seconds between flashes
          r.nextDouble() * 9, // time offset so they don't flash together
          r.nextDouble() * math.pi * 2,
        ),
      );
    }
  }
  return list;
}();

void _drawRay(
  Canvas canvas,
  Offset c,
  double len,
  double w,
  double angle,
  Paint paint,
) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(angle);
  final path = Path()
    ..moveTo(-len, 0)
    ..lineTo(0, -w)
    ..lineTo(len, 0)
    ..lineTo(0, w)
    ..close();
  canvas.drawPath(path, paint);
  canvas.restore();
}

/// The still part of the sky: rose-pink galaxy colours and silky ribbons.
/// Drawn once, never repaints.
class _GalaxyBasePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5E011F),
            Color(0xFF700228),
            Color(0xFF5A011E),
            Color(0xFF9A053E),
          ],
          stops: [0, 0.35, 0.65, 1],
        ).createShader(rect),
    );

    void glow(double fx, double fy, double fr, Color c) {
      final center = Offset(size.width * fx, size.height * fy);
      final radius = size.longestSide * fr;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(
            center,
            radius,
            [c, c.withValues(alpha: 0)],
          ),
      );
    }

    glow(0.12, 0.10, 0.45, const Color(0xFFFF3D7F).withValues(alpha: 0.30));
    glow(0.90, 0.42, 0.50, const Color(0xFFE8266B).withValues(alpha: 0.22));
    glow(0.15, 0.92, 0.55, const Color(0xFFFF4D8D).withValues(alpha: 0.28));
    glow(0.85, 0.95, 0.45, const Color(0xFFFF5C98).withValues(alpha: 0.22));

    Path ribbon(List<double> p, double dy) {
      return Path()
        ..moveTo(size.width * p[0], size.height * p[1] + dy)
        ..cubicTo(
          size.width * p[2],
          size.height * p[3] + dy,
          size.width * p[4],
          size.height * p[5] + dy,
          size.width * p[6],
          size.height * p[7] + dy,
        );
    }

    final ribbons = <List<double>>[
      [-0.05, 0.17, 0.20, 0.15, 0.30, 0.33, 0.70, 0.36],
      [-0.05, 0.68, 0.25, 0.78, 0.40, 0.95, 0.60, 1.05],
      [-0.05, 0.78, 0.20, 0.86, 0.30, 1.00, 0.50, 1.08],
      [1.05, 0.80, 0.80, 0.84, 0.70, 0.95, 0.45, 1.05],
    ];

    final soft = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..color = const Color(0xFFFF6FA3).withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final lineA = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.30);
    final lineB = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = const Color(0xFFFFB3CF).withValues(alpha: 0.40);

    for (final r in ribbons) {
      canvas.drawPath(ribbon(r, 4), soft);
      canvas.drawPath(ribbon(r, 0), lineA);
      canvas.drawPath(ribbon(r, 9), lineB);
    }

    // Soft dark corners so the glass cards and white text stand out.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          rect.center,
          size.longestSide * 0.75,
          [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
          [0.55, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The moving part of the sky: twinkles, neon starbursts, shooting star.
class _SkyPainter extends CustomPainter {
  _SkyPainter(Listenable repaint) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final t = _bgClock.elapsedMicroseconds / 1000000.0;
    final paint = Paint()..isAntiAlias = true;

    // 1) Tiny stars: continuously brighten and dim.
    for (final s in _tinyStars) {
      final wave = 0.5 + 0.5 * math.sin(2 * math.pi * t / s.period + s.phase);
      final b = 0.12 + 0.88 * wave * wave;
      final c = Offset(s.x * size.width, s.y * size.height);
      final color = s.pink ? const Color(0xFFFFB3CF) : Colors.white;

      if (s.radius > 1.0) {
        paint.color = color.withValues(alpha: 0.14 * b);
        canvas.drawCircle(c, s.radius * 3.2, paint);
      }
      paint.color = color.withValues(alpha: s.maxAlpha * b);
      canvas.drawCircle(c, s.radius * (0.75 + 0.35 * b), paint);
    }

    // 2) Bigger stars: quick neon flash with white rays, then slow fade.
    const attack = 0.15;
    const decay = 1.3;
    for (final s in _bigStars) {
      final c = Offset(s.x * size.width, s.y * size.height);
      final local = (t + s.offset) % s.period;

      double env = 0;
      if (local < attack) {
        env = local / attack;
      } else if (local < attack + decay) {
        final x = (local - attack) / decay;
        env = (1 - x) * (1 - x);
      }

      final rest = 0.40 + 0.12 * math.sin(t * 1.3 + s.phase);
      final i = math.max(rest, env);
      final len = s.baseLen * (0.85 + 0.3 * rest) +
          (s.peakLen - s.baseLen) * env;

      // soft glow
      final glowR = 12 + 46 * env + 6 * rest;
      canvas.drawCircle(
        c,
        glowR,
        Paint()
          ..shader = ui.Gradient.radial(
            c,
            glowR,
            [
              Colors.white.withValues(alpha: 0.30 * rest + 0.55 * env),
              const Color(0xFFFF4D8D)
                  .withValues(alpha: 0.18 * rest + 0.30 * env),
              const Color(0xFFFF4D8D).withValues(alpha: 0),
            ],
            [0, 0.35, 1],
          ),
      );

      // pink halo behind the rays
      paint.color = const Color(0xFFFF4D8D).withValues(alpha: 0.30 * i);
      _drawRay(canvas, c, len, len * 0.16, 0, paint);
      _drawRay(canvas, c, len, len * 0.16, math.pi / 2, paint);

      // white rays
      paint.color = Colors.white.withValues(alpha: 0.55 + 0.45 * i);
      final w = math.max(0.7, len * 0.05);
      _drawRay(canvas, c, len, w, 0, paint);
      _drawRay(canvas, c, len, w, math.pi / 2, paint);

      // short diagonal rays appear only during the flash
      if (env > 0.04) {
        paint.color = Colors.white.withValues(alpha: env * 0.85);
        _drawRay(canvas, c, len * 0.5, w * 0.8, math.pi / 4, paint);
        _drawRay(canvas, c, len * 0.5, w * 0.8, -math.pi / 4, paint);
      }

      paint.color = Colors.white.withValues(alpha: 0.7 + 0.3 * i);
      canvas.drawCircle(c, 1.4 + 2.0 * env, paint);
    }

    // 3) Shooting star: one streak every 3 seconds.
    const period = 3.0;
    const duration = 1.15;
    final k = (t / period).floor();
    final p = (t - k * period) / duration;

    if (p >= 0 && p <= 1) {
      final r = math.Random(k * 7919 + 13);
      final goLeft = r.nextDouble() < 0.75;
      final angle = 0.40 + r.nextDouble() * 0.35;
      final dir = Offset(
        goLeft ? -math.cos(angle) : math.cos(angle),
        math.sin(angle),
      );
      final start = Offset(
        size.width *
            (goLeft ? 0.45 + 0.55 * r.nextDouble() : 0.55 * r.nextDouble()),
        size.height * (0.02 + 0.30 * r.nextDouble()),
      );

      final travel = size.width * 0.85 + 180;
      final e = 1 - (1 - p) * (1 - p);
      final head = start + dir * (travel * e);
      final tailLen = 130 + 70 * math.sin(math.pi * p);
      final tail = head - dir * tailLen;
      final fade = p < 0.15 ? p / 0.15 : (p > 0.6 ? (1 - p) / 0.4 : 1.0);

      canvas.drawLine(
        head,
        tail,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 7
          ..shader = ui.Gradient.linear(head, tail, [
            const Color(0xFFFF4D8D).withValues(alpha: 0.35 * fade),
            const Color(0xFFFF4D8D).withValues(alpha: 0),
          ]),
      );
      canvas.drawLine(
        head,
        tail,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2.4
          ..shader = ui.Gradient.linear(head, tail, [
            Colors.white.withValues(alpha: fade),
            Colors.white.withValues(alpha: 0),
          ]),
      );
      canvas.drawCircle(
        head,
        14,
        Paint()
          ..shader = ui.Gradient.radial(
            head,
            14,
            [
              Colors.white.withValues(alpha: 0.95 * fade),
              const Color(0xFFFF4D8D).withValues(alpha: 0.4 * fade),
              const Color(0xFFFF4D8D).withValues(alpha: 0),
            ],
            [0, 0.4, 1],
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Rose-pink galaxy background used by every page.
/// Only this layer animates; the page content on top never moves.
class GradientBackground extends StatefulWidget {
  const GradientBackground({super.key});

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  // Only used to repaint every frame; the sky reads time from _bgClock.
  late final AnimationController _ticker = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: CustomPaint(
                painter: _GalaxyBasePainter(),
                size: Size.infinite,
              ),
            ),
            RepaintBoundary(
              child: CustomPaint(
                painter: _SkyPainter(_ticker),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Round frosted button used in headers (back, cart, ...).
class GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final int badge;

  const GlassCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Badge(
              isLabelVisible: badge > 0,
              backgroundColor: kDeepRed,
              textColor: Colors.white,
              label: Text('$badge'),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
          ),
        ),
      ),
    );
  }
}

/// Page frame: gradient background + home-style header + body (+ optional
/// floating bottom bar).
class GlassPage extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBack;
  final String backTooltip;
  final List<Widget> actions;
  final Widget body;
  final Widget? bottomBar;
  final double maxWidth;

  const GlassPage({
    super.key,
    this.title,
    this.titleWidget,
    this.showBack = true,
    this.backTooltip = 'Back',
    this.actions = const [],
    required this.body,
    this.bottomBar,
    this.maxWidth = 1000,
  });

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Row(
            children: [
              if (showBack) ...[
                GlassCircleButton(
                  icon: Icons.arrow_back,
                  tooltip: backTooltip,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: titleWidget ??
                    Text(
                      title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
              for (final a in actions) ...[
                const SizedBox(width: 10),
                a,
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kDeepRed,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const GradientBackground(),
            SafeArea(
              child: Column(
                children: [
                  _header(context),
                  Expanded(child: body),
                  if (bottomBar != null) bottomBar!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrollable area with the home page's glass scrollbar.
class GlassScrollView extends StatefulWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;
  final bool centered;

  const GlassScrollView({
    super.key,
    required this.child,
    this.maxWidth = 1000,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 24, 24),
    this.centered = false,
  });

  @override
  State<GlassScrollView> createState() => _GlassScrollViewState();
}

class _GlassScrollViewState extends State<GlassScrollView> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScrollbar(
      controller: _controller,
      inset: const EdgeInsets.fromLTRB(0, 8, 4, 8),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: _controller,
              padding: widget.padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: widget.centered
                      ? (constraints.maxHeight -
                              widget.padding.vertical)
                          .clamp(0.0, double.infinity)
                          .toDouble()
                      : 0,
                ),
                child: Align(
                  alignment:
                      widget.centered ? Alignment.center : Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: widget.maxWidth),
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Frosted card (replaces the old white card).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double bottomMargin;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.bottomMargin = 14,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: bottomMargin),
      padding: padding,
      decoration: glassDecoration(radius: radius, alpha: 0.18),
      child: child,
    );
  }
}

class CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const CardHeader({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Home-style section title: pink bar + bold white text.
class SectionTitle extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const SectionTitle(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.only(top: 22, bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(
            width: 5,
            height: 26,
            decoration: BoxDecoration(
              color: kPink,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Solid white button with pink label (primary action on the gradient).
ButtonStyle whiteButtonStyle({
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 16),
}) {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: kPink,
    elevation: 0,
    padding: padding,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  );
}

/// Frosted outlined button (secondary action).
ButtonStyle glassOutlinedButtonStyle({
  EdgeInsetsGeometry padding = const EdgeInsets.all(14),
}) {
  return OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.white.withValues(alpha: 0.14),
    side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
    padding: padding,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  );
}

/// Frosted text field look.
InputDecoration glassInput({
  String? label,
  String? hint,
  Widget? prefix,
  Widget? suffix,
  String? errorText,
  double radius = 18,
  bool dense = false,
}) {
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: c, width: w),
      );

  return InputDecoration(
    isDense: dense,
    labelText: label,
    hintText: hint,
    errorText: errorText,
    prefixIcon: prefix,
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.16),
    labelStyle: const TextStyle(color: Colors.white70),
    floatingLabelStyle: const TextStyle(color: Colors.white),
    hintStyle: const TextStyle(color: Colors.white70),
    prefixIconColor: Colors.white70,
    suffixIconColor: Colors.white70,
    errorStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    enabledBorder: border(Colors.white.withValues(alpha: 0.3)),
    focusedBorder: border(Colors.white, 1.6),
    errorBorder: border(Colors.white, 1.2),
    focusedErrorBorder: border(Colors.white, 1.8),
    border: border(Colors.white.withValues(alpha: 0.3)),
  );
}

/// Floating rounded red bar (same as home's bottom nav).
class GlassBottomBar extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const GlassBottomBar({super.key, required this.child, this.maxWidth = 700});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: kNavRed.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small cart icon with badge used in headers.
class CartHeaderButton extends StatelessWidget {
  final VoidCallback onTap;

  const CartHeaderButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        return GlassCircleButton(
          icon: Icons.shopping_cart_outlined,
          tooltip: 'Cart',
          badge: cart.itemCount,
          onTap: onTap,
        );
      },
    );
  }
}


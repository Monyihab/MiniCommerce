import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WindGirl extends StatefulWidget {
  final double width;

  const WindGirl({super.key, this.width = 104});

  static const double imageWidth = 434;
  static const double imageHeight = 544;

  static double heightFor(double width) => width * imageHeight / imageWidth;

  @override
  State<WindGirl> createState() => _WindGirlState();
}

class _WindGirlState extends State<WindGirl>
    with SingleTickerProviderStateMixin {
  static final Map<String, Future<ui.Image>> _cache = {};

  late final AnimationController _controller;
  ui.Image? _hair;
  ui.Image? _body;

  static Future<ui.Image> _load(String asset) {
    return _cache.putIfAbsent(asset, () async {
      final data = await rootBundle.load(asset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      return frame.image;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _init();
  }

  Future<void> _init() async {
    try {
      final hair = await _load('assets/girl_hair.png');
      final body = await _load('assets/girl_body.png');
      if (!mounted) {
        return;
      }
      setState(() {
        _hair = hair;
        _body = body;
      });
    } catch (_) {
      _cache.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = WindGirl.heightFor(widget.width);
    final hair = _hair;
    final body = _body;

    if (hair == null || body == null) {
      return SizedBox(width: widget.width, height: height);
    }

    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        height: height,
        child: CustomPaint(
          painter: _WindGirlPainter(
            hair: hair,
            body: body,
            animation: _controller,
          ),
        ),
      ),
    );
  }
}

class _Eye {
  final double cx;
  final double cy;
  final double rx;
  final double ry;
  final double angle;

  const _Eye(this.cx, this.cy, this.rx, this.ry, this.angle);
}

class _WindGirlPainter extends CustomPainter {
  final ui.Image hair;
  final ui.Image body;
  final Animation<double> animation;

  _WindGirlPainter({
    required this.hair,
    required this.body,
    required this.animation,
  }) : super(repaint: animation);

  static const List<_Eye> _eyes = [
    _Eye(183, 128, 21, 12.5, 0.35),
    _Eye(250, 126, 24, 12.5, -0.35),
  ];

  static const Color _lidColor = Color(0xFFF6B27A);
  static const Color _lashColor = Color(0xFF411408);

  static const List<double> _blinkStarts = [0.15, 0.38, 0.43, 0.72];
  static const double _blinkLength = 0.014;

  double _wave(double cycles, [double phase = 0]) {
    return math.sin(2 * math.pi * cycles * animation.value + phase);
  }

  double get _blink {
    final u = animation.value;
    for (final start in _blinkStarts) {
      final p = (u - start) / _blinkLength;
      if (p > 0 && p < 1) {
        final c = p < 0.4 ? p / 0.4 : 1 - (p - 0.4) / 0.6;
        return Curves.easeInOut.transform(c);
      }
    }
    return 0;
  }

  void _paintHair(Canvas canvas, double s) {
    final w = hair.width.toDouble();
    final h = hair.height.toDouble();
    const strip = 3.0;

    final gust = 0.65 + 0.35 * _wave(2, 0.6);
    final paint = Paint()..filterQuality = FilterQuality.medium;

    for (var y = 0.0; y < h; y += strip) {
      final rows = math.min(strip, h - y);
      final yn = y / h;
      final weight =
          math.pow(((yn - 0.10) / 0.90).clamp(0.0, 1.0), 1.4).toDouble();
      final flutter = _wave(5, -yn * 5.0) + 0.45 * _wave(8, -yn * 8.0 + 1.0);
      final dx = 40 * weight * (0.30 + 0.50 * gust * flutter);

      canvas.drawImageRect(
        hair,
        Rect.fromLTWH(0, y, w, rows),
        Rect.fromLTWH(dx * s, y * s, w * s, rows * s + 0.6),
        paint,
      );
    }
  }

  void _paintEyelid(Canvas canvas, double s, _Eye eye, double cover) {
    final rx = (eye.rx + 2) * s;
    final ry = (eye.ry + 2.5) * s;
    final lidHeight = cover * ry * 2;

    canvas.save();
    canvas.translate(eye.cx * s, eye.cy * s);
    canvas.rotate(eye.angle);
    canvas.clipPath(
      Path()
        ..addOval(
          Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
        ),
    );
    canvas.drawRect(
      Rect.fromLTWH(-rx - 1, -ry, rx * 2 + 2, lidHeight),
      Paint()..color = _lidColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(-rx - 1, -ry + lidHeight - 1.2 * s, rx * 2 + 2, 2.2 * s),
      Paint()..color = _lashColor,
    );
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / body.width;
    final sway = _wave(3) * 0.014 + _wave(5, 1.3) * 0.005;
    final breathe = 1 + _wave(6) * 0.005;

    canvas.save();
    canvas.translate(size.width / 2, size.height);
    canvas.rotate(sway);
    canvas.scale(1, breathe);
    canvas.translate(-size.width / 2, -size.height);

    _paintHair(canvas, s);

    canvas.drawImageRect(
      body,
      Rect.fromLTWH(0, 0, body.width.toDouble(), body.height.toDouble()),
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.medium,
    );

    final cover = _blink;
    if (cover > 0.01) {
      for (final eye in _eyes) {
        _paintEyelid(canvas, s, eye, cover);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WindGirlPainter oldDelegate) {
    return oldDelegate.hair != hair || oldDelegate.body != body;
  }
}

class _WindowDecorPainter extends CustomPainter {
  final Animation<double> animation;

  _WindowDecorPainter(this.animation) : super(repaint: animation);

  static const List<List<double>> _stars = [
    [0.30, 0.12, 6, 2, 0.0],
    [0.93, 0.24, 5, 3, 1.2],
    [0.60, 0.86, 6, 1, 2.0],
    [0.42, 0.58, 4, 3, 0.5],
    [0.97, 0.72, 7, 2, 2.6],
    [0.06, 0.12, 5, 1, 3.0],
    [0.06, 0.86, 6, 2, 4.0],
    [0.75, 0.12, 4, 2, 5.2],
    [0.52, 0.32, 3.5, 3, 1.9],
    [0.86, 0.88, 4, 1, 0.8],
  ];

  Path _star(Offset c, double r) {
    final k = r * 0.12;
    return Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + k, c.dy - k, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + k, c.dy + k, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - k, c.dy + k, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - k, c.dy - k, c.dx, c.dy - r)
      ..close();
  }

  Path _heart(Offset c, double s) {
    return Path()
      ..moveTo(c.dx, c.dy + s * 0.9)
      ..cubicTo(
        c.dx - s * 1.5,
        c.dy - s * 0.1,
        c.dx - s * 0.9,
        c.dy - s * 1.2,
        c.dx,
        c.dy - s * 0.45,
      )
      ..cubicTo(
        c.dx + s * 0.9,
        c.dy - s * 1.2,
        c.dx + s * 1.5,
        c.dy - s * 0.1,
        c.dx,
        c.dy + s * 0.9,
      )
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = animation.value;

    final glossRect = Rect.fromLTWH(0, 0, w, h * 0.5);
    canvas.drawRect(
      glossRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.32),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(glossRect),
    );

    final lineA = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = Colors.white.withValues(alpha: 0.32);
    final lineB = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white.withValues(alpha: 0.22);

    canvas.drawPath(
      Path()
        ..moveTo(-10, h * 0.30)
        ..cubicTo(w * 0.25, h * 0.05, w * 0.55, h * 0.55, w + 10, h * 0.2),
      lineA,
    );
    canvas.drawPath(
      Path()
        ..moveTo(-10, h * 0.85)
        ..cubicTo(w * 0.30, h * 0.55, w * 0.65, h * 1.05, w + 10, h * 0.6),
      lineB,
    );

    canvas.drawPath(
      _heart(Offset(108, h * 0.60), 7),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.95),
    );

    final fill = Paint();
    final glow = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (final s in _stars) {
      final wave = 0.5 + 0.5 * math.sin(2 * math.pi * s[3] * t + s[4]);
      final a = 0.15 + 0.85 * wave * wave;
      final c = Offset(w * s[0], h * s[1]);
      final r = s[2] * (0.6 + 0.4 * wave);

      glow.color = Colors.white.withValues(alpha: 0.5 * a);
      canvas.drawCircle(c, r * 0.9, glow);

      fill.color = Colors.white.withValues(alpha: a);
      canvas.drawPath(_star(c, r), fill);
    }
  }

  @override
  bool shouldRepaint(covariant _WindowDecorPainter oldDelegate) => false;
}

class _SwooshPainter extends CustomPainter {
  const _SwooshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()
      ..moveTo(0, size.height * 0.85)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.2,
        size.width * 0.6,
        size.height * 0.2,
        size.width,
        size.height * 0.5,
      );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white,
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _SwooshPainter oldDelegate) => false;
}

class GuideMessage extends StatefulWidget {
  final VoidCallback onClosed;

  const GuideMessage({super.key, required this.onClosed});

  static const String name = 'Mia';
  static const String message =
      'Hello there!\nWelcome to your happy place for shopping.';

  @override
  State<GuideMessage> createState() => _GuideMessageState();
}

class _GuideMessageState extends State<GuideMessage>
    with TickerProviderStateMixin {
  static const double _girlWidth = 104;

  late final AnimationController _enter;
  late final AnimationController _type;
  late final AnimationController _sparkle;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _type = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: GuideMessage.message.length * 42),
    );
    _sparkle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _enter.forward().whenComplete(() {
      if (mounted) {
        _type.forward();
      }
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    _type.dispose();
    _sparkle.dispose();
    super.dispose();
  }

  void _close() {
    if (_closing || !mounted) {
      return;
    }
    _closing = true;
    _enter.reverse().whenComplete(() {
      if (mounted) {
        widget.onClosed();
      }
    });
  }

  void _skipTyping() {
    if (!_type.isCompleted && _enter.isCompleted) {
      _type.value = 1.0;
    }
  }

  Widget _pill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF6FA3), Color(0xFFE8266B)],
        ),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.35),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Text(
        GuideMessage.name,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _closeButton() {
    return Tooltip(
      message: 'Close',
      child: InkWell(
        onTap: _close,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF6FA3), Color(0xFFE8266B)],
            ),
            border: Border.all(color: Colors.white, width: 2.4),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.35),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _typedText() {
    const style = TextStyle(
      color: Colors.white,
      fontSize: 17,
      height: 1.3,
      fontWeight: FontWeight.w800,
      shadows: [
        Shadow(color: Colors.black38, blurRadius: 3, offset: Offset(0, 1)),
      ],
    );

    return AnimatedBuilder(
      animation: _type,
      builder: (context, _) {
        const message = GuideMessage.message;
        final count =
            (message.length * _type.value).floor().clamp(0, message.length);

        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: message.substring(0, count)),
              TextSpan(
                text: message.substring(count),
                style: const TextStyle(color: Colors.transparent),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: style,
        );
      },
    );
  }

  Widget _flourish() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(size: Size(84, 14), painter: _SwooshPainter()),
        SizedBox(width: 8),
        Icon(Icons.favorite_border, color: Colors.white, size: 20),
      ],
    );
  }

  Widget _content() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _typedText(),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _type,
          builder: (context, child) {
            return AnimatedOpacity(
              opacity: _type.isCompleted ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              child: child,
            );
          },
          child: _flourish(),
        ),
      ],
    );
  }

  Widget _window(double girlHeight) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.28),
            blurRadius: 16,
          ),
          BoxShadow(
            color: const Color(0xFFFF3D7F).withValues(alpha: 0.45),
            blurRadius: 26,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF7FB0), Color(0xFFFF4D8D), Color(0xFFE8266B)],
            stops: [0, 0.55, 1],
          ),
          border: Border.all(color: Colors.white, width: 2.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _WindowDecorPainter(_sparkle)),
                ),
              ),
              const Positioned(
                left: 4,
                bottom: -4,
                child: WindGirl(width: _girlWidth),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(_girlWidth + 14, 26, 16, 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: girlHeight - 40),
                  child: Align(
                    alignment: Alignment.center,
                    child: _content(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final girlHeight = WindGirl.heightFor(_girlWidth);

    return AnimatedBuilder(
      animation: _enter,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_enter.value);
        return Opacity(
          opacity: _enter.value.clamp(0.0, 1.0).toDouble(),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 40),
            child: child,
          ),
        );
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, right: 12),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _skipTyping,
              child: _window(girlHeight),
            ),
          ),
          Positioned(top: 0, left: _girlWidth + 8, child: _pill()),
          Positioned(top: 0, right: 0, child: _closeButton()),
        ],
      ),
    );
  }
}
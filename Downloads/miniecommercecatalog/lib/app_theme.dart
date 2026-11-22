import 'dart:math' as math;
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

/// Shared clock so every page shows the background at the same point of
/// its motion (no jump when you navigate between pages).
final Stopwatch _bgClock = Stopwatch()..start();

/// Slowly drifting image background used by every page.
class GradientBackground extends StatefulWidget {
  const GradientBackground({super.key});

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  // How long one full drift loop takes. Bigger = slower.
  static const double _loopSeconds = 40;
  // How far the image travels (fraction of screen width / height).
  static const double _driftX = 0.10;
  static const double _driftY = 0.05;

  // Only used to repaint every frame; the position comes from _bgClock.
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
    final image = SizedBox.expand(
      child: Image.asset(
        'assets/Background.jpg',
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) {
          return const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF76B7F),
                  Color(0xFFB30B27),
                  Color(0xFF4A0B24),
                ],
              ),
            ),
          );
        },
      ),
    );

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF3A0B1E)),
          LayoutBuilder(
            builder: (context, constraints) {
              return ClipRect(
                child: AnimatedBuilder(
                  animation: _ticker,
                  child: image,
                  builder: (context, child) {
                    final t = (_bgClock.elapsedMicroseconds /
                            (_loopSeconds * 1000000)) %
                        1.0;
                    final dx = math.sin(2 * math.pi * t) *
                        constraints.maxWidth *
                        _driftX;
                    final dy = math.sin(4 * math.pi * t) *
                        constraints.maxHeight *
                        _driftY;
                    return Transform.translate(
                      offset: Offset(dx, dy),
                      // 1.3x gives spare image around the edges so the
                      // drift never shows a gap.
                      child: Transform.scale(scale: 1.3, child: child),
                    );
                  },
                ),
              );
            },
          ),
          // Soft dark layer so white text stays readable on the light pink.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kDeepRed.withValues(alpha: 0.38),
                  Colors.black.withValues(alpha: 0.10),
                ],
              ),
            ),
          ),
        ],
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

import 'package:flutter/material.dart';

class GlassScrollbar extends StatefulWidget {
  final ScrollController controller;
  final Widget child;
  final EdgeInsets inset;

  const GlassScrollbar({
    super.key,
    required this.controller,
    required this.child,
    this.inset = const EdgeInsets.fromLTRB(0, 8, 4, 8),
  });

  @override
  State<GlassScrollbar> createState() => _GlassScrollbarState();
}

class _GlassScrollbarState extends State<GlassScrollbar> {
  ScrollMetrics? _metrics;
  bool _dragging = false;

  void _update(ScrollMetrics metrics) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _metrics = metrics;
      });
    });
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth == 0 &&
        notification.metrics.axis == Axis.vertical) {
      _update(notification.metrics);
    }
    return false;
  }

  bool _onMetrics(ScrollMetricsNotification notification) {
    if (notification.depth == 0 &&
        notification.metrics.axis == Axis.vertical) {
      _update(notification.metrics);
    }
    return false;
  }

  void _dragBy(double dy, double travel) {
    final c = widget.controller;
    if (!c.hasClients) {
      return;
    }
    final max = c.position.maxScrollExtent;
    c.jumpTo((c.offset + dy * max / travel).clamp(0.0, max).toDouble());
  }

  void _jumpToTap(double dy, double thumbHeight, double travel) {
    final c = widget.controller;
    if (!c.hasClients) {
      return;
    }
    final max = c.position.maxScrollExtent;
    final fraction = ((dy - thumbHeight / 2) / travel).clamp(0.0, 1.0);
    c.animateTo(
      fraction.toDouble() * max,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Widget _buildBar(BoxConstraints constraints) {
    final m = _metrics;
    if (m == null) {
      return const SizedBox.shrink();
    }

    final max = m.maxScrollExtent;
    if (!max.isFinite || max <= 0) {
      return const SizedBox.shrink();
    }

    final trackHeight = constraints.maxHeight;
    final viewport = m.viewportDimension;
    final thumbHeight =
        (trackHeight * viewport / (max + viewport)).clamp(56.0, trackHeight)
            .toDouble();
    final travel = (trackHeight - thumbHeight).clamp(1.0, double.infinity)
        .toDouble();
    final progress = (m.pixels / max).clamp(0.0, 1.0).toDouble();
    final thumbTop = travel * progress;
    final side = _dragging ? 2.0 : 3.0;

    return SizedBox(
      width: 16,
      height: trackHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          _jumpToTap(details.localPosition.dy, thumbHeight, travel);
        },
        onVerticalDragStart: (_) {
          setState(() {
            _dragging = true;
          });
        },
        onVerticalDragUpdate: (details) {
          _dragBy(details.delta.dy, travel);
        },
        onVerticalDragEnd: (_) {
          setState(() {
            _dragging = false;
          });
        },
        onVerticalDragCancel: () {
          setState(() {
            _dragging = false;
          });
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Stack(
            children: [
              Positioned(
                left: 3,
                right: 3,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: side,
                right: side,
                top: thumbTop,
                height: thumbHeight,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Color(0xFFFFD0D8)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
    return Stack(
      children: [
        Positioned.fill(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: NotificationListener<ScrollMetricsNotification>(
              onNotification: _onMetrics,
              child: widget.child,
            ),
          ),
        ),
        Positioned(
          top: widget.inset.top,
          bottom: widget.inset.bottom,
          right: widget.inset.right,
          width: 16,
          child: LayoutBuilder(
            builder: (context, constraints) => _buildBar(constraints),
          ),
        ),
      ],
    );
  }
}
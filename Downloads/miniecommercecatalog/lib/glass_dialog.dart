import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'app_theme.dart';

class GlassDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;

  const GlassDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  static Widget cancel(
    BuildContext context, {
    String label = 'Cancel',
    Object? result,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () => Navigator.pop(context, result),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  static Widget primary({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: whiteButtonStyle(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kNavRed.withValues(alpha: 0.94),
                    const Color(0xFF7A0824).withValues(alpha: 0.96),
                  ],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Flexible(
                    child: SingleChildScrollView(
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                        child: content,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: actions,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
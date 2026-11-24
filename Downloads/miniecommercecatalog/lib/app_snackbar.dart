import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'app_theme.dart';

void showAppSnack(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_rounded,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.none,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: duration,
      content: _AppSnack(
        message: message,
        icon: icon,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    ),
  );
}

class _AppSnack extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _AppSnack({
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF3D7F).withValues(alpha: 0.35),
                blurRadius: 20,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF9A053E).withValues(alpha: 0.96),
                      const Color(0xFF700228).withValues(alpha: 0.96),
                      const Color(0xFF5A011E).withValues(alpha: 0.96),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(width: 10),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          onAction!();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            actionLabel!,
                            style: const TextStyle(
                              color: kPink,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
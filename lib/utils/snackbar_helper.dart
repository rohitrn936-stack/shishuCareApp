import 'package:flutter/material.dart';

/// Displays a sleek, compact floating toast banner near the TOP of the screen.
void showTopSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  IconData? icon,
  Duration duration = const Duration(seconds: 2),
}) {
  final mediaQuery = MediaQuery.of(context);
  final topPadding = mediaQuery.padding.top;
  final screenWidth = mediaQuery.size.width;

  final double topOffset = topPadding + 60.0;
  final double bottomMargin = mediaQuery.size.height - topOffset - 50.0;

  final double horizontalMargin = (screenWidth > 500)
      ? (screenWidth - 380) / 2
      : 16.0;

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      dismissDirection: DismissDirection.up,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: bottomMargin.clamp(0.0, mediaQuery.size.height - 100.0),
        left: horizontalMargin,
        right: horizontalMargin,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      backgroundColor: isError ? const Color(0xFFC62828) : const Color(0xFF23232E),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      duration: duration,
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? (isError ? Icons.error_outline_rounded : Icons.check_circle_rounded),
            color: isError ? Colors.white : const Color(0xFF66BB6A),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    ),
  );
}

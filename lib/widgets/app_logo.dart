import 'package:flutter/material.dart';
import 'package:web_page/constants/app_colours.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showBadge;

  const AppLogo({
    super.key,
    this.size = 56,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = size * 0.32;
    final iconSize = size * 0.55;
    final badgeSize = size * 0.34;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Outer Glow / Gradient Emblem Container
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF8E24AA),
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: size * 0.3,
                  offset: Offset(0, size * 0.12),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Translucent Inner Emblem Ring
                Container(
                  width: size * 0.78,
                  height: size * 0.78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.14),
                  ),
                ),
                // Main Child Care Icon
                Icon(
                  Icons.child_care_rounded,
                  color: Colors.white,
                  size: iconSize,
                ),
              ],
            ),
          ),

          // Healthcare Heart Badge Overlay
          if (showBadge && size >= 28)
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    color: Colors.redAccent,
                    size: badgeSize * 0.65,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppLogoHeader extends StatelessWidget {
  final double logoSize;
  final double fontSize;
  final Color? textColor;

  const AppLogoHeader({
    super.key,
    this.logoSize = 36,
    this.fontSize = 22,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(size: logoSize, showBadge: true),
        const SizedBox(width: 12),
        Text(
          'ShishuCare',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: fontSize,
            letterSpacing: -0.5,
            color: textColor ?? AppColors.text,
          ),
        ),
      ],
    );
  }
}

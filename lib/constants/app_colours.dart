
import 'package:flutter/material.dart';

/// Centralised palette for ShishuCare.
///
/// The original app used Flutter's Deep Purple palette. The redesign keeps
/// that identity and adds a few supporting shades so every screen feels
/// consistent.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF673AB7);
  static const Color primaryDark = Color(0xFF512DA8);
  static const Color primaryLight = Color(0xFF9575CD);
  static const Color background = Color(0xFFF6F1FB);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF241B2F);
  static const Color mutedText = Color(0xFF6F6878);
  static const Color border = Color(0xFFE7DEEF);
  static const Color success = Color(0xFF2E7D32);
  static const Color danger = Color(0xFFC62828);
  static const Color warning = Color(0xFFF57C00);
}

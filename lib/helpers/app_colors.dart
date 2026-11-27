// helpers/app_colors.dart
// ─── Palette de couleurs dynamique (thème sombre / clair) ────────────────────
import 'package:flutter/material.dart';
import 'notifiers.dart';

class AppColors {
  final Color bg;
  final Color card;
  final Color text;

  // La couleur accentuée reste dorée dans les deux thèmes
  static const Color accent = Color(0xFFC6A165);

  AppColors._({required this.bg, required this.card, required this.text});

  /// Retourne les couleurs adaptées au thème courant
  factory AppColors.current() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    return isDark ? AppColors._dark() : AppColors._light();
  }

  factory AppColors._dark() => AppColors._(
    bg: const Color(0xFF14100E),
    card: const Color(0xFF221A16),
    text: const Color(0xFFEFEBE9),
  );

  factory AppColors._light() => AppColors._(
    bg: const Color(0xFFF5EFE6),
    card: const Color(0xFFFFFFFF),
    text: const Color(0xFF2C1810),
  );
}
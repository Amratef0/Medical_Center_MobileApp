import 'package:flutter/material.dart';

/// كل الألوان هنا مأخوذة من نفس theme بتاع الموقع (tailwind.config.js)
/// عشان الابليكيشن يطلع بنفس شكل الويب سايت.
class AppColors {
  AppColors._();

  // Primary (Blue) - من primary.500 / 600 / 700
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryDarker = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);

  // Teal accent - من teal.500 / 600
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealDark = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFF2DD4BF);

  // Dark backgrounds - من dark.100 / 200 / 300
  static const Color bgLayer1 = Color(0xFF1E1E2E); // لون الكروت
  static const Color bgLayer2 = Color(0xFF181825); // خلفية الصفحة
  static const Color bgLayer3 = Color(0xFF11111B); // أغمق حاجة (اب بار / سايد بار)

  // نصوص
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);

  // حالات (نفس ألوان الـ status badges في الموقع)
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color border = Color(0xFF2E2E3E);
}

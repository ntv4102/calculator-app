import 'dart:ui';
import 'package:flutter/material.dart';

/// Hệ thống Design Tokens tuân thủ chuẩn `mobile-design`:
/// - Semantic color roles cho cả Light Mode (Chống chói ngoài nắng) & Dark Mode (Cân đêm / Rạng sáng)
/// - Tabular figures (`FontFeature.tabularFigures()`) cho toàn bộ số cân và tiền tệ
/// - Touch target tối thiểu >= 48dp (đạt chuẩn Android 48dp & iOS 44pt)
/// - Hệ thống góc bo (Radius 8 / 12 / 16) và nhịp khoảng cách 4pt nhất quán
class AppColors {
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceSubtle;
  final Color elevated;
  final Color text;
  final Color textMuted;
  final Color border;
  final Color borderStrong;
  final Color accentRice;
  final Color accentRiceSoft;
  final Color accentPig;
  final Color accentPigSoft;
  final Color onAccent;
  final Color danger;
  final Color dangerSoft;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;

  const AppColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceSubtle,
    required this.elevated,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.borderStrong,
    required this.accentRice,
    required this.accentRiceSoft,
    required this.accentPig,
    required this.accentPigSoft,
    required this.onAccent,
    required this.danger,
    required this.dangerSoft,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
  });

  /// Giao diện Sáng độ tương phản cao (Outdoor Glare-Safe Light Mode - WCAG AAA)
  static const AppColors light = AppColors(
    brightness: Brightness.light,
    background: Color(0xFFF3F5F4),
    surface: Color(0xFFFFFFFF),
    surfaceSubtle: Color(0xFFE9ECEA),
    elevated: Color(0xFFFFFFFF),
    text: Color(0xFF111714),
    textMuted: Color(0xFF49544E),
    border: Color(0xFFE2E8F0),
    borderStrong: Color(0xFFCBD5E1),
    accentRice: Color(0xFFEA580C),
    accentRiceSoft: Color(0xFFFFEDD5),
    accentPig: Color(0xFFEA580C),
    accentPigSoft: Color(0xFFFFEDD5),
    onAccent: Color(0xFFFFFFFF),
    danger: Color(0xFFB91C1C),
    dangerSoft: Color(0xFFFEF2F2),
    success: Color(0xFF15803D),
    successSoft: Color(0xFFF0FDF4),
    warning: Color(0xFFB45309),
    warningSoft: Color(0xFFFFFBEB),
  );

  /// Giao diện Tối chuyên biệt (Cân heo rạng sáng / Cân lúa ghe đêm - Near-black OLED safe)
  static const AppColors dark = AppColors(
    brightness: Brightness.dark,
    background: Color(0xFF0E1210),
    surface: Color(0xFF171D1A),
    surfaceSubtle: Color(0xFF212925),
    elevated: Color(0xFF232C27),
    text: Color(0xFFF1F5F3),
    textMuted: Color(0xFFA3B1AA),
    border: Color(0xFF2E3833),
    borderStrong: Color(0xFF4B5952),
    accentRice: Color(0xFF4ADE80),
    accentRiceSoft: Color(0xFF132A1E),
    accentPig: Color(0xFFF87171),
    accentPigSoft: Color(0xFF2C1517),
    onAccent: Color(0xFF09130D),
    danger: Color(0xFFF87171),
    dangerSoft: Color(0xFF2D1618),
    success: Color(0xFF4ADE80),
    successSoft: Color(0xFF132A1E),
    warning: Color(0xFFFBBF24),
    warningSoft: Color(0xFF2B2111),
  );

  static AppColors of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}

class AppTokens {
  /// Vùng chạm tối thiểu đạt chuẩn cả Android (48dp) và iOS (44pt)
  static const double minTouchTarget = 48.0;

  /// Nhịp khoảng cách 4pt
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;

  /// Hệ thống bo góc (Sharp/Soft Utilitarian)
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusPill = 999.0;

  /// Tabular figures giúp các con số cân nặng và tiền tệ thẳng hàng tuyệt đối
  static const List<FontFeature> tabularNums = [
    FontFeature.tabularFigures(),
  ];

  static TextStyle numericTitle(Color color) => TextStyle(
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: color,
        fontFeatures: tabularNums,
      );

  static TextStyle numericCell(Color color) => TextStyle(
        fontSize: 16,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: color,
        fontFeatures: tabularNums,
      );

  static TextStyle numericMetric(Color color) => TextStyle(
        fontSize: 15,
        height: 1.25,
        fontWeight: FontWeight.w800,
        color: color,
        fontFeatures: tabularNums,
      );

  static ThemeData buildTheme(Brightness brightness) {
    final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.accentRice,
      onPrimary: c.onAccent,
      secondary: c.accentPig,
      onSecondary: c.onAccent,
      error: c.danger,
      onError: c.onAccent,
      surface: c.surface,
      onSurface: c.text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      dividerColor: c.border,
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.text,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: c.text,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardTheme(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: c.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space12,
          vertical: space12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: c.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: c.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: c.accentRice, width: 2),
        ),
        labelStyle: TextStyle(color: c.textMuted, fontSize: 14),
      ),
    );
  }
}

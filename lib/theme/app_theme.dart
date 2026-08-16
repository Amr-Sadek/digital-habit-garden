import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFFF5F7F0);
  static const Color primaryColor = Color(0xFF4F7D4A);
  static const Color secondaryColor = Color(0xFF8FBF88);
  static const Color accentColor = Color(0xFFF2B84B);
  static const Color textColor = Color(0xFF263326);

  // ============================================================
  // DARK COLORS
  // ============================================================

  static const Color darkBackground = Color(0xFF101510);
  static const Color darkSurface = Color(0xFF182019);
  static const Color darkCard = Color(0xFF1E281F);
  static const Color darkCardSecondary = Color(0xFF243025);

  static const Color darkText = Color(0xFFE8F0E7);
  static const Color darkSecondaryText = Color(0xFFB9C5B8);

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.light,

      scaffoldBackgroundColor: backgroundColor,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),

      // ========================================================
      // APP BAR
      // ========================================================
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
      ),

      // ========================================================
      // CARDS
      // ========================================================
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),

      // ========================================================
      // INPUTS
      // ========================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),

      // ========================================================
      // NAVIGATION BAR
      // ========================================================
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,

        indicatorColor: secondaryColor.withValues(alpha: 0.35),

        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // ========================================================
      // BOTTOM SHEET
      // ========================================================
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // ========================================================
      // DIALOG
      // ========================================================
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),

      // ========================================================
      // SWITCH
      // ========================================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }

          return Colors.grey.shade500;
        }),

        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return secondaryColor.withValues(alpha: 0.5);
          }

          return Colors.grey.shade300;
        }),
      ),

      // ========================================================
      // TEXT
      // ========================================================
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textColor,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),

        headlineMedium: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),

        titleLarge: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),

        bodyLarge: TextStyle(color: textColor, fontSize: 16),

        bodyMedium: TextStyle(color: textColor, fontSize: 14),
      ),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.dark,

      scaffoldBackgroundColor: darkBackground,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,

        surface: darkSurface,

        // مهم عشان الـMaterial components
        // تستخدم ألوان مناسبة في Dark Mode.
        onSurface: darkText,
      ),

      // ========================================================
      // APP BAR
      // ========================================================
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: false,
      ),

      // ========================================================
      // CARDS
      // ========================================================
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,

        surfaceTintColor: Colors.transparent,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),

      // ========================================================
      // INPUTS
      // ========================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: darkCard,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: secondaryColor, width: 2),
        ),

        hintStyle: const TextStyle(color: darkSecondaryText),
      ),

      // ========================================================
      // NAVIGATION BAR
      // ========================================================
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,

        surfaceTintColor: Colors.transparent,

        indicatorColor: primaryColor.withValues(alpha: 0.35),

        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: darkText, fontWeight: FontWeight.w600),
        ),

        iconTheme: WidgetStateProperty.all(
          const IconThemeData(color: darkText),
        ),
      ),

      // ========================================================
      // BOTTOM SHEET
      // ========================================================
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCard,

        modalBackgroundColor: darkCard,

        surfaceTintColor: Colors.transparent,

        elevation: 8,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // ========================================================
      // DIALOG
      // ========================================================
      dialogTheme: const DialogThemeData(
        backgroundColor: darkCard,

        surfaceTintColor: Colors.transparent,

        elevation: 8,

        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),

        contentTextStyle: TextStyle(color: darkSecondaryText, fontSize: 15),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),

      // ========================================================
      // SWITCH
      // ========================================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return secondaryColor;
          }

          return const Color(0xFF7C877C);
        }),

        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withValues(alpha: 0.55);
          }

          return const Color(0xFF303830);
        }),
      ),

      // ========================================================
      // PROGRESS INDICATOR
      // ========================================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: secondaryColor,
        linearTrackColor: darkCardSecondary,
      ),

      // ========================================================
      // DIVIDERS
      // ========================================================
      dividerTheme: const DividerThemeData(
        color: Color(0xFF303A31),
        thickness: 1,
      ),

      // ========================================================
      // TEXT
      // ========================================================
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: darkText,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),

        headlineMedium: TextStyle(
          color: darkText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),

        titleLarge: TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),

        bodyLarge: TextStyle(color: darkText, fontSize: 16),

        bodyMedium: TextStyle(color: darkSecondaryText, fontSize: 14),
      ),
    );
  }
}

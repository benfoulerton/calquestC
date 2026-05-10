// lib/theme/app_theme.dart
//
// Material 3 Expressive theming.
//
// We expose:
//   - A set of named PRESETS (Ocean, Forest, Sunset, Synthwave, Mono, Coral, Mint).
//     Each is a seed Color the M3 algorithm expands into a full ColorScheme.
//   - Light + Dark theme builders that take a ColorScheme and produce a
//     fully wired ThemeData with Expressive defaults (large radii, expressive
//     typography, surfaceContainer-based tones, snappy motion).
//   - A bridge to Android 12+ wallpaper-derived dynamic colour: the user can
//     toggle it in settings; when on, we use the system-provided ColorScheme
//     instead of the preset.
//
// Pedagogically, theming matters: ADHD users benefit from agency, and a
// brighter or calmer scheme can make the difference between an engaging or
// overwhelming session. We default to a calm "Ocean" preset.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A named theme preset. The seedColor drives the entire ColorScheme.
class ThemePreset {
  const ThemePreset({
    required this.id,
    required this.name,
    required this.seedColor,
    required this.icon,
    required this.description,
    this.variant = DynamicSchemeVariant.tonalSpot,
    this.isPremium = false,
  });

  final String id;
  final String name;
  final Color seedColor;
  final IconData icon;
  final String description;
  final DynamicSchemeVariant variant;
  final bool isPremium;
}

class ThemePresets {
  ThemePresets._();

  static const ocean = ThemePreset(
    id: 'ocean',
    name: 'Ocean',
    seedColor: Color(0xFF0077B6),
    icon: Icons.waves_rounded,
    description: 'Calm blues. Easy on the eyes.',
  );

  static const forest = ThemePreset(
    id: 'forest',
    name: 'Forest',
    seedColor: Color(0xFF2D6A4F),
    icon: Icons.forest_rounded,
    description: 'Grounded greens. Studied vibe.',
  );

  static const sunset = ThemePreset(
    id: 'sunset',
    name: 'Sunset',
    seedColor: Color(0xFFE76F51),
    icon: Icons.wb_twilight_rounded,
    description: 'Warm oranges. Cosy.',
    variant: DynamicSchemeVariant.expressive,
  );

  static const synthwave = ThemePreset(
    id: 'synthwave',
    name: 'Synthwave',
    seedColor: Color(0xFFFF006E),
    icon: Icons.auto_awesome_rounded,
    description: 'Electric magentas. Late-night vibes.',
    variant: DynamicSchemeVariant.vibrant,
  );

  static const mono = ThemePreset(
    id: 'mono',
    name: 'Mono',
    seedColor: Color(0xFF1F2937),
    icon: Icons.contrast_rounded,
    description: 'Greyscale. Lowest stimulation.',
    variant: DynamicSchemeVariant.monochrome,
  );

  static const coral = ThemePreset(
    id: 'coral',
    name: 'Coral',
    seedColor: Color(0xFFFF6B6B),
    icon: Icons.spa_rounded,
    description: 'Soft pink-coral. Friendly.',
  );

  static const mint = ThemePreset(
    id: 'mint',
    name: 'Mint',
    seedColor: Color(0xFF06D6A0),
    icon: Icons.eco_rounded,
    description: 'Fresh mint. Spring energy.',
  );

  static const indigo = ThemePreset(
    id: 'indigo',
    name: 'Indigo',
    seedColor: Color(0xFF5B5FCF),
    icon: Icons.nightlight_rounded,
    description: 'Royal indigo. Focused.',
  );

  static const amber = ThemePreset(
    id: 'amber',
    name: 'Amber',
    seedColor: Color(0xFFF59E0B),
    icon: Icons.lightbulb_rounded,
    description: 'Bright amber. High energy.',
    variant: DynamicSchemeVariant.expressive,
  );

  static const all = <ThemePreset>[
    ocean,
    forest,
    sunset,
    synthwave,
    mono,
    coral,
    mint,
    indigo,
    amber,
  ];

  static ThemePreset byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => ocean);
}

/// Semantic colour roles we use that aren't part of the standard ColorScheme.
/// These are derived from the scheme but expose nicer names for our UI.
class AppPalette {
  const AppPalette({
    required this.success,
    required this.successContainer,
    required this.onSuccess,
    required this.warning,
    required this.warningContainer,
    required this.onWarning,
    required this.streak,
  });

  final Color success;
  final Color successContainer;
  final Color onSuccess;
  final Color warning;
  final Color warningContainer;
  final Color onWarning;
  final Color streak;

  /// Build a palette derived from the colour scheme. Greens and oranges
  /// shift with the active scheme's tertiary/error tones for a unified feel.
  factory AppPalette.fromScheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return AppPalette(
      success: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669),
      successContainer: isDark
          ? const Color(0xFF065F46)
          : const Color(0xFFD1FAE5),
      onSuccess: isDark ? const Color(0xFF052E16) : Colors.white,
      warning: isDark ? const Color(0xFFFCD34D) : const Color(0xFFD97706),
      warningContainer: isDark
          ? const Color(0xFF78350F)
          : const Color(0xFFFEF3C7),
      onWarning: isDark ? const Color(0xFF422006) : Colors.white,
      streak: const Color(0xFFEF8B25),
    );
  }
}

/// Theme builder. Given a ColorScheme, returns a fully configured ThemeData
/// with Material 3 Expressive defaults — bigger radii, snappier motion,
/// expressive typography.
class AppTheme {
  AppTheme._();

  /// Standard radii used across the app. M3 Expressive favours large radii.
  static const double radSmall = 12;
  static const double radMedium = 18;
  static const double radLarge = 24;
  static const double radPill = 999;

  static ThemeData build(ColorScheme scheme) {
    final base = scheme.brightness == Brightness.light
        ? ThemeData.light(useMaterial3: true)
        : ThemeData.dark(useMaterial3: true);

    final textTheme = _textTheme(scheme);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radLarge),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radLarge),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radLarge),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outlineVariant, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radLarge),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primaryContainer,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radPill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radMedium),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((s) {
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: s.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          );
        }),
        height: 70,
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 8,
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHigh,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withOpacity(0.12),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHigh,
        circularTrackColor: scheme.surfaceContainerHigh,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radLarge),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(radLarge + 4)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radMedium),
        ),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    final base = scheme.brightness == Brightness.light
        ? Typography.blackMountainView
        : Typography.whiteMountainView;
    return GoogleFonts.interTextTheme(base).copyWith(
      // Display — for the +XP toast and big numbers
      displayLarge: GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
        letterSpacing: -0.4,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
        letterSpacing: -0.3,
      ),
      // Headline — lesson titles
      headlineLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
        letterSpacing: -0.3,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      // Title — section heads, question stems
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      // Body
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
        height: 1.45,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: scheme.onSurfaceVariant,
      ),
      // Label — buttons
      labelLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: scheme.onPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: scheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// A monospace text style for math content (Roboto Mono renders Unicode math
/// symbols cleanly: ∫, ∂, π, ², etc.).
TextStyle mathStyle(BuildContext context, {double size = 16, FontWeight? weight}) {
  return GoogleFonts.robotoMono(
    fontSize: size,
    fontWeight: weight ?? FontWeight.w500,
    color: Theme.of(context).colorScheme.onSurface,
    height: 1.4,
  );
}

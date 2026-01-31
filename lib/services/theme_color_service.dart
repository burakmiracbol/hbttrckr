
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:hbttrckr/providers/scheme_provider.dart';
import '../universal_variables.dart';


// Keep a couple of default scheme objects (will be overridden by provider at runtime)
final defaultScheme = SchemeExpressive(
  isDark: false,
  contrastLevel: 0.0,
  sourceColorHct: Hct.fromInt(themeColor.toARGB32()),
);

// Convert various Scheme* objects into a Flutter ColorScheme. The material_color_utilities
// package uses different scheme classes but their fields are similarly named; this helper
// handles the common fields using dynamic access.
ColorScheme colorSchemeFromMaterial(dynamic s) {
  // Many Scheme classes expose fields directly; we try direct access first.
  Color c(Object? value, [int fallback = 0xFF000000]) {
    if (value is int) return Color(value);
    try {
      if (value != null) return Color(value as int);
    } catch (_) {}
    return Color(fallback);
  }

  // Use common names where possible; fall back to defaults if a field isn't present.
  return ColorScheme(
    brightness: (s?.isDark == true) ? Brightness.dark : Brightness.light,
    primary: c(s?.primary, Colors.teal.toARGB32()),
    onPrimary: c(s?.onPrimary, Colors.white.toARGB32()),
    primaryContainer: c(s?.primaryContainer, Colors.teal[700]!.toARGB32()),
    onPrimaryContainer: c(s?.onPrimaryContainer, Colors.white.toARGB32()),
    secondary: c(s?.secondary, Colors.tealAccent.toARGB32()),
    onSecondary: c(s?.onSecondary, Colors.black.toARGB32()),
    secondaryContainer: c(
      s?.secondaryContainer,
      Colors.tealAccent[100]?.toARGB32() ?? Colors.tealAccent.toARGB32(),
    ),
    onSecondaryContainer: c(s?.onSecondaryContainer, Colors.black.toARGB32()),
    tertiary: c(s?.tertiary, Colors.teal.toARGB32()),
    onTertiary: c(s?.onTertiary, Colors.white.toARGB32()),
    tertiaryContainer: c(
      s?.tertiaryContainer,
      Colors.teal[200]?.toARGB32() ?? Colors.teal.toARGB32(),
    ),
    onTertiaryContainer: c(s?.onTertiaryContainer, Colors.white.toARGB32()),
    error: c(s?.error, Colors.red.toARGB32()),
    onError: c(s?.onError, Colors.white.toARGB32()),
    errorContainer: c(
      s?.errorContainer,
      Colors.red[100]?.toARGB32() ?? Colors.red.toARGB32(),
    ),
    onErrorContainer: c(s?.onErrorContainer, Colors.white.toARGB32()),
    surface: c(s?.surface, Colors.grey[50]!.toARGB32()),
    onSurface: c(s?.onSurface, Colors.black.toARGB32()),
    surfaceContainerHighest: c(
      s?.surfaceVariant,
      Colors.grey[200]!.toARGB32(),
    ),
    onSurfaceVariant: c(s?.onSurfaceVariant, Colors.black.toARGB32()),
    outline: c(s?.outline, Colors.grey[600]!.toARGB32()),
    shadow: c(s?.shadow, Colors.black.toARGB32()),
    inverseSurface: c(s?.inverseSurface, Colors.grey[800]!.toARGB32()),
    onInverseSurface: c(s?.onSurface, Colors.white.toARGB32()),
    inversePrimary: c(s?.inversePrimary, Colors.tealAccent.toARGB32()),
    surfaceTint: c(s?.primary, Colors.teal.toARGB32()),
  );
}

// Build a material_color_utilities scheme object from provider values.
// This returns different Scheme* based on the provider's SchemeType selection.
dynamic buildMaterialScheme(SchemeProvider sp, bool isDark) {
  final hct = Hct.fromInt(sp.baseColorArgb);
  switch (sp.scheme) {
    case SchemeType.expressive:
      return SchemeExpressive(
        isDark: isDark,
        sourceColorHct: hct,
        contrastLevel: isDark ? 1.0 : 0.0,
      );
    case SchemeType.fidelity:
      return SchemeFidelity(
        isDark: isDark,
        sourceColorHct: hct,
        contrastLevel: isDark ? 1.0 : 0.0,
      );
    case SchemeType.fruitsalad:
    // material_color_utilities may not provide a dedicated "fruitsalad" class; use Expressive as a close default
      return SchemeExpressive(
        isDark: isDark,
        sourceColorHct: hct,
        contrastLevel: isDark ? 1.0 : 0.0,
      );
    case SchemeType.monochrome:
      return SchemeMonochrome(
        isDark: isDark,
        sourceColorHct: hct,
        contrastLevel: isDark ? 1.0 : 0.0,
      );
    case SchemeType.neutral:
      return SchemeNeutral(
        isDark: isDark,
        sourceColorHct: hct,
        contrastLevel: isDark ? 1.0 : 0.0,
      );
    case SchemeType.rainbow:
      return SchemeRainbow(
        isDark: isDark,
        sourceColorHct: hct,
        contrastLevel: isDark ? 1.0 : 0.0,
      );
    case SchemeType.tonalSpot:
      return SchemeTonalSpot(
        isDark: isDark,
        sourceColorHct: hct,
        contrastLevel: isDark ? 1.0 : 0.0,
      );
    case SchemeType.vibrant:
      return SchemeVibrant(
        isDark: isDark,
        sourceColorHct: hct,
        contrastLevel: isDark ? 1.0 : 0.0,
      );
  }
}
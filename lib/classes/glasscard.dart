import 'dart:ui';
import 'package:flutter/material.dart';

Widget liquidGlassContainer({required Widget child, double borderRadius = 24.0, required BuildContext context }) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final borderRadius = 24.0;
  final isDark = theme.brightness == Brightness.dark;

  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
// Uses surface with low opacity to allow background through
          color: colorScheme.surface.withOpacity(isDark ? 0.15 : 0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
// Provides the "glass edge" highlight
            color: colorScheme.onSurface.withOpacity(isDark ? 0.1 : 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}
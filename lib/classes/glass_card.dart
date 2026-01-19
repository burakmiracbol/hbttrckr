// hbttrckr: just a habit tracker
// Copyright (C) 2026  Burak Miraç Bol
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
          color: colorScheme.surface.withValues(alpha: isDark ? 0.15 : 0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
// Provides the "glass edge" highlight
            color: colorScheme.onSurface.withValues(alpha: isDark ? 0.1 : 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
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
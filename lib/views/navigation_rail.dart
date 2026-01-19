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
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' hide IconButton;

class NavigationRailMain extends StatefulWidget {
  const NavigationRailMain({super.key});

  @override
  State<NavigationRailMain> createState() => _NavigationRailMainState();
}

class _NavigationRailMainState extends State<NavigationRailMain> {
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      contentShape: StadiumBorder(),
      content: FluentTheme(
        data: FluentThemeData(
          navigationPaneTheme: NavigationPaneThemeData(
            backgroundColor: Colors.grey[200],
          ),
        ),
        child: Scaffold(
          body: Center(child: Text('Navigation Rail Example Content')),
        ),
      ),

      appBar: NavigationAppBar(
        title: Text('Navigation Rail Example'),
        decoration: ShapeDecoration(shape: StadiumBorder(), color: Colors.blue),
      ),
    );
  }
}

Widget gradientButton(
  BuildContext context,
  String text,
  VoidCallback onPressed,
) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: LinearGradient(
        colors: [colorScheme.primary, colorScheme.secondary],
      ),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(text, style: theme.textTheme.labelLarge),
    ),
  );
}

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
          body: Center(
            child: Text('Navigation Rail Example Content'),
          ),
        ),
      ),

      appBar: NavigationAppBar(
        title: Text('Navigation Rail Example'),
        decoration: ShapeDecoration(
          shape: StadiumBorder(),
          color: Colors.blue,
        )
      ),
    );
  }
}

Widget gradientButton(BuildContext context, String text, VoidCallback onPressed) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: LinearGradient(
        colors: [
          colorScheme.primary,
          colorScheme.secondary,
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withOpacity(0.3),
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


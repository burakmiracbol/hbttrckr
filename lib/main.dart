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

import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/material.dart';
import 'package:hbttrckr/providers/habit_provider.dart';
import 'package:hbttrckr/providers/notification_settings_provider.dart';
import 'package:hbttrckr/providers/style_provider.dart';
import 'package:hbttrckr/services/google_sign-in.dart';
import 'package:hbttrckr/services/notification_service.dart';
import 'package:hbttrckr/services/theme_color_service.dart';
import 'package:provider/provider.dart';
import 'package:hbttrckr/views/mainviews/main_app_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hbttrckr/providers/scheme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SchemeProvider early so saved preferences are loaded
  final schemeProvider = SchemeProvider();
  await schemeProvider.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeGoogleSignIn();
  seamlessAuthentication();

  // NotificationService'i başlat
  await NotificationService().initialize();

  // Recover any lost image picker data (Android may kill MainActivity during pick)
  try {
    final picker = ImagePicker();
    final LostDataResponse response = await picker.retrieveLostData();
    if (!response.isEmpty) {
      // If there are lost files, the app may want to process or store them.
      // We'll just log them for now; the Habit notes editor will handle loading images from file paths or data URLs.
      if (response.files != null) {
        for (final f in response.files!) {
          debugPrint('Recovered lost image: ${f.path}');
        }
      } else if (response.exception != null) {
        debugPrint('ImagePicker lost-data exception: ${response.exception}');
      }
    }
  } catch (_) {
    // ignore
  }

  // Create the theme provider instance here so we can read its initial isMica
  final initialTheme = CurrentThemeMode();

  if (kIsWeb) {
  } else if (defaultTargetPlatform == TargetPlatform.android) {
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
  } else if (defaultTargetPlatform == TargetPlatform.macOS) {
    await Window.initialize();
    await Window.setEffect(
      effect: initialTheme.isMica
          ? WindowEffect.mica
          : WindowEffect.transparent,
      color: Color(schemeProvider.baseColorArgb),
    );
    initialTheme.isMica
        ? Window.makeTitlebarOpaque()
        : Window.makeTitlebarTransparent();
  } else if (defaultTargetPlatform == TargetPlatform.windows) {
    await Window.initialize();
    await Window.setEffect(
      effect: initialTheme.isMica
          ? WindowEffect.mica
          : WindowEffect.transparent,
      color: Color(schemeProvider.baseColorArgb),
    );
    initialTheme.isMica
        ? Window.makeTitlebarOpaque()
        : Window.makeTitlebarTransparent();
  } else if (defaultTargetPlatform == TargetPlatform.linux) {
    await Window.initialize();
    await Window.setEffect(
      effect: initialTheme.isMica
          ? WindowEffect.mica
          : WindowEffect.transparent,
      color: Color(schemeProvider.baseColorArgb),
    );
    initialTheme.isMica
        ? Window.makeTitlebarOpaque()
        : Window.makeTitlebarTransparent();
  }
  initializeDateFormatting('tr_TR', null);
  runApp(
    MultiProvider(
      providers: [
        // provide the same instance so MyApp and widgets read the same object
        ChangeNotifierProvider<CurrentThemeMode>.value(value: initialTheme),
        ChangeNotifierProvider(create: (_) => StyleProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => NotificationSettings()),
        ChangeNotifierProvider<SchemeProvider>.value(value: schemeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = Provider.of<CurrentThemeMode>(context).currentMode;
    final schemeProvider = Provider.of<SchemeProvider>(context);

    // Build material scheme based on provider
    final lightMat = buildMaterialScheme(schemeProvider, false);
    final darkMat = buildMaterialScheme(schemeProvider, true);

    final colorSchemeLight = colorSchemeFromMaterial(lightMat);
    final colorSchemeDark = colorSchemeFromMaterial(darkMat);

    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('fr'),
        const Locale('de'),
        const Locale('es'),
        const Locale('tr'),
        const Locale('ru'),
      ],
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        bottomAppBarTheme: BottomAppBarThemeData(
          color: colorSchemeLight.onSecondary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorSchemeLight.onPrimary,
          elevation: 10,
        ),
        brightness: Brightness.light,
        colorScheme: colorSchemeLight,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        bottomAppBarTheme: BottomAppBarThemeData(
          color: colorSchemeDark.onSecondary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorSchemeDark.onPrimary,
          elevation: 10,
        ),
        colorScheme: colorSchemeDark,
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        overscroll: false,
      ),
      home: MainAppViewForMaterial(),
    );
  }
}

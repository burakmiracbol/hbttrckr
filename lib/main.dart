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
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hbttrckr/providers/habit_provider.dart';
import 'package:hbttrckr/providers/notification_settings_provider.dart';
import 'package:hbttrckr/providers/uix_provider.dart';
import 'package:hbttrckr/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:hbttrckr/views/main_app_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hbttrckr/providers/scheme_provider.dart';

Color themeColor = Colors.teal;

// Keep a couple of default scheme objects (will be overridden by provider at runtime)
final defaultScheme = SchemeExpressive(
  isDark: false,
  contrastLevel: 0.0,
  sourceColorHct: Hct.fromInt(themeColor.toARGB32()),
);

// Convert various Scheme* objects into a Flutter ColorScheme. The material_color_utilities
// package uses different scheme classes but their fields are similarly named; this helper
// handles the common fields using dynamic access.
ColorScheme _colorSchemeFromMaterial(dynamic s) {
  // Many Scheme classes expose fields directly; we try direct access first.
  Color _c(Object? value, [int fallback = 0xFF000000]) {
    if (value is int) return Color(value);
    try {
      if (value != null) return Color(value as int);
    } catch (_) {}
    return Color(fallback);
  }

  // Use common names where possible; fall back to defaults if a field isn't present.
  return ColorScheme(
    brightness: (s?.isDark == true) ? Brightness.dark : Brightness.light,
    primary: _c(s?.primary, Colors.teal.toARGB32()),
    onPrimary: _c(s?.onPrimary, Colors.white.toARGB32()),
    primaryContainer: _c(s?.primaryContainer, Colors.teal[700]!.toARGB32()),
    onPrimaryContainer: _c(s?.onPrimaryContainer, Colors.white.toARGB32()),
    secondary: _c(s?.secondary, Colors.tealAccent.toARGB32()),
    onSecondary: _c(s?.onSecondary, Colors.black.toARGB32()),
    secondaryContainer: _c(
      s?.secondaryContainer,
      Colors.tealAccent[100]?.toARGB32() ?? Colors.tealAccent.toARGB32(),
    ),
    onSecondaryContainer: _c(s?.onSecondaryContainer, Colors.black.toARGB32()),
    tertiary: _c(s?.tertiary, Colors.teal.toARGB32()),
    onTertiary: _c(s?.onTertiary, Colors.white.toARGB32()),
    tertiaryContainer: _c(
      s?.tertiaryContainer,
      Colors.teal[200]?.toARGB32() ?? Colors.teal.toARGB32(),
    ),
    onTertiaryContainer: _c(s?.onTertiaryContainer, Colors.white.toARGB32()),
    error: _c(s?.error, Colors.red.toARGB32()),
    onError: _c(s?.onError, Colors.white.toARGB32()),
    errorContainer: _c(
      s?.errorContainer,
      Colors.red[100]?.toARGB32() ?? Colors.red.toARGB32(),
    ),
    onErrorContainer: _c(s?.onErrorContainer, Colors.white.toARGB32()),
    surface: _c(s?.surface, Colors.grey[50]!.toARGB32()),
    onSurface: _c(s?.onSurface, Colors.black.toARGB32()),
    surfaceContainerHighest: _c(
      s?.surfaceVariant,
      Colors.grey[200]!.toARGB32(),
    ),
    onSurfaceVariant: _c(s?.onSurfaceVariant, Colors.black.toARGB32()),
    outline: _c(s?.outline, Colors.grey[600]!.toARGB32()),
    shadow: _c(s?.shadow, Colors.black.toARGB32()),
    inverseSurface: _c(s?.inverseSurface, Colors.grey[800]!.toARGB32()),
    onInverseSurface: _c(s?.onSurface, Colors.white.toARGB32()),
    inversePrimary: _c(s?.inversePrimary, Colors.tealAccent.toARGB32()),
    surfaceTint: _c(s?.primary, Colors.teal.toARGB32()),
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

final GoogleSignIn googleSignIn = GoogleSignIn.instance; // Singleton kullanımı
final ValueNotifier<GoogleSignInAccount?> googleUserNotifier =
    ValueNotifier<GoogleSignInAccount?>(null);

void initializeGoogleSignIn() {
  // Arka planda sessizce başlatıyoruz
  googleSignIn.initialize(
    // Web için clientId gerekebilir, Android/iOS için google-services.json yeterlidir
  ).then((_) {
    // Giriş olaylarını dinliyoruz
    googleSignIn.authenticationEvents.listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        googleUserNotifier.value = event.user;
      } else if (event is GoogleSignInAuthenticationEventSignOut) {
        googleUserNotifier.value = null;
      }
      print("Giriş Durumu Değişti: $event");
    }).onError((error) {
      print("Hata: $error");
    });

    // Daha önce giriş yapmış mı diye kontrol et (Lightweight)
    final attempt = googleSignIn.attemptLightweightAuthentication();
    if (attempt != null) {
      attempt.then((account) {
        if (account != null) {
          googleUserNotifier.value = account;
        }
      });
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SchemeProvider early so saved preferences are loaded
  final schemeProvider = SchemeProvider();
  await schemeProvider.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeGoogleSignIn();
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
        ChangeNotifierProvider(create: (_) => UIXProvider()),
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

    final colorSchemeLight = _colorSchemeFromMaterial(lightMat);
    final colorSchemeDark = _colorSchemeFromMaterial(darkMat);

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
      home: MainAppView(),
    );
  }
}

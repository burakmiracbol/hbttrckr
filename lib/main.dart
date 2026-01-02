import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter/material.dart';
import 'package:hbttrckr/providers/habitprovider.dart';
import 'package:provider/provider.dart';
import 'package:hbttrckr/views/mainappview.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';

final schemelight = SchemeMonochrome(
  isDark: false,
  contrastLevel: 0.4,
  // use explicit ARGB int for teal to avoid deprecated accessors
  sourceColorHct: Hct.fromInt(0xFF009688), // Colors.teal ARGB
);

final schemedark = SchemeMonochrome(
  isDark: true,
  contrastLevel: 1.0,
  sourceColorHct: Hct.fromInt(0xFF009688), // Colors.teal ARGB
);

final colorScheme1 = ColorScheme(
  brightness: Brightness.light,
  primary: Color(schemelight.primary),
  onPrimary: Color(schemelight.onPrimary),
  secondary: Color(schemelight.secondary),
  onSecondary: Color(schemelight.onSecondary),
  error: Color(schemelight.error),
  onError: Color(schemelight.onError),
  // use surface/onSurface instead of deprecated background/onBackground
  surface: Color(schemelight.surface),
  onSurface: Color(schemelight.onSurface),
);

final colorScheme2 = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(schemedark.primary),
  onPrimary: Color(schemedark.onPrimary),
  secondary: Color(schemedark.secondary),
  onSecondary: Color(schemedark.onSecondary),
  error: Color(schemedark.error),
  onError: Color(schemedark.onError),
  surface: Color(schemedark.surface),
  onSurface: Color(schemedark.onSurface),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      effect: initialTheme.isMica ? WindowEffect.mica : WindowEffect.transparent,
    );
  } else if (defaultTargetPlatform == TargetPlatform.windows) {
    await Window.initialize();
    await Window.setEffect(
      effect: initialTheme.isMica ? WindowEffect.mica : WindowEffect.transparent,
    );
  } else if (defaultTargetPlatform == TargetPlatform.linux) {
    await Window.initialize();
    await Window.setEffect(
      effect: initialTheme.isMica ? WindowEffect.mica : WindowEffect.transparent,
    );
  }
  initializeDateFormatting('tr_TR', null);
  runApp(
    MultiProvider(
      providers: [
        // provide the same instance so MyApp and widgets read the same object
        ChangeNotifierProvider<CurrentThemeMode>.value(value: initialTheme),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
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
          color: colorScheme1.onSecondary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme1.onPrimary,
          elevation: 10,
        ),
        brightness: Brightness.light,
        colorScheme: colorScheme1,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        bottomAppBarTheme: BottomAppBarThemeData(
          color: colorScheme2.onSecondary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme2.onPrimary,
          elevation: 10,
        ),
        colorScheme: colorScheme2,
      ),
      home: MainAppView(),
    );
  }
}

// const MainAppView(),
// const AdaptiveScaffoldMainView(),
// const NavigationRailMain(),

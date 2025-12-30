import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:hbttrckr/views/adaptivescaffoldmainview.dart';
import 'package:hbttrckr/views/navigationrail.dart';
import 'package:flutter/material.dart';
import 'package:hbttrckr/providers/habitprovider.dart';
import 'package:provider/provider.dart';
import 'package:hbttrckr/views/mainappview.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

final schemelight = SchemeMonochrome(
  isDark: false,
  contrastLevel: 0.4,
  sourceColorHct: Hct.fromInt(Colors.teal.value),
);

final schemedark = SchemeMonochrome(
  isDark: true,
  contrastLevel: 1.0,
  sourceColorHct: Hct.fromInt(Colors.teal.value),
);

final colorScheme1 = ColorScheme(
  brightness: Brightness.light,
  primary: Color(schemelight.primary),
  onPrimary: Color(schemelight.onPrimary),
  secondary: Color(schemelight.secondary),
  onSecondary: Color(schemelight.onSecondary),
  error: Color(schemelight.error),
  onError: Color(schemelight.onError),
  background: Color(schemelight.background),
  onBackground: Color(schemelight.onBackground),
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
  background: Color(schemedark.background),
  onBackground: Color(schemedark.onBackground),
  surface: Color(schemedark.surface),
  onSurface: Color(schemedark.onSurface),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
  } else if (defaultTargetPlatform == TargetPlatform.android) {
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
  } else if (defaultTargetPlatform == TargetPlatform.macOS) {
    await Window.initialize();
    await Window.setEffect(
      effect: isMica ? WindowEffect.mica : WindowEffect.transparent,
    );
  } else if (defaultTargetPlatform == TargetPlatform.windows) {
    await Window.initialize();
    await Window.setEffect(
      effect: isMica ? WindowEffect.mica : WindowEffect.transparent,
    );
  } else if (defaultTargetPlatform == TargetPlatform.linux) {
    await Window.initialize();
    await Window.setEffect(
      effect: isMica ? WindowEffect.mica : WindowEffect.transparent,
    );
  }
  initializeDateFormatting('tr_TR', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrentThemeMode()),
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
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
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
      themeMode: context.watch<CurrentThemeMode>().currentMode,
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

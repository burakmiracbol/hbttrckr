// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hbttrckr/main.dart';
import 'package:hbttrckr/providers/habit_provider.dart';
import 'package:hbttrckr/providers/notification_settings_provider.dart';
import 'package:hbttrckr/providers/scheme_provider.dart';
import 'package:hbttrckr/views/main_app_view.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'package:hbttrckr/views/habit_detail_screen.dart';
import 'package:hbttrckr/views/stats_view.dart';
import 'package:hbttrckr/classes/stats_card.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App builds main view', (WidgetTester tester) async {
    final schemeProvider = SchemeProvider();
    await schemeProvider.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CurrentThemeMode>(
            create: (_) => CurrentThemeMode(),
          ),
          ChangeNotifierProvider(
            create: (_) => HabitProvider(enableNotifications: false),
          ),
          ChangeNotifierProvider(create: (_) => NotificationSettings()),
          ChangeNotifierProvider<SchemeProvider>.value(value: schemeProvider),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MainAppView), findsOneWidget);
  });

  testWidgets('Tapping a habit does not throw provider listen assertion',
      (WidgetTester tester) async {
    final schemeProvider = SchemeProvider();
    await schemeProvider.init();
    final habitProvider = HabitProvider(enableNotifications: false);
    habitProvider.addHabitFromObject(
      Habit(
        id: '1',
        name: 'Read',
        description: '',
        group: 'Health',
        color: Colors.blue,
        createdAt: DateTime(2026, 1, 1),
        type: HabitType.task,
        icon: Icons.favorite,
        achievedCount: 0,
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CurrentThemeMode>(
            create: (_) => CurrentThemeMode(),
          ),
          ChangeNotifierProvider<HabitProvider>.value(value: habitProvider),
          ChangeNotifierProvider(create: (_) => NotificationSettings()),
          ChangeNotifierProvider<SchemeProvider>.value(value: schemeProvider),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    final habitTile = find.byType(ListTile).first;
    await tester.tap(habitTile);
    await tester.pumpAndSettle();

    expect(find.byType(HabitDetailScreen), findsOneWidget);
  });

  testWidgets('Stats view renders wide StatCard layout in wide tiles',
      (WidgetTester tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1200, 800);
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });

    final schemeProvider = SchemeProvider();
    await schemeProvider.init();
    final habitProvider = HabitProvider(enableNotifications: false);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CurrentThemeMode>(
            create: (_) => CurrentThemeMode(),
          ),
          ChangeNotifierProvider<HabitProvider>.value(value: habitProvider),
          ChangeNotifierProvider<SchemeProvider>.value(value: schemeProvider),
        ],
        child: const MaterialApp(home: StatisticsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final statCardFinder =
        find.widgetWithText(StatCard, 'Toplam Alışkanlık');
    expect(statCardFinder, findsOneWidget);
    expect(
      find.descendant(of: statCardFinder, matching: find.byType(Row)),
      findsOneWidget,
    );
  });
}

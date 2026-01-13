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

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:hbttrckr/classes/glasscard.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'package:hbttrckr/views/habitdetailscreen.dart';
import 'package:provider/provider.dart';
import 'package:hbttrckr/views/statsview.dart';
import 'package:hbttrckr/providers/habitprovider.dart';
import '../sheets/habit_add_sheet.dart';
import '../sheets/habits_summary_sheet.dart';
import '../sheets/main_settings_sheet.dart';
import 'habits_page.dart';

// TODO's taken from README:
//  Implement statistics page and strengthen strength calculation
//  Refactor Habit class and HabitProvider behavior
//  Add 'skip' support and reflect skipped days in detail calendar
//  Make detail screen completion UIs per habit type (task/count/time)
//  Add navigation/adaptive scaffold improvements (navigation view)
//  Background image and glass-like effects in parts
//  Replace many setState usages with Provider where appropriate
//  Add more habit properties (types, strength, icons) and auto-assign types
//  Add backup/account linking for syncing or local export
//  Add widgets for home screen and make desktop-specific designs

// TODO's
//
//  doğa modu
//  reklam fikri sağol
//
//  habit paylaşma özelliği olsun bujnun için de bir küçük eidget tasarlayalım ve bunun ss alma özelliği olsun bir tuşla şu pkaeti kullan screenshot: ^3.0.0
//
//  detail screende appbar şeffaf yapalım
//  habitler için not kısmında hatalar düzeltilsin
//  habitdetail screen hepsine bir glass glow ekle
//  windowsta uygulamanın o en yukardakı küçültme tam ekran yapma ve kapatma tuşunun olduğu bar transparan düğmesiyle etkileşime girildiğinde bozuluyor
//  strentgh gauge a içinde strength seviyesine göre bize laf söylesin
//  haftanın hangi gününden başladığı eklenmeli
//  habit gruplama olmalı
//  kodu düzeltmeli hızımızı artırır eğer düzenler isek
//  alarmın haftanın hangi günleri olduğunu ayarlama mevzusu halledilmeli
//  habitleri sadece isim logo ve action buttonları ile tam ekran gösterme yapmalı
//  custom bildirim gönderme olmalı
//  bir icon paketi oluşturlmalı veya bulunmalı ama bize uyumlu olsun
//  material 3 expressive veya material 3 tasarım biçimlerini uygulamaya koymalıyız
//  ana ekrana eklemelik widgetlar yapılmalı
//  windows gibi bilgisayarlara farklı bir tasarım olmalı
//

// TODO: ayarlar düğmesi ile bottom sheet açılacak ve farklı ayar menülerine gitme gösterilecek
// NOTE: sheet yapıldı

// TODO: mobilde tranparan yöntemleri bakılacak ve her yerde liquid glass kullanılmaya çalışılacak (transparan ekranda olmuyor çünkü içindeki şeyleri transparan arka planda göstermiyor bu son paket)

// TODO: habit yazı rengi de transparan olmaya göre bakılacak ayrıca bottom app bar a sonradan dönülecek çünkü rengi şüpheli

// isMica taşıdı: artık CurrentThemeMode içinde tutuluyor ve provider ile erişiliyor
// bool isMica = true;

// TODO : kod düzenlemesi yapılması lazım. Birgün alıp bu tüm belirli widgetları sayfaları felan ayrı dosyalara ayıralım

typedef OnHabitUpdated = void Function(Habit updatedHabit);
typedef OnHabitTapped = void Function(Habit habit);
typedef OnHabitDeleted = void Function(String id);

class CurrentThemeMode with ChangeNotifier {
  bool isDarkMode = true;
  ThemeMode currentMode = ThemeMode.system;

  bool isMica = true;

  void changeThemeMode() {
    isDarkMode = !isDarkMode;
    currentMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleMica() async {
    if (isMica) {
      await Window.setEffect(effect: WindowEffect.disabled);
      await Future.delayed(const Duration(milliseconds: 100));
      await Window.setEffect(effect: WindowEffect.transparent);
      isMica = false;
    } else {
      await Window.setEffect(effect: WindowEffect.aero, dark: false);
      isMica = true;
    }
    notifyListeners();
  }
}

class MainAppView extends StatefulWidget {
  const MainAppView({super.key});

  @override
  State<MainAppView> createState() => MainAppViewState();
}

class MainAppViewState extends State<MainAppView> {
  static TextEditingController accountController = TextEditingController();

  static TextEditingController passwordController = TextEditingController();

  late ThemeMode currentThemeMode = context
      .watch<CurrentThemeMode>()
      .currentMode;

  String titleForToday = "Today";
  String titleForYesterday = "Yesterday";
  String titleForTomorrow = "Tomorrow";

  bool isDarkMode = true;

  int _selectedIndex = 0;

  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
  }

  void showAddHabitSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(parentContext).viewInsets.bottom,
        ),
        child: AddHabitSheet(
          onAdd:
              ({
                required String name,
                String description = '',
                required Color color,
                required HabitType type,
                required IconData icon,
                double? targetCount,
                double? maxCount,
                double? targetSeconds,
                TimeOfDay? reminderTime,
                Set<int>? reminderDays,
              }) {
                parentContext.read<HabitProvider>().addHabit(
                  name: name,
                  description: description,
                  color: color,
                  type: type,
                  targetCount: targetCount,
                  maxCount: maxCount,
                  targetSeconds: targetSeconds?.toDouble(),
                  reminderTime: reminderTime,
                  reminderDays: reminderDays,
                  icon: icon,
                );

                Navigator.pop(sheetContext);
              },
        ),
      ),
    );
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _titleForSelectedDate(BuildContext context) {
    final sel = context.read<HabitProvider>().selectedDate ?? DateTime.now();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(sel.year, sel.month, sel.day);
    final diff = selected.difference(today).inDays;

    final lang = Localizations.localeOf(context).languageCode;

    if (lang == 'tr') {
      if (diff == 0) return 'Bugün';
      if (diff == 1) return 'Yarın';
      if (diff == -1) return 'Dün';
      if (diff > 1) return '${diff} gün sonra';
      return '${-diff} gün önce';
    }

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 1) return 'In $diff days';
    return '${-diff} days ago';
  }

  @override
  Widget build(BuildContext context) {
    var habits = context.watch<HabitProvider>().habits;
    return Scaffold(
      backgroundColor: context.watch<CurrentThemeMode>().isMica
          ? Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 1)
          : Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.3),
      floatingActionButton: liquidGlassContainer(
        context: context,
        child: FloatingActionButton(
          foregroundColor: context.watch<CurrentThemeMode>().isMica
              ? Theme.of(context).floatingActionButtonTheme.foregroundColor
              : Theme.of(context).floatingActionButtonTheme.foregroundColor
                    ?.withValues(alpha: 0.7),
          backgroundColor: context.watch<CurrentThemeMode>().isMica
              ? Theme.of(context).floatingActionButtonTheme.backgroundColor
              : Theme.of(context).floatingActionButtonTheme.backgroundColor
                    ?.withValues(alpha: 0.7),
          onPressed: () {},
          shape: StadiumBorder(),
          child: IconButton(
            onPressed: () => showAddHabitSheet(context),
            icon: Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      appBar: AppBar(
        title: Center(
          child: liquidGlassContainer(
            context: context,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 4.0,
                bottom: 4.0,
                left: 2.0,
                right: 8.0,
              ),
              child: Text(
                '  ${_selectedIndex == 0 ? _titleForSelectedDate(context) : "İstatistikler"}',
              ),
            ),
          ),
        ),

        backgroundColor: context.watch<CurrentThemeMode>().isMica
            ? Theme.of(
                context,
              ).appBarTheme.backgroundColor?.withValues(alpha: 1)
            : Theme.of(
                context,
              ).appBarTheme.backgroundColor?.withValues(alpha: 0.2),

        elevation: 10,
        leading: Builder(
          builder: (BuildContext context) {
            return Consumer<HabitProvider>(
              builder: (ctx, habitProvider, child) {
                final combinedColor = habitProvider.getCombinedMixedColor();
                return liquidGlassContainer(
                  context: context,
                  child: IconButton(
                    style: IconButton.styleFrom(padding: EdgeInsets.all(0)),
                    icon: Icon(
                      Icons.format_list_bulleted,
                      color: combinedColor,
                    ),
                    onPressed: () {
                      showHabitsSummarySheet(context);
                    },
                  ),
                );
              },
            );
          },
        ),

        actions: [
          liquidGlassContainer(
            context: context,
            child: IconButton(
              onPressed: () {
                showMainSettingsSheet(
                  context,
                  accountController,
                  passwordController,
                );
              },
              icon: Icon(Icons.settings),
            ),
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? buildHabitsPage(
              onDateSelected: (date) {
                context.read<HabitProvider>().setSelectedDate(date);
              },
              habits: habits,
              onHabitTapped: (habit) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HabitDetailScreen(
                      habitId: habit.id,
                      selectedDate:
                          context.read<HabitProvider>().selectedDate ??
                          DateTime.now(),
                      onHabitUpdated: (updatedHabit) {
                        setState(() {
                          // habits listesi unmodifiable olduğu için yeni liste oluştur
                          final index = habits.indexWhere(
                            (h) => h.id == updatedHabit.id,
                          );
                          if (index != -1) {
                            habits = [
                              ...habits.sublist(0, index),
                              updatedHabit,
                              ...habits.sublist(index + 1),
                            ];
                          }
                        });

                        // HabitProvider'ı güncelle - bu bildirimleri yeniden planlar
                        context.read<HabitProvider>().updateHabit(updatedHabit);
                      },
                      onHabitDeleted: (String id) {
                        setState(() {
                          habits = habits.where((h) => h.id != id).toList();
                        });
                        // HabitProvider'dan da sil (bildirimler iptal edilecek)
                        context.read<HabitProvider>().deleteHabit(id);
                      },
                    ),
                  ),
                );
              },
              onHabitUpdated: (updatedHabit) {
                // bu satır aslında gerekmiyor çünkü Navigator içinden çağırılıyor
                // ama tutarlılık için bırakabilirsin
              },
              onHabitDeleted: (String id) {
                // 1. Önce sil
                setState(() {
                  habits.removeWhere((h) => h.id == id);
                });

                // 2. Sonra tekrar ekle (eğer edit yapıyorsan)
                final habit = habits.firstWhere(
                  (h) => h.id == id,
                ); // habit burada tanımlı!

                context.read<HabitProvider>().addHabit(
                  name: habit.name,
                  description: habit.description,
                  color: habit.color,
                  type: habit.type,
                  targetCount: habit.targetCount,
                  targetSeconds: habit.targetSeconds,
                  reminderTime: habit.reminderTime,
                  reminderDays: habit.reminderDays,
                  icon: habit.icon,
                );
              },
            ) // 1. sayfa: alışkanlıklar
          : StatisticsScreen(), // 2. sayfa: istatistikler
      bottomNavigationBar: BottomAppBar(
        color: context.watch<CurrentThemeMode>().isMica
            ? Theme.of(context).bottomAppBarTheme.color?.withValues(alpha: 1)
            : Theme.of(context).bottomAppBarTheme.color?.withValues(alpha: 0.2),
        elevation: 10,
        shape: CircularNotchedRectangle(),
        clipBehavior: Clip.hardEdge,
        notchMargin: 15.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              style: IconButton.styleFrom(
                shape: StadiumBorder(),
                foregroundColor: _selectedIndex == 0
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey,
              ),
              icon: Icon(Icons.checklist),
              onPressed: () => onItemTapped(0),
            ),
            IconButton(
              style: IconButton.styleFrom(
                shape: StadiumBorder(),
                foregroundColor: _selectedIndex == 1
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey,
              ),
              icon: Icon(Icons.bar_chart),
              onPressed: () => onItemTapped(1),
            ),
          ],
        ),
      ),
    );
  }
}

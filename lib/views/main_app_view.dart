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
import 'package:hbttrckr/classes/glass_card.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'package:hbttrckr/views/habit_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:hbttrckr/views/stats_view.dart';
import 'package:hbttrckr/providers/habit_provider.dart';
import '../providers/scheme_provider.dart';
import '../actions/main_view/habit_add_sheet.dart';
import '../actions/main_view/habits_summary_sheet.dart';
import '../actions/main_view/main_settings_sheet.dart';
import 'habits_page.dart';

// TODO's taken from README:
//  Implement statistics page and strengthen strength calculation
//  Refactor Habit class and HabitProvider behavior
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
//    sheetler açılırkan iki yaprak açılma yüksekliğine göre 0 derceden 90 dereceye kadar dönecek mesela
//      Bunun için Transform.rotate kullanılacak
//    .
//
//  slider kullanılabilir
//  Animated Widgetlar:
//    AnimatedContainer
//    AnimatedOpacity
//    AnimatedAlign
//    AnimatedPositioned
//    AnimatedDefaultTextStyle
//    AnimatedTheme
//    AnimatedList
//    AnimatedSwitcher
//    AnimatedRotation
//    AnimatedScale
//    AlignTransition
//
//  animated widgetlar kullaılnması
//  tamamlama efektleri
//  reklam fikri sağol
//
//
//  habits_page den girdim habite sonra ekranı büyülttüm sonra geri çıktım sonra deadlock yedik (assertion)
//    bunun için farklı yöntemler denemeliyiz engellemek için future.microtask gibi ama gene de hata kodu şu
//    ======== Exception caught by scheduler library =====================================================
//    The following assertion was thrown during a scheduler callback:
//    'package:flutter/src/rendering/mouse_tracker.dart': Failed assertion: line 199 pos 12: '!_debugDuringDeviceUpdate': is not true.
//
//
//    Either the assertion indicates an error in the framework itself, or we should provide substantially more information in this error message to help you determine and fix the underlying cause.
//    In either case, please report this assertion by filing a bug on GitHub:
//    https://github.com/flutter/flutter/issues/new?template=02_bug.yml
//
//    When the exception was thrown, this was the stack:
//    #2      MouseTracker._deviceUpdatePhase (package:flutter/src/rendering/mouse_tracker.dart:199:12)
//    #3      MouseTracker.updateAllDevices (package:flutter/src/rendering/mouse_tracker.dart:367:5)
//    #4      RendererBinding._scheduleMouseTrackerUpdate.<anonymous closure> (package:flutter/src/rendering/binding.dart:512:22)
//    #5      SchedulerBinding._invokeFrameCallback (package:flutter/src/scheduler/binding.dart:1434:15)
//    #6      SchedulerBinding.handleDrawFrame (package:flutter/src/scheduler/binding.dart:1361:11)
//    #7      SchedulerBinding._handleDrawFrame (package:flutter/src/scheduler/binding.dart:1200:5)
//    #8      _invoke (dart:ui/hooks.dart:356:13)
//    #9      PlatformDispatcher._drawFrame (dart:ui/platform_dispatcher.dart:444:5)
//    #10     _drawFrame (dart:ui/hooks.dart:328:31)
//    (elided 2 frames from class _AssertionError)
//    ====================================================================================================
//    yani gene mousetracker hatası
//
//  detailscreende rate of doing
//  rate of doing atlananlar boyaması ??
//  habit paylaşma da overflowlar var düzeltilmesi gereken ve ayrıca o widgetı daha güzel yap
//  statsview gridview overflow düzeltilmeli
//  windowsta uygulamanın o en yukardakı küçültme tam ekran yapma ve kapatma tuşunun olduğu bar transparan düğmesiyle etkileşime girildiğinde bozuluyor
//
//  detail screende appbar şeffaf yapalım
//  sadece calendar bölümü olabilir tek sferlik eventler için
//  genel bir kronometre süre sayar da eklenebilir
//  habitler için not kısmında hatalar düzeltilsin
//  habitdetail screen hepsine bir glass glow ekle
//  strentgh gauge a içinde strength seviyesine göre bize laf söylesin detail screende mesela strength levele göre sözler ve her zaman aynı sözler olmasın diye random sayı ile aynı seviyede farklı quote lar görünebilir
//  haftanın hangi gününden başladığı eklenmeli
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

  bool isDarkMode = true;

  int _selectedIndex = 0;

  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
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
      if (diff > 1) return '$diff gün sonra';
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
      floatingActionButton: glassContainer(
        shape: BoxShape.circle,
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
          child: glassContainer(
            context: context,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 4.0,
                bottom: 4.0,
                left: 2.0,
                right: 11.0,
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
                return Padding(
                  padding: EdgeInsets.fromLTRB(8,4,4,4),
                  child: glassContainer(
                    shape: BoxShape.circle,
                    context: context,
                    child: IconButton(
                      style: IconButton.styleFrom(padding: EdgeInsets.all(4)),
                      icon: Icon(
                        Icons.format_list_bulleted,
                        color: combinedColor,
                      ),
                      onPressed: () {
                        showHabitsSummarySheet(context);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: glassContainer(
              shape: BoxShape.circle,
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
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? Container(
        color: Colors.black12,
            child: buildHabitsPage(
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
                  context.read<HabitProvider>().setGroupToView(null);
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
              ),
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

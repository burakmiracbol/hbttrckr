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
import 'package:provider/provider.dart';
import 'package:hbttrckr/classes/glass_card.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'package:hbttrckr/views/habit_detail_screen.dart';
import 'package:hbttrckr/views/stats_view.dart';
import 'package:hbttrckr/providers/habit_provider.dart';
import 'package:hbttrckr/providers/scheme_provider.dart';
import 'package:hbttrckr/actions/main_view/habit_add_sheet.dart';
import 'package:hbttrckr/actions/main_view/habits_summary_sheet.dart';
import 'package:hbttrckr/actions/main_view/main_settings_sheet.dart';
import 'package:hbttrckr/services/google_sign-in.dart';
import 'package:hbttrckr/views/habits_page.dart';

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
//
//  TODO: Universallness in design
//
//  Linux için google sign-in (firebase auth gerekli google sign-inde sıkıntı yok)
//
//  mobilde transparanlık araştırılacak
//
//  açılış ekranı ilk kullananlar için
//
//  shared_preferences ile daha fazla ayar cihaza kaydedilmeli mesela en son şeffaf bıraktım niye bir sonrakinde şeffaf değil için
//
//  windowsta farklı bir arayüz tasarımı seçeneği
//    kullanıcıya başta windows önerilen mi yoksa mobil önerilen mi diye sorulacak
//
//  alarmın haftanın hangi günleri olduğunu ayarlama mevzusu halledilmeli
//  habitleri sadece isim logo ve action buttonları ile tam ekran gösterme yapmalı
//
//  ayarlarda tercihler bölümüne tonla ayar gelicek
//    arkaplanı image yapma
//    şefffalıkla ilgili nerenin şeffaflığı nerede naslı olacak
//      mesela habit detail screen hep mi şeffaf olsun yoksa sadece şeffaf modu açıldığında mı
//    tasarımlar kişiselleştirilebilecek
//      detail screen page olarak mı görüntülenecek ya da sheet olarak mı
//      veya habits page de görünüm nasıl olacak ikili coolumn mu üçlü mü tekli mi
//      veya settings logosu yerine kullanıcı fotosu mu gelmeli
//      time ve count selector sheetlerde slider lar yatay mı olacak
//    deneyimler için ayarlar değişitrilebilecek
//      haftanın hangi gününden başladığı eklenmeli
//
//  detail screen şeffaflık desteği glow ve liquidler bozulmadan (tahminimce bozulmaz)
//  tüm sheetlerin tasarımı düzeltilecek ve main settings sheet gibi olacak
//  rate of doing atlananlar boyaması ??
//  windowsta uygulamanın o en yukardakı küçültme tam ekran yapma ve kapatma tuşunun olduğu bar transparan düğmesiyle etkileşime girildiğinde bozuluyor
//
//  detail screende appbar şeffaf yapalım
//  sadece calendar bölümü olabilir tek sferlik eventler için
//  genel bir kronometre süre sayar da eklenebilir
//  habitler için not kısmında hatalar düzeltilsin
//  strentgh gauge a içinde strength seviyesine göre bize laf söylesin detail screende mesela strength levele göre sözler ve her zaman aynı sözler olmasın diye random sayı ile aynı seviyede farklı quote lar görünebilir
//  kodu düzeltmeli hızımızı artırır eğer düzenler isek
//  custom bildirim gönderme olmalı
//  bir icon paketi oluşturlmalı veya bulunmalı ama bize uyumlu olsun
//  material 3 expressive veya material 3 tasarım biçimlerini uygulamaya koymalıyız
//  ana ekrana eklemelik widgetlar yapılmalı
//
// note for universallness
//
//"Material ve LiquidGlass" karışımı bir tasarımın varsa, aslında zaten **Custom (Özel)** bir yol çizmişsin demektir. Bu harika bir haber, çünkü tamamen standart Material'e bağlı kalmamış olman işimizi kolaylaştırır.
//
// Eğer altyapın düzenliyse, bu universal sisteme geçişi **4 ile 8 saat** arasında (bir iş gününde) iskelet olarak ayağa kaldırabiliriz.
//
// Neden bu kadar kısa? Çünkü her şeyi sıfırdan yazmayacağız, sadece **"Yönlendirme ve Kapsayıcı"** (Routing & Wrapper) mantığını değiştireceğiz.
//
// İşte bu süreci nasıl böleceğimiz:
//
// ### 1. Tasarım Seçim Ekranı ve Local Storage (1 Saat)
//
// Uygulama ilk açıldığında çalışacak küçük bir `Onboarding` ekranı. Seçilen stil `SharedPreferences`'e kaydedilir.
//
// * "iOS Stili (Alt Menü)"
// * "Desktop Stili (Yan Menü)"
// * "Liquid Stili (Floating/Yüzer Menü)"
//
// ### 2. "Layout Switcher" (Kapsayıcı) Yazımı (2-3 Saat)
//
// Burası işin beyni. `Scaffold` yerine geçecek bir `MainLayout` widget'ı yazacağız. Bu widget, seçilen stile göre `body`'yi sarmalayacak:
//
// * **Stil A:** `Scaffold` + `BottomNavigationBar`
// * **Stil B:** `Row` [ `NavigationRail` (Sidebar) + `VerticalDivider` + `Expanded(body)` ]
// * **Stil C:** `Stack` [ `body` + `Positioned(LiquidFloatingBar)` ]
//
// ### 3. Widget'ları "Stil-Duyarlı" Hale Getirme (2-4 Saat)
//
// En çok zaman alacak ama en keyifli kısım burası. Kendi "Atomic" widget'larını oluşturmalısın. Örneğin bir `MyButton` widget'ın olacak ve içeride şuna bakacak:
//
// ```dart
// Widget build(BuildContext context) {
//   final style = Provider.of<ThemeProvider>(context).currentStyle;
//
//   if (style == AppDesignStyle.liquid) {
//     return GlassButton(child: child); // Senin LiquidGlass tasarımın
//   } else if (style == AppDesignStyle.ios) {
//     return CupertinoButton(child: child);
//   }
//   return ElevatedButton(child: child); // Default Material
// }
//
// ```
//
// ### Neden LiquidGlass İşini Kolaylaştırıyor?
//
// LiquidGlass zaten standart dışı (custom) bir yapı olduğu için, `MaterialApp`'in getirdiği katı kuralları (Elevation, Shadow vb.) muhtemelen çoktan ezmişsin (override etmişsin). Bu da senin tasarım dilini "bağımsız" bir kütüphane gibi her platforma taşımanı sağlar.
//
// ---
//
// ### Strateji Önerisi:
//
// Şu anki Material kodunu bozmadan, sadece **"Navigation"** (Menülerin yeri) kısmını ayırarak başla. İçerideki sayfaların (Content) Material kalması başlangıçta kimseyi rahatsız etmez. Önce uygulamanın "iskeletini" platforma veya seçime göre hareket ettirelim.
//
// **Hadi başlayalım mı?**
// Önce şu meşhur "MainLayout" iskeletini kuralım mı? Yani; seçim yapıldığında menü alttan hop diye yana kayacak şekilde bir yapı kuralım mı?
//

typedef OnHabitUpdated = void Function(Habit updatedHabit);
typedef OnHabitTapped = void Function(Habit habit);
typedef OnHabitDeleted = void Function(String id);

class MainAppViewForMaterial extends StatefulWidget {
  const MainAppViewForMaterial({super.key});

  @override
  State<MainAppViewForMaterial> createState() => MainAppViewForMaterialState();
}

class MainAppViewForMaterialState extends State<MainAppViewForMaterial> {
  int _selectedIndex = 0;
  double _leftPanelWidth = 300.0; // Başlangıç genişliği sağ panel için
  List<Habit> habits = [];

  @override
  void initState() {
    googleSignIn.silentSignIn();
    super.initState();
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

  List<NavigationDestination> get _destinations => const [
    NavigationDestination(icon: Icon(Icons.checklist), label: 'Alışkanlıklar'),
    NavigationDestination(icon: Icon(Icons.bar_chart), label: 'İstatistikler'),
  ];

  Habit? _selectedHabitForDetail; // Sağ panelde görünecek olan

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 600;
    final bool isExpanded = width >= 600 && width < 1024; // Tablet/Yarım ekran
    final bool isLargeScreen = width >= 1324; // Geniş Masaüstü

    return Scaffold(
      // Mica/Glass Arkaplan Mantığın
      backgroundColor: context.watch<CurrentThemeMode>().isMica
          ? Theme.of(context).scaffoldBackgroundColor
          : Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.3),

      // Sadece Mobilde FAB göster
      floatingActionButton: isMobile ? _buildFab(context) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      appBar: _buildAppBar(context),

      // ANA GÖVDE: Row ile yan menü ve içeriği ayırıyoruz
      body: Row(
        children: [
          // Desktop/Tablet için Yan Menü (NavigationRail)
          if (!isMobile) _buildNavigationRail(context, isLargeScreen),

          // Asıl İçerik
          // Expanded(
          //   child: _selectedIndex == 0
          //       ? _buildHabitsList(context, habits)
          //       : StatisticsScreen(),
          // ),
          Expanded(
            child: _selectedIndex == 0
                ? _buildMainContent(context, !isMobile)
                : StatisticsScreen(),
          ),
        ],
      ),

      // Sadece Mobilde Alt Menü
      bottomNavigationBar: isMobile ? _buildBottomAppBar(context) : null,
    );
  }


  // --- WIDGET PARÇALARI ---

  Widget _buildMainContent(BuildContext context, bool showDetailPanel) {
    var habits = context.watch<HabitProvider>().habits;

    return Row(
      children: [
        // SOL TARAF: Liste Sayfası
        SizedBox(
          width: _leftPanelWidth,
          child: Align(
            alignment: Alignment.topCenter,
            child: buildHabitsPage(
              habits: habits,
              // onHabitTapped burada kritik:
              onHabitTapped: (habit) {
                if (showDetailPanel) {
                  setState(
                    () => _selectedHabitForDetail =
                        _selectedHabitForDetail == null ? habit : null,
                  );
                } else {
                  _navigateToDetail(context, habit); // Mobilde tam sayfa git
                }
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
              onDateSelected: (DateTime selectedDate) {
                // 1. Provider'daki tarihi güncelle (Tüm uygulama duysun)
                context.read<HabitProvider>().setSelectedDate(selectedDate);

                // 2. Eğer sağ panelde bir habit açıksa, o habitin seçili tarihteki
                // verilerini göstermesi için sağ paneli tetikle
                if (_selectedHabitForDetail != null) {
                  setState(() {
                    // Sadece arayüzü tazelemek için (rebuild)
                  });
                }
              },
            ),
          ),
        ),

        if (showDetailPanel) ...[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              setState(() {
                // Sürükleme miktarı kadar genişliği artır/azalt
                _leftPanelWidth += details.delta.dx;

                // Sınır koyalım ki panel kaybolmasın veya çok büyümesin
                if (_leftPanelWidth < 200) _leftPanelWidth = 200;
                if (_leftPanelWidth > 600) _leftPanelWidth = 600;
              });
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight, // Fare üzerine gelince ikon değişsin
              child: Container(
                width: 10, // Tıklama alanı (Görünmez ama geniş)
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300], // Ortadaki ince çizgi
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedHabitForDetail != null
                  ? HabitDetailScreen(
                      key: ValueKey(_selectedHabitForDetail!.id),
                      habitId: _selectedHabitForDetail!.id,
                      selectedDate:
                          context.read<HabitProvider>().selectedDate ??
                          DateTime.now(),
                      isPanel: true, // Sağ panelde olduğu için true

                      onHabitUpdated: (updatedHabit) {
                        // Önce provider'ı güncelle
                        context.read<HabitProvider>().updateHabit(updatedHabit);
                        // Sonra yerel referansı güncelle ki sağ panel yeni veriyi bassın
                        setState(() {
                          _selectedHabitForDetail = updatedHabit;
                        });
                      },
                      onHabitDeleted: (id) {
                        context.read<HabitProvider>().deleteHabit(id);
                        setState(() => _selectedHabitForDetail = null);
                      },
                    )
                  : _buildEmptyState(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hafif şeffaf bir ikon
          Icon(
            Icons.add_circle_outline, // Veya 'touch_app' / 'select_all'
            size: 80,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          // Senin o meşhur glassContainer yapın varsa içine alabilirsin
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Text(
              "Detayları görüntülemek için\nbir alışkanlık seçin",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Habit habit) {
    final width = MediaQuery.of(context).size.width;

    final bool isExpanded = width >= 600 && width < 1024;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(
          habitId: habit.id,
          selectedDate:
              context.read<HabitProvider>().selectedDate ?? DateTime.now(),
          // Mobilde açıldığı için panel dostu modunu KAPATIYORUZ
          isPanel: isExpanded,
          // Callback'leri buraya da eklemeyi unutma (Update/Delete için)
          onHabitUpdated: (updatedHabit) {
            // Önce provider'ı güncelle
            context.read<HabitProvider>().updateHabit(updatedHabit);
            // Sonra yerel referansı güncelle ki sağ panel yeni veriyi bassın
            setState(() {
              _selectedHabitForDetail = updatedHabit;
            });
          },
          onHabitDeleted: (id) {
            context.read<HabitProvider>().deleteHabit(id);
            setState(() => _selectedHabitForDetail = null);
          },
        ),
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context, bool isLargeScreen) {
    return Container(
      // Yan menüyü de cam yapalım mı? Evet!
      child: glassContainer(
        borderRadiusRect: 0, // Sol kenara sıfırla
        context: context,
        child: IntrinsicWidth(
          child: NavigationRail(
            extended: isLargeScreen,
            backgroundColor:
                Colors.transparent, // Glass üstünde sırıtmaması için
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            leading: _buildFab(
              context,
            ), // Desktop'ta artı butonu yukarıda şık durur
            destinations: _destinations
                .map(
                  (d) => NavigationRailDestination(
                    icon: d.icon,
                    label: Text(d.label),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      color: context.watch<CurrentThemeMode>().isMica
          ? Theme.of(context).bottomAppBarTheme.color
          : Theme.of(context).bottomAppBarTheme.color?.withValues(alpha: 0.2),
      elevation: 10,
      shape: const CircularNotchedRectangle(),
      notchMargin: 15.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIconButton(0, Icons.checklist),
          _navIconButton(1, Icons.bar_chart),
        ],
      ),
    );
  }

  Widget _navIconButton(int index, IconData icon) {
    return IconButton(
      style: IconButton.styleFrom(
        shape: const StadiumBorder(),
        foregroundColor: _selectedIndex == index
            ? Theme.of(context).colorScheme.secondary
            : Colors.grey,
      ),
      icon: Icon(icon),
      onPressed: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildFab(BuildContext context) {
    return glassContainer(
      shape: BoxShape.circle,
      context: context,
      child: FloatingActionButton(
        elevation: 0, // Glass arkasında gölge karmaşası olmasın
        backgroundColor: Colors.transparent,
        onPressed: () => showAddHabitSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Mevcut Alışkanlık Listesi Mantığın (Kırpılmış hali)
  // Widget _buildHabitsList(BuildContext context, List<Habit> habits) {
  //   return buildHabitsPage(
  //     onDateSelected: (date) {
  //       context.read<HabitProvider>().setSelectedDate(date);
  //     },
  //     habits: habits,
  //     onHabitTapped: (habit) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => HabitDetailScreen(
  //             habitId: habit.id,
  //             selectedDate:
  //                 context.read<HabitProvider>().selectedDate ?? DateTime.now(),
  //             onHabitUpdated: (updatedHabit) {
  //               // Önce provider'ı güncelle
  //               context.read<HabitProvider>().updateHabit(updatedHabit);
  //               // Sonra yerel referansı güncelle ki sağ panel yeni veriyi bassın
  //               setState(() {
  //                 _selectedHabitForDetail = updatedHabit;
  //               });
  //             },
  //             onHabitDeleted: (id) {
  //               context.read<HabitProvider>().deleteHabit(id);
  //               setState(() => _selectedHabitForDetail = null);
  //             },
  //           ),
  //         ),
  //       );
  //       context.read<HabitProvider>().setGroupToView(null);
  //     },
  //     onHabitUpdated: (updatedHabit) {
  //       // bu satır aslında gerekmiyor çünkü Navigator içinden çağırılıyor
  //       // ama tutarlılık için bırakabilirsin
  //     },
  //     onHabitDeleted: (String id) {
  //       // 1. Önce sil
  //       setState(() {
  //         habits.removeWhere((h) => h.id == id);
  //       });
  //
  //       // 2. Sonra tekrar ekle (eğer edit yapıyorsan)
  //       final habit = habits.firstWhere(
  //         (h) => h.id == id,
  //       ); // habit burada tanımlı!
  //
  //       context.read<HabitProvider>().addHabit(
  //         name: habit.name,
  //         description: habit.description,
  //         color: habit.color,
  //         type: habit.type,
  //         targetCount: habit.targetCount,
  //         targetSeconds: habit.targetSeconds,
  //         reminderTime: habit.reminderTime,
  //         reminderDays: habit.reminderDays,
  //         icon: habit.icon,
  //       );
  //     },
  //   );
  // }

  // AppBar Metodu (Senin mevcut AppBar kodun buraya gelecek)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
          ? Theme.of(context).appBarTheme.backgroundColor?.withValues(alpha: 1)
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
                padding: EdgeInsets.fromLTRB(8, 4, 4, 4),
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
                showMainSettingsSheet(context);
              },
              icon: Icon(Icons.settings),
            ),
          ),
        ),
      ],
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   var habits = context.watch<HabitProvider>().habits;
  //   return Scaffold(
  //     backgroundColor: context.watch<CurrentThemeMode>().isMica
  //         ? Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 1)
  //         : Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.3),
  //     floatingActionButton: glassContainer(
  //       shape: BoxShape.circle,
  //       context: context,
  //       child: FloatingActionButton(
  //         foregroundColor: context.watch<CurrentThemeMode>().isMica
  //             ? Theme.of(context).floatingActionButtonTheme.foregroundColor
  //             : Theme.of(context).floatingActionButtonTheme.foregroundColor
  //                   ?.withValues(alpha: 0.7),
  //         backgroundColor: context.watch<CurrentThemeMode>().isMica
  //             ? Theme.of(context).floatingActionButtonTheme.backgroundColor
  //             : Theme.of(context).floatingActionButtonTheme.backgroundColor
  //                   ?.withValues(alpha: 0.7),
  //         onPressed: () {},
  //         shape: StadiumBorder(),
  //         child: IconButton(
  //           onPressed: () => showAddHabitSheet(context),
  //           icon: Icon(Icons.add),
  //         ),
  //       ),
  //     ),
  //     floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  //
  //     appBar: AppBar(
  //       title: Center(
  //         child: glassContainer(
  //           context: context,
  //           child: Padding(
  //             padding: const EdgeInsets.only(
  //               top: 4.0,
  //               bottom: 4.0,
  //               left: 2.0,
  //               right: 11.0,
  //             ),
  //             child: Text(
  //               '  ${_selectedIndex == 0 ? _titleForSelectedDate(context) : "İstatistikler"}',
  //             ),
  //           ),
  //         ),
  //       ),
  //
  //       backgroundColor: context.watch<CurrentThemeMode>().isMica
  //           ? Theme.of(
  //               context,
  //             ).appBarTheme.backgroundColor?.withValues(alpha: 1)
  //           : Theme.of(
  //               context,
  //             ).appBarTheme.backgroundColor?.withValues(alpha: 0.2),
  //
  //       elevation: 10,
  //       leading: Builder(
  //         builder: (BuildContext context) {
  //           return Consumer<HabitProvider>(
  //             builder: (ctx, habitProvider, child) {
  //               final combinedColor = habitProvider.getCombinedMixedColor();
  //               return Padding(
  //                 padding: EdgeInsets.fromLTRB(8,4,4,4),
  //                 child: glassContainer(
  //                   shape: BoxShape.circle,
  //                   context: context,
  //                   child: IconButton(
  //                     style: IconButton.styleFrom(padding: EdgeInsets.all(4)),
  //                     icon: Icon(
  //                       Icons.format_list_bulleted,
  //                       color: combinedColor,
  //                     ),
  //                     onPressed: () {
  //                       showHabitsSummarySheet(context);
  //                     },
  //                   ),
  //                 ),
  //               );
  //             },
  //           );
  //         },
  //       ),
  //
  //       actions: [
  //         Padding(
  //           padding: const EdgeInsets.only(right: 8.0),
  //           child: glassContainer(
  //             shape: BoxShape.circle,
  //             context: context,
  //             child: IconButton(
  //               onPressed: () {
  //                 showMainSettingsSheet(
  //                   context,
  //                 );
  //               },
  //               icon: Icon(Icons.settings),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //     body: _selectedIndex == 0
  //         ? buildHabitsPage(
  //             onDateSelected: (date) {
  //               context.read<HabitProvider>().setSelectedDate(date);
  //             },
  //             habits: habits,
  //             onHabitTapped: (habit) {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => HabitDetailScreen(
  //                     habitId: habit.id,
  //                     selectedDate:
  //                         context.read<HabitProvider>().selectedDate ??
  //                         DateTime.now(),
  //                     onHabitUpdated: (updatedHabit) {
  //                       setState(() {
  //                         // habits listesi unmodifiable olduğu için yeni liste oluştur
  //                         final index = habits.indexWhere(
  //                           (h) => h.id == updatedHabit.id,
  //                         );
  //                         if (index != -1) {
  //                           habits = [
  //                             ...habits.sublist(0, index),
  //                             updatedHabit,
  //                             ...habits.sublist(index + 1),
  //                           ];
  //                         }
  //                       });
  //
  //                       // HabitProvider'ı güncelle - bu bildirimleri yeniden planlar
  //                       context.read<HabitProvider>().updateHabit(updatedHabit);
  //                     },
  //                     onHabitDeleted: (String id) {
  //                       setState(() {
  //                         habits = habits.where((h) => h.id != id).toList();
  //                       });
  //                       // HabitProvider'dan da sil (bildirimler iptal edilecek)
  //                       context.read<HabitProvider>().deleteHabit(id);
  //                     },
  //                   ),
  //                 ),
  //               );
  //               context.read<HabitProvider>().setGroupToView(null);
  //             },
  //             onHabitUpdated: (updatedHabit) {
  //               // bu satır aslında gerekmiyor çünkü Navigator içinden çağırılıyor
  //               // ama tutarlılık için bırakabilirsin
  //             },
  //             onHabitDeleted: (String id) {
  //               // 1. Önce sil
  //               setState(() {
  //                 habits.removeWhere((h) => h.id == id);
  //               });
  //
  //               // 2. Sonra tekrar ekle (eğer edit yapıyorsan)
  //               final habit = habits.firstWhere(
  //                 (h) => h.id == id,
  //               ); // habit burada tanımlı!
  //
  //               context.read<HabitProvider>().addHabit(
  //                 name: habit.name,
  //                 description: habit.description,
  //                 color: habit.color,
  //                 type: habit.type,
  //                 targetCount: habit.targetCount,
  //                 targetSeconds: habit.targetSeconds,
  //                 reminderTime: habit.reminderTime,
  //                 reminderDays: habit.reminderDays,
  //                 icon: habit.icon,
  //               );
  //             },
  //           ) // 1. sayfa: alışkanlıklar
  //         : StatisticsScreen(), // 2. sayfa: istatistikler
  //
  //     bottomNavigationBar: BottomAppBar(
  //       color: context.watch<CurrentThemeMode>().isMica
  //           ? Theme.of(context).bottomAppBarTheme.color?.withValues(alpha: 1)
  //           : Theme.of(context).bottomAppBarTheme.color?.withValues(alpha: 0.2),
  //       elevation: 10,
  //       shape: CircularNotchedRectangle(),
  //       clipBehavior: Clip.hardEdge,
  //       notchMargin: 15.0,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: [
  //           IconButton(
  //             style: IconButton.styleFrom(
  //               shape: StadiumBorder(),
  //               foregroundColor: _selectedIndex == 0
  //                   ? Theme.of(context).colorScheme.secondary
  //                   : Colors.grey,
  //             ),
  //             icon: Icon(Icons.checklist),
  //             onPressed: () => onItemTapped(0),
  //           ),
  //           IconButton(
  //             style: IconButton.styleFrom(
  //               shape: StadiumBorder(),
  //               foregroundColor: _selectedIndex == 1
  //                   ? Theme.of(context).colorScheme.secondary
  //                   : Colors.grey,
  //             ),
  //             icon: Icon(Icons.bar_chart),
  //             onPressed: () => onItemTapped(1),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

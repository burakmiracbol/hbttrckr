import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:hbttrckr/classes/glasscard.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'package:hbttrckr/views/habitdetailscreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
import 'package:hbttrckr/views/statsview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hbttrckr/providers/habitprovider.dart';
import 'package:wheel_slider/wheel_slider.dart';
import 'habits_page.dart';

// TODO's
//
//  todaya göre olan fonksiyonlar tarihe dönderilmeli ve detail screen tarihe göre açılmalı
//  strentgh gauge a içinde strength seviyesine göre bize laf söylesin
//  calendar yapılmalı ana sayfa için veya daha düzgün paket bulunmalı ama not edelim geçen güzel pakaet bulamadık
//  her alışkanlığın kendi içinde de takvimi var ama skipped yok
//  stats_view.dart ekranında da takvim lazım ve görsellik yükseltilmeli yapma sayısı oran felan
//  alışkanlıklara yeni özellikler eklemeli notlar kısmı ikonu felan ayrıca ikon seçme özelliği eklenmeli
//  alışkanlıklarda skip tuşu eklenmeli
//  haftanın hangi gününden başladığı eklenmeli
//  o güne göre habit çekme olmalı (şu an sadece yaşadığımız günü çekme var o yüzden calendarda geçmiş tarihe gidince bugün tamamlanma oranı var) ve habitlerin saklanma şekli çok şüpheci onlara bakılmalı
//  habit gruplama olmalı
//  kodu düzeltmeli hızımızı artırır eğer düzenler isek
//  alarm ve haftanın hangi günleri olduğunu ayarlama mevzusu halledilmeli
//  custom theme olsun ve şu an ki transparan butonu ve açık koyu tema butonu ayarlara doğru yol alsın
//  tema açısından geliştirmeler yapılmalı
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

bool isMica = true;

// TODO : kod düzenlemesi yapılması lazım. Birgün alıp bu tüm belirli widgetları sayfaları felan ayrı dosyalara ayıralım

typedef OnHabitUpdated = void Function(Habit updatedHabit);
typedef OnHabitTapped = void Function(Habit habit);
typedef OnHabitDeleted = void Function(String id);

class CurrentThemeMode with ChangeNotifier {
  bool isDarkMode = true;
  ThemeMode currentMode = ThemeMode.dark;
  void changeThemeMode() {
    isDarkMode = !isDarkMode;
    if (isDarkMode) {
      currentMode = ThemeMode.dark;
    } else {
      currentMode = ThemeMode.light;
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

  String title = "Today";

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
          bottom: MediaQuery.of(
            parentContext,
          ).viewInsets.bottom, // parentContext!
        ),
        child: AddHabitSheet(
          onAdd:
              ({
                required String name,
                String description = '',
                required Color color,
                required HabitType type,
                int? targetCount,
                int? maxCount,
                num? targetSeconds,
                TimeOfDay? reminderTime,
                Set<int>? reminderDays,
              }) {
                // DOĞRU CONTEXT → parentContext!
                parentContext.read<HabitProvider>().addHabit(
                  name: name,
                  description: description,
                  color: color,
                  type: type,
                  targetCount: targetCount,
                  maxCount: maxCount,
                  targetSeconds: targetSeconds?.toInt(),
                  reminderTime: reminderTime,
                  reminderDays: reminderDays,
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

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitProvider>().habits;
    return Scaffold(
      backgroundColor: isMica
          ? Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 1)
          : Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.3),
      floatingActionButton: FloatingActionButton(
        foregroundColor: isMica
            ? Theme.of(context).floatingActionButtonTheme.foregroundColor
            : Theme.of(context).floatingActionButtonTheme.foregroundColor
                  ?.withValues(alpha: 0.2),
        backgroundColor: isMica
            ? Theme.of(context).floatingActionButtonTheme.backgroundColor
            : Theme.of(context).floatingActionButtonTheme.backgroundColor
                  ?.withValues(alpha: 0.2),
        onPressed: () {},
        shape: StadiumBorder(),
        child: IconButton(
          onPressed: () => showAddHabitSheet(context),
          icon: Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        backgroundColor: isMica
            ? Theme.of(
                context,
              ).appBarTheme.backgroundColor?.withValues(alpha: 1)
            : Theme.of(
                context,
              ).appBarTheme.backgroundColor?.withValues(alpha: 0.2),

        elevation: 10,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(isMica ? Icons.blur_off : Icons.blur_on),
              onPressed: () async {
                if (isMica) {
                  await Window.setEffect(
                    effect: WindowEffect.disabled,
                  ); // önce tüm efekti sıfırla
                  await Future.delayed(const Duration(milliseconds: 100));
                  await Window.setEffect(effect: WindowEffect.transparent);

                  setState(() {
                    isMica = false;
                  });
                } else {
                  await Window.setEffect(
                    effect: WindowEffect.aero,
                    dark: false,
                  );

                  setState(() {
                    isMica = true;
                  });
                }
              },
            );
          },
        ),
        title: Center(child: Text(title)),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (sheetContext) =>
                    Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: Column(
                          children: [
                            Text(
                              "Tüm Alışkanlıklar",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            ...habits.map(
                                  (h) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Card(
                                  color: isMica
                                      ? Theme.of(context).cardColor
                                      : Theme.of(context).cardColor.withValues(alpha: 0.2),
                                  elevation: 3,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: h.color,
                                      child: Text(h.name[0].toUpperCase()),
                                    ),
                                    title: Text(h.name),
                                    subtitle: Text(
                                      "${h.currentStreak} gün streak • ${h.strength}% güç",
                                    ),
                                    trailing: h.currentStreak > 0
                                        ? Icon(
                                      Icons.local_fire_department,
                                    ) // TODO : lottie ekle
                                        : const Icon(
                                      Icons.local_fire_department_outlined,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),)
                    ),
              );
            },
            icon: Icon(Icons.panorama_fisheye),
          ),
          IconButton(
            icon: Icon(
              context.watch<CurrentThemeMode>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => context.read<CurrentThemeMode>().changeThemeMode(),
          ),
          IconButton.outlined(
            onPressed: () {
              showModalBottomSheet(
                enableDrag: true,
                useSafeArea: true,
                isScrollControlled: true,
                context: context,
                builder: (sheetContext) => Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 8,
                    right: 8,
                    bottom: 8,
                  ),
                  child: Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "Ayarlar",
                              style: TextStyle(
                                fontSize: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.fontSize,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Icon(Icons.account_circle_outlined),
                              ),
                              title: Text("Hesap Bilgileri"),
                              trailing: Icon(Icons.chevron_right),
                              onTap: () {
                                showModalBottomSheet(
                                  enableDrag: true,
                                  useSafeArea: true,
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (sheetContext) => Padding(
                                    padding: const EdgeInsets.only(
                                      top: 16,
                                      left: 8,
                                      right: 8,
                                      bottom: 8,
                                    ),
                                    child: Expanded(
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    icon: Icon(Icons.close),
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                  "Account",
                                                  style: TextStyle(
                                                    fontSize: Theme.of(context)
                                                        .textTheme
                                                        .headlineSmall
                                                        ?.fontSize,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Card(
                                              child: TextField(
                                                controller: accountController,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: 'Account name',
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.grey[900],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Card(
                                              child: TextField(
                                                controller: passwordController,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Password (that is secret don\'t share it)',
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.grey[900],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: TextButton(
                                              onPressed: () {},
                                              child: Text(
                                                "Forgot your password ?\n(okay that is normal but we are tired)",
                                              ),
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                        255,
                                                        140,
                                                        140,
                                                        73,
                                                      ),
                                                ),
                                                onPressed: () {},
                                                child: Expanded(
                                                  child: Text("Log in"),
                                                ),
                                              ),
                                            ),
                                          ),

                                          Stack(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 6.0,
                                                ),
                                                child: Center(child: Divider()),
                                              ),
                                              Center(
                                                child: Card(
                                                  child: Expanded(
                                                    child: Text("  or  "),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          Card(
                                            child: Expanded(
                                              child: TextButton(
                                                onPressed: () {},
                                                child: Text("Create Account"),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Icon(Icons.notifications_outlined),
                              ),
                              title: Text("Bildirimler"),
                              trailing: Icon(Icons.chevron_right),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(child: Icon(Icons.tune)),
                              title: Text("Tercihler"),
                              trailing: Icon(Icons.chevron_right),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Icon(Icons.message_outlined),
                              ),
                              title: Text("Destek Hattı"),
                              trailing: Icon(Icons.chevron_right),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Icon(Icons.star_outline),
                              ),
                              title: Text("Bizi Değerlendir"),
                              trailing: Icon(Icons.chevron_right),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Drawer Header',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Handle the tap
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Handle the tap
              },
            ),
          ],
        ),
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
                      onHabitUpdated: (updatedHabit) {
                        setState(() {
                          final index = habits.indexWhere(
                            (h) => h.id == updatedHabit.id,
                          );
                          if (index != -1) {
                            habits[index] = updatedHabit; // referansı değiştir!
                          }
                        });

                        context.read<HabitProvider>().addHabit(
                          name: habit.name,
                          description: habit.description,
                          color: habit.color,
                          type: habit.type,
                          targetCount: habit.targetCount,
                          targetSeconds: habit.targetSeconds,
                          reminderTime: habit.reminderTime,
                          reminderDays: habit.reminderDays,
                        ); // kalıcı kaydet
                      },
                      onHabitDeleted: (String id) {
                        setState(() {
                          habits.removeWhere((h) => h.id == id);
                        });
                        context.read<HabitProvider>().addHabit(
                          name: habit.name,
                          description: habit.description,
                          color: habit.color,
                          type: habit.type,
                          targetCount: habit.targetCount,
                          targetSeconds: habit.targetSeconds,
                          reminderTime: habit.reminderTime,
                          reminderDays: habit.reminderDays,
                        );
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
                );
              },
            ) // 1. sayfa: alışkanlıklar
          : StatisticsScreen(), // 2. sayfa: istatistikler
      bottomNavigationBar: BottomAppBar(
        color: isMica
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

class AddHabitSheet extends StatefulWidget {
  final Function({
    required String name,
    String description,
    required Color color,
    required HabitType type,
    int? targetCount,
    int? maxCount,
    num? targetSeconds,
    TimeOfDay? reminderTime,
    Set<int>? reminderDays,
  })
  onAdd;

  const AddHabitSheet({Key? key, required this.onAdd}) : super(key: key);

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _countController = TextEditingController();
  final _maxCountController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay.now();
  Set<int> _selectedDays = {1, 2, 3, 4, 5}; // Pazartesi-Cuma
  Color _selectedColor = Colors.blue;
  HabitType _selectedType = HabitType.task;

  // --- Taşınan state alanları (değişiklik burası) ---
  int _currentHours = 0;
  int _currentMinutes = 0;
  int _currentSeconds = 0;
  int _totalSeconds = 0;
  // ---------------------------------------------------

  final List<String> dayNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    num currentHours = 0;
    num currentMinutes = 0;
    num currentSeconds = 0;
    num totalSeconds = 0;
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kapat + Başlık
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'New Habit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 48),
              ],
            ),
            SizedBox(height: 20),

            // Habit Name
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Habit name',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[900],
              ),
            ),
            SizedBox(height: 16),

            // Description
            TextField(
              controller: _descController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[900],
              ),
            ),
            SizedBox(height: 24),

            // Habit Type
            Text(
              'Tür',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            DropdownButton<HabitType>(
              value: _selectedType,
              dropdownColor: Colors.grey[900],
              style: TextStyle(color: Colors.white),
              items: HabitType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            SizedBox(height: 16),

            // Target (Count / Time)
            if (_selectedType == HabitType.count)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextField(
                    controller: _countController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Hedef sayı (örn: 10)',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _maxCountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'maximum sayı',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[900],
                    ),
                  ),
                ],
              ),

            if (_selectedType == HabitType.time)
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SAAT
                    Expanded(
                      child: WheelSlider.number(
                        verticalListHeight:
                            MediaQuery.of(context).size.height * 0.3,
                        horizontal: false,
                        totalCount: 24,
                        initValue: _currentHours,
                        currentIndex: _currentHours,
                        onValueChanged: (val) {
                          setState(() {
                            _currentHours = val.toInt();
                            _totalSeconds =
                                (_currentHours * 3600) +
                                (_currentMinutes * 60) +
                                _currentSeconds;
                          });
                        },
                        selectedNumberStyle: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                        unSelectedNumberStyle: const TextStyle(
                          fontSize: 24,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    // DAKİKA
                    Expanded(
                      child: WheelSlider.number(
                        verticalListHeight:
                            MediaQuery.of(context).size.height * 0.3,
                        horizontal: false,
                        totalCount: 60,
                        initValue: _currentMinutes,
                        currentIndex: _currentMinutes,
                        onValueChanged: (val) {
                          setState(() {
                            _currentMinutes = val.toInt();
                            _totalSeconds =
                                (_currentHours * 3600) +
                                (_currentMinutes * 60) +
                                _currentSeconds;
                          });
                        },
                      ),
                    ),
                    // SANİYE
                    Expanded(
                      child: WheelSlider.number(
                        verticalListHeight:
                            MediaQuery.of(context).size.height * 0.3,
                        horizontal: false,
                        totalCount: 60,
                        initValue: _currentSeconds,
                        currentIndex: _currentSeconds,
                        onValueChanged: (val) {
                          setState(() {
                            _currentSeconds = val.toInt();
                            _totalSeconds =
                                (_currentHours * 3600) +
                                (_currentMinutes * 60) +
                                _currentSeconds;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 24),

            // Reminder
            Text(
              'Reminder',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time', style: TextStyle(color: Colors.white70)),
                TextButton(
                  onPressed: selectTime,
                  child: Text(
                    _selectedTime.format(context),
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Days
            Text(
              'Days',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: List.generate(7, (i) {
                return FilterChip(
                  label: Text(
                    dayNames[i],
                    style: TextStyle(color: Colors.white),
                  ),
                  selected: _selectedDays.contains(i),
                  onSelected: (selected) {
                    setState(() {
                      selected ? _selectedDays.add(i) : _selectedDays.remove(i);
                    });
                  },
                  selectedColor: Colors.blue[600],
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.grey[800],
                );
              }),
            ),
            SizedBox(height: 24),

            // Color Picker
            Text(
              'Renk seç',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Color tempColor = _selectedColor;
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.grey[900],
                        title: Text(
                          'Renk Seç',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: tempColor,
                            onColorChanged: (color) => tempColor = color,
                            showLabel: false,
                            pickerAreaHeightPercent: 0.8,
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              'İptal',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                          TextButton(
                            child: Text(
                              'Seç',
                              style: TextStyle(color: Colors.blue),
                            ),
                            onPressed: () {
                              setState(() => _selectedColor = tempColor);
                              Navigator.pop(ctx);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.rectangle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Icon(Icons.color_lens, color: Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Seçilen renk',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
            SizedBox(height: 24),

            // SAVE BUTONU
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blue[700],
                ),
                onPressed: () {
                  if (_nameController.text.trim().isEmpty) return;

                  widget.onAdd(
                    name: _nameController.text.trim(),
                    description: _descController.text,
                    color: _selectedColor,
                    type: _selectedType,
                    targetCount: _selectedType == HabitType.count
                        ? int.tryParse(_countController.text)
                        : null,
                    maxCount: _selectedType == HabitType.count
                        ? int.tryParse(_maxCountController.text)
                        : null,
                    // artık state içindeki toplam saniyeyi kullan
                    targetSeconds: _selectedType == HabitType.time
                        ? _totalSeconds
                        : null,
                    reminderTime: _selectedTime,
                    reminderDays: _selectedDays.isEmpty ? null : _selectedDays,
                  );
                },
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hbttrckr/classes/glasscard.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'package:hbttrckr/views/habitdetailscreen.dart';
import 'package:provider/provider.dart';
import 'package:hbttrckr/views/statsview.dart';
import 'package:hbttrckr/providers/habitprovider.dart';
import 'package:hbttrckr/providers/notification_settings_provider.dart';
import 'package:hbttrckr/services/notification_service.dart';
import 'package:wheel_slider/wheel_slider.dart';
import 'habits_page.dart';
import 'package:hbttrckr/providers/scheme_provider.dart';

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
//  Extend theme options beyond dark/light (color schemes)
//  Add notifications

// TODO's
//
//  reklam fikri sağol
//  ALARM: edit dialog çalışmıyor ve edit dialog artık dialog olarak değil de modal botom sheet olarak kullanmak daha iyi olur
//  habit paylaşma özelliği olsun
//  detail screende appbar şeffaf yapalım
//  detail scrrende appbarda actionsda iki tuş bulunsun biri notes biri ise diğerlerini görmek için sheet açan kısım
//  habitler için not kısmında hatalar düzeltilsin
//  countlarda ve timelarda strength tamalama oranına göre verilsin (mevcut hal ise tamamlama durumu) yani durum değil oran ile yapacağız
//  habitdetail screen hepsine bir glass glow ekle
//  windowsta uygulamanın o en yukardakı küçültme tam ekran yapma ve kapatma tuşunun olduğu bar transparan düğmesiyle etkileşime girildiğinde bozuluyor
//  strentgh gauge a içinde strength seviyesine göre bize laf söylesin
//  her alışkanlığın kendi içinde de takvimi var ama skipped yok
//  stats_view.dart ekranında da takvimi düzeltmek lazım (skipped olan günler gösterme felan) ve görsellik yükseltilmeli yapma sayısı oran felan
//  alışkanlıklara yeni özellikler eklemeli notlar kısmı ikonu felan ayrıca ikon seçme özelliği eklenmeli
//  haftanın hangi gününden başladığı eklenmeli
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
                int? targetCount,
                int? maxCount,
                num? targetSeconds,
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
                    icon: Icon(Icons.format_list_bulleted, color: combinedColor),
                    onPressed: () {
                      showModalBottomSheet(
                        enableDrag: true,
                        useSafeArea: true,
                        isScrollControlled: true,
                        context: context,
                        builder: (sheetContext) => DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.5, // başlangıçta ekranın %50'si
                      minChildSize: 0.25,
                      maxChildSize: 0.95,
                      builder: (context, scrollController) => Padding(
                        padding: EdgeInsets.all(8),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              Text(
                                "Tüm Alışkanlıklar",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Column(
                                children: [
                                  ...habits.map(
                                    (h) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Card(
                                        color:
                                            context
                                                .watch<CurrentThemeMode>()
                                                .isMica
                                            ? Theme.of(context).cardColor
                                            : Theme.of(context).cardColor
                                                  .withValues(alpha: 0.2),
                                        elevation: 3,
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: context.read<HabitProvider>().getMixedColor(h.id).withValues(alpha: 0.8),
                                            child: Text(
                                              h.name[0].toUpperCase(),
                                            ),
                                          ),
                                          title: Text(h.name),
                                          subtitle: Text(
                                            "${h.currentStreak} gün streak • ${h.strength}% güç",
                                          ),
                                          trailing: h.currentStreak > 0
                                              ? Icon(
                                                  Icons.local_fire_department,
                                                  color: context.read<HabitProvider>().getMixedColor(h.id),
                                                )
                                              : const Icon(
                                                  Icons
                                                      .local_fire_department_outlined,
                                                  color: Colors.grey,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                  )
              );
            },
          );
        },
        ),

        actions: [
          liquidGlassContainer(
            context: context,
            child: IconButton(
              onPressed: () async {
                await showModalBottomSheet(
                  enableDrag: true,
                  useSafeArea: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (sheetContext) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 8,
                        right: 8,
                        bottom: 8,
                      ),
                      child: SingleChildScrollView(
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
                                      builder: (sheetContext) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 16,
                                            left: 8,
                                            right: 8,
                                            bottom: 8,
                                          ),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Stack(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              4.0,
                                                            ),
                                                        child: IconButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              sheetContext,
                                                            );
                                                          },
                                                          icon: Icon(
                                                            Icons.close,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Text(
                                                        "Account",
                                                        style: TextStyle(
                                                          fontSize:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headlineSmall
                                                                  ?.fontSize,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
                                                  child: Card(
                                                    child: TextField(
                                                      controller:
                                                          accountController,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                      decoration: InputDecoration(
                                                        hintText:
                                                            'Account name',
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
                                                        fillColor:
                                                            Colors.grey[900],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
                                                  child: Card(
                                                    child: TextField(
                                                      controller:
                                                          passwordController,
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
                                                        fillColor:
                                                            Colors.grey[900],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {},
                                                    child: Text(
                                                      "Forgot your password ?\n(okay that is normal but we are tired)",
                                                    ),
                                                  ),
                                                ),

                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Color.fromARGB(
                                                                  255,
                                                                  140,
                                                                  140,
                                                                  73,
                                                                ),
                                                          ),
                                                      onPressed: () {},
                                                      child: Text("Log in"),
                                                    ),
                                                  ),
                                                ),

                                                Stack(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            top: 6.0,
                                                          ),
                                                      child: Center(
                                                        child: Divider(),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Card(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8.0,
                                                                vertical: 4.0,
                                                              ),
                                                          child: Text("  or  "),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                Card(
                                                  child: TextButton(
                                                    onPressed: () {},
                                                    child: Text(
                                                      "Create Account",
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
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
                                  onTap: () {
                                    showModalBottomSheet(
                                      enableDrag: true,
                                      useSafeArea: true,
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (sheetContext) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 16,
                                            left: 8,
                                            right: 8,
                                            bottom: 8,
                                          ),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Stack(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              4.0,
                                                            ),
                                                        child: IconButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              sheetContext,
                                                            );
                                                          },
                                                          icon: Icon(
                                                            Icons.close,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Text(
                                                        "Bildirim Ayarları",
                                                        style: TextStyle(
                                                          fontSize:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headlineSmall
                                                                  ?.fontSize,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 20),
                                                // Bildirimleri Aç/Kapat
                                                Consumer<NotificationSettings>(
                                                  builder: (ctx, notifSettings, child) {
                                                    return ListTile(
                                                      leading: Icon(
                                                        Icons
                                                            .notifications_active,
                                                      ),
                                                      title: Text(
                                                        "Bildirimleri Etkinleştir",
                                                      ),
                                                      trailing: Switch(
                                                        value: notifSettings
                                                            .notificationsEnabled,
                                                        onChanged: (value) async {
                                                          await notifSettings
                                                              .setNotificationsEnabled(
                                                                value,
                                                              );
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                                // Sesi Aç/Kapat
                                                Consumer<NotificationSettings>(
                                                  builder: (ctx, notifSettings, child) {
                                                    return ListTile(
                                                      leading: Icon(
                                                        Icons.volume_up,
                                                      ),
                                                      title: Text("Ses"),
                                                      trailing: Switch(
                                                        value: notifSettings
                                                            .soundEnabled,
                                                        onChanged: (value) async {
                                                          await notifSettings
                                                              .setSoundEnabled(
                                                                value,
                                                              );
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                                // Titreşimi Aç/Kapat
                                                Consumer<NotificationSettings>(
                                                  builder: (ctx, notifSettings, child) {
                                                    return ListTile(
                                                      leading: Icon(
                                                        Icons.vibration,
                                                      ),
                                                      title: Text("Titreşim"),
                                                      trailing: Switch(
                                                        value: notifSettings
                                                            .vibrationEnabled,
                                                        onChanged: (value) async {
                                                          await notifSettings
                                                              .setVibrationEnabled(
                                                                value,
                                                              );
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                                Divider(),
                                                // Varsayılan Hatırlatma Saati
                                                Consumer<NotificationSettings>(
                                                  builder: (ctx, notifSettings, child) {
                                                    return ListTile(
                                                      leading: Icon(
                                                        Icons.schedule,
                                                      ),
                                                      title: Text(
                                                        "Varsayılan Hatırlatma Saati",
                                                      ),
                                                      subtitle: Text(
                                                        notifSettings
                                                            .defaultReminderTime
                                                            .format(context),
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                        ),
                                                      ),
                                                      trailing: Icon(
                                                        Icons.edit,
                                                      ),
                                                      onTap: () async {
                                                        final TimeOfDay?
                                                        picked =
                                                            await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  notifSettings
                                                                      .defaultReminderTime,
                                                            );
                                                        if (picked != null) {
                                                          await notifSettings
                                                              .setDefaultReminderTime(
                                                                picked,
                                                              );
                                                        }
                                                      },
                                                    );
                                                  },
                                                ),
                                                SizedBox(height: 20),
                                                // Test Bildirim Butonu
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: ElevatedButton.icon(
                                                    onPressed: () async {
                                                      await NotificationService()
                                                          .showNotification(
                                                            id: 999,
                                                            title:
                                                                '🔔 Test Bildirim',
                                                            body:
                                                                'Bildirim sistemi çalışıyor!',
                                                          );
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Test bildirim gönderildi!',
                                                          ),
                                                          duration: Duration(
                                                            seconds: 2,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: Icon(Icons.send),
                                                    label: Text(
                                                      'Test Bildirim Gönder',
                                                    ),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.green,
                                                          foregroundColor:
                                                              Colors.white,
                                                        ),
                                                  ),
                                                ),
                                                // Planlı Bildirimleri Kontrol Et
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: ElevatedButton.icon(
                                                    onPressed: () async {
                                                      await NotificationService()
                                                          .debugPendingNotifications();
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Planlı bildirimler console\'da gösteriliyor',
                                                          ),
                                                          duration: Duration(
                                                            seconds: 2,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: Icon(Icons.list),
                                                    label: Text(
                                                      'Planlı Bildirimleri Kontrol Et',
                                                    ),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.blue,
                                                          foregroundColor:
                                                              Colors.white,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
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
                                    child: Icon(Icons.tune),
                                  ),
                                  title: Text("Tercihler"),
                                  trailing: Icon(Icons.chevron_right),
                                  onTap: () {
                                    showModalBottomSheet(
                                      enableDrag: true,
                                      useSafeArea: true,
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (sheetContext) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 16,
                                            left: 8,
                                            right: 8,
                                            bottom: 8,
                                          ),
                                          child: SingleChildScrollView(
                                            child: Stack(
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ListTile(
                                                      onTap: () => context
                                                          .read<
                                                            CurrentThemeMode
                                                          >()
                                                          .changeThemeMode(),
                                                      leading: IconButton(
                                                        icon: Icon(
                                                          context
                                                                  .watch<
                                                                    CurrentThemeMode
                                                                  >()
                                                                  .isDarkMode
                                                              ? Icons.light_mode
                                                              : Icons.dark_mode,
                                                        ),
                                                        onPressed: () => context
                                                            .read<
                                                              CurrentThemeMode
                                                            >()
                                                            .changeThemeMode(),
                                                      ),
                                                      title: Text(
                                                        "Tema Modunu Değiştirin",
                                                      ),
                                                      subtitle: Text(
                                                        "şu anki tema modu ${context.watch<CurrentThemeMode>().isDarkMode ? "karanlık" : "açık"}",
                                                      ),
                                                    ),
                                                    // Yeni: Tema etkenlerini değiştirme ListTile'ı
                                                    ListTile(
                                                      leading: CircleAvatar(
                                                        child: Icon(
                                                          Icons.palette,
                                                        ),
                                                      ),
                                                      title: Text(
                                                        "Tema Etkenlerini Değiştirin",
                                                      ),
                                                      subtitle: Text(
                                                        "${context.watch<SchemeProvider>().scheme.toString().split('.').last} • ${context.watch<SchemeProvider>().baseColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}",
                                                      ),
                                                      onTap: () {
                                                        final sp = context
                                                            .read<
                                                              SchemeProvider
                                                            >();
                                                        Color tempColor =
                                                            sp.baseColor;
                                                        SchemeType tempScheme =
                                                            sp.scheme;
                                                        showModalBottomSheet(
                                                          context: sheetContext,
                                                          isScrollControlled:
                                                              true,
                                                          builder: (ctx) {
                                                            return StatefulBuilder(
                                                              builder:
                                                                  (
                                                                    ctx2,
                                                                    setStateSheet,
                                                                  ) {
                                                                    return Padding(
                                                                      padding: EdgeInsets.only(
                                                                        bottom: MediaQuery.of(
                                                                          ctx,
                                                                        ).viewInsets.bottom,
                                                                      ),
                                                                      child: SingleChildScrollView(
                                                                        child: Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            ListTile(
                                                                              title: Text(
                                                                                'Scheme Tipi Seçin',
                                                                              ),
                                                                              subtitle:
                                                                                  DropdownButton<
                                                                                    SchemeType
                                                                                  >(
                                                                                    value: tempScheme,
                                                                                    items: SchemeType.values
                                                                                        .map(
                                                                                          (
                                                                                            e,
                                                                                          ) => DropdownMenuItem(
                                                                                            value: e,
                                                                                            child: Text(
                                                                                              e
                                                                                                  .toString()
                                                                                                  .split(
                                                                                                    '.',
                                                                                                  )
                                                                                                  .last,
                                                                                            ),
                                                                                          ),
                                                                                        )
                                                                                        .toList(),
                                                                                    onChanged:
                                                                                        (
                                                                                          v,
                                                                                        ) {
                                                                                          if (v !=
                                                                                              null)
                                                                                            setStateSheet(
                                                                                              () => tempScheme = v,
                                                                                            );
                                                                                        },
                                                                                  ),
                                                                            ),
                                                                            ListTile(
                                                                              title: Text(
                                                                                'Base Renk Seçin',
                                                                              ),
                                                                              subtitle: Row(
                                                                                children: [
                                                                                  CircleAvatar(
                                                                                    backgroundColor: tempColor,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 12,
                                                                                  ),
                                                                                  Expanded(
                                                                                    child: Text(
                                                                                      '#' +
                                                                                          tempColor.value
                                                                                              .toRadixString(
                                                                                                16,
                                                                                              )
                                                                                              .padLeft(
                                                                                                8,
                                                                                                '0',
                                                                                              )
                                                                                              .toUpperCase(),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(
                                                                                12.0,
                                                                              ),
                                                                              child: ColorPicker(
                                                                                pickerColor: tempColor,
                                                                                onColorChanged:
                                                                                    (
                                                                                      c,
                                                                                    ) => setStateSheet(
                                                                                      () => tempColor = c,
                                                                                    ),
                                                                                showLabel: true,
                                                                                pickerAreaHeightPercent: 0.6,
                                                                              ),
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                              children: [
                                                                                TextButton(
                                                                                  onPressed: () => Navigator.of(
                                                                                    ctx,
                                                                                  ).pop(),
                                                                                  child: Text(
                                                                                    'İptal',
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 8,
                                                                                ),
                                                                                ElevatedButton(
                                                                                  onPressed: () {
                                                                                    sp.setScheme(
                                                                                      tempScheme,
                                                                                    );
                                                                                    sp.setBaseColor(
                                                                                      tempColor,
                                                                                    );
                                                                                    Navigator.of(
                                                                                      ctx,
                                                                                    ).pop();
                                                                                  },
                                                                                  child: Text(
                                                                                    'Uygula',
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 12,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            SizedBox(
                                                                              height: 12,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading:
                                                          Consumer<
                                                            CurrentThemeMode
                                                          >(
                                                            builder:
                                                                (
                                                                  ctx,
                                                                  theme,
                                                                  child,
                                                                ) => Icon(
                                                                  theme.isMica
                                                                      ? Icons
                                                                            .blur_off
                                                                      : Icons
                                                                            .blur_on,
                                                                ),
                                                          ),
                                                      title: Text(
                                                        "Uygulamanın Şeffaflığını Değiştirin",
                                                      ),
                                                      subtitle: Text(
                                                        "şu anki görüntü modu ${context.watch<CurrentThemeMode>().isMica ? "normal" : "şeffaf"}",
                                                      ),
                                                      onTap: () async {
                                                        await context
                                                            .read<
                                                              CurrentThemeMode
                                                            >()
                                                            .toggleMica();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                            labelTypes: [],
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

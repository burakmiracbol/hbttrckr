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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/neat_and_clean_calendar_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'package:hbttrckr/classes/colormix.dart';
import 'package:hbttrckr/services/notification_service.dart';
import 'dart:convert';


enum TimeElements { minute, second, hour }

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  DateTime? selectedDate = DateTime.now();
  late ColorMixer _colorMixer;
  final Map<String, Color> _mixedColorCache = {}; // Mixed color cache (O(1) lookup)

  List<Habit> get habits => List.unmodifiable(_habits);
  Timer? _timer;
  Map<String, bool> runningTimers = {};

  HabitProvider() {
    _colorMixer = ColorMixer();
    _loadHabits();
    // Alışkanlıklar yüklendikten sonra bildirimleri planla
    Future.microtask(rescheduleAllNotifications);
  }

  // Tüm alışkanlıklar için renkleri mixer ile yeniden hesapla ve cache'le
  void _recalculateMixedColors() {
    _colorMixer.reset();
    _mixedColorCache.clear(); // Cache'i temizle
    for (final habit in _habits) {
      final mixed = _colorMixer.addColor(habit.color);
      _mixedColorCache[habit.id] = mixed; // Cache'e kaydet
    }
    notifyListeners();
  }

  // Bir alışkanlığın mixed color'ını cache'den al (O(1) lookup)
  Color getMixedColor(String habitId) {
    return _mixedColorCache[habitId] ?? _habits.firstWhere((h) => h.id == habitId).color;
  }

  // Tüm habitler için combined/average mixed color (icon için)
  Color getCombinedMixedColor() {
    if (_mixedColorCache.isEmpty) return Colors.grey;

    // Tüm mixed color'ları ortalama
    double r = 0, g = 0, b = 0;
    for (final color in _mixedColorCache.values) {
      r += (color.r * 255.0).round();
      g += (color.g * 255.0).round();
      b += (color.b * 255.0).round();
    }
    final count = _mixedColorCache.length;
    return Color.fromARGB(
      255,
      (r / count).toInt(),
      (g / count).toInt(),
      (b / count).toInt(),
    );
  }

  // Tüm alışkanlıkların bildirimlerini yeniden planla (uygulama başlangıcında ve ayarlar değiştirildiğinde)
  Future<void> rescheduleAllNotifications() async {
    // Alışkanlıkların yüklenmesini bekle
    await Future.delayed(const Duration(milliseconds: 300));

    debugPrint('🔄 Tüm bildirimleri yeniden planlıyor...');

    // Önce TÜM eski bildirimleri iptal et
    await NotificationService().cancelAllNotifications();
    debugPrint('🗑️ Tüm eski bildirimler iptal edildi');

    // Sonra yenileri planla
    int scheduledCount = 0;
    for (final habit in _habits) {
      if (habit.reminderTime != null) {
        await scheduleReminders(habit.id);
        scheduledCount++;
      }
    }
    debugPrint(
        '✅ Yeniden planlama tamamlandı (${_habits.length} alışkanlık, $scheduledCount hatırlatma aktif)');
  }

  void resetTimer(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    if (habit.type != HabitType.time) return;

    final targetDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );

    final newProgress = Map<DateTime, dynamic>.from(habit.dailyProgress);
    newProgress[targetDate] = 0; // bugünki süreyi sıfırla

    _habits[index] = habit.copyWith(dailyProgress: newProgress);
    notifyListeners();
    _saveHabits();
  }

  void incrementTime(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    if (habit.type != HabitType.time) return;

    final targetDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );

    final v = habit.dailyProgress[targetDate];
    final currentSeconds = (v is num) ? v.toInt() : 0;
    final newSeconds = currentSeconds + 1;

    final newProgress = Map<DateTime, dynamic>.from(habit.dailyProgress);
    newProgress[targetDate] = newSeconds;

    _habits[index] = habit.copyWith(dailyProgress: newProgress);
    notifyListeners();
    _saveHabits();
  }

  void toggleTimer(String habitId) {
    if (runningTimers[habitId] == true) {
      // DURDUR
      _timer?.cancel();
      runningTimers[habitId] = false;
    } else {
      // BAŞLAT
      runningTimers[habitId] = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        incrementTime(habitId); // saniye ekle
      });
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void incrementCount(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;
    final habit = _habits[index];
    if (habit.type != HabitType.count) return;

    final targetDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );
    final v = habit.dailyProgress[targetDate];
    final current = (v is num) ? v.toInt() : 0;
    final newValue = current + 1;

    final newProgress = Map<DateTime, dynamic>.from(habit.dailyProgress);
    newProgress[targetDate] = newValue;

    _habits[index] = habit.copyWith(dailyProgress: newProgress);
    notifyListeners();
    _saveHabits();
  }

  void decrementCount(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;
    final habit = _habits[index];
    if (habit.type != HabitType.count) return;

    final targetDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );
    final v = habit.dailyProgress[targetDate];
    final current = (v is num) ? v.toInt() : 0;
    final newValue = current - 1;

    final newProgress = Map<DateTime, dynamic>.from(habit.dailyProgress);
    newProgress[targetDate] = newValue;

    _habits[index] = habit.copyWith(dailyProgress: newProgress);
    notifyListeners();
    _saveHabits();
  }

  void setSecondsForThatDate(String habitId, int totalSeconds) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    if (habit.type != HabitType.time) return;

    final targetDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );

    final newProgress = Map<DateTime, dynamic>.from(habit.dailyProgress);
    newProgress[targetDate] = totalSeconds;

    _habits[index] = habit.copyWith(dailyProgress: newProgress);
    notifyListeners();
    _saveHabits();
  }

  void changeCount(String habitId, int value) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    if (habit.type != HabitType.count) return;

    final targetDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );

    final newProgress = Map<DateTime, dynamic>.from(habit.dailyProgress);
    newProgress[targetDate] = value;

    _habits[index] = habit.copyWith(dailyProgress: newProgress);
    notifyListeners();
    _saveHabits();
  }

  dynamic getTimeProgress(String habitId, {String format = 'seconds'}) {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    if (habit.type != HabitType.time) {
      return format == 'string' || format == 'hh:mm:ss' ? "0 dk" : 0;
    }

    // SEÇİLEN TARİH (bugün yerine)
    final targetDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );
    final v = habit.dailyProgress[targetDate];
    final totalSeconds = (v is num) ? v.toInt() : 0;

    switch (format) {
      case 'hours':
        return totalSeconds ~/ 3600;
      case 'minutes':
        return totalSeconds ~/ 60;
      case 'seconds':
        return totalSeconds;
      case 'string':
        final h = totalSeconds ~/ 3600;
        final m = (totalSeconds % 3600) ~/ 60;
        final s = totalSeconds % 60;
        if (h > 0) return "${h}s ${m}dk ${s}sn";
        if (m > 0) return "${m}dk ${s}sn";
        return "${s}sn";
      case 'hh:mm:ss':
        final h = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
        final m = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
        final s = (totalSeconds % 60).toString().padLeft(2, '0');
        return "$h:$m:$s";
      default:
        return totalSeconds;
    }
  }

  int getCompletedCountForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);

    return habits.where((habit) {
      // Task tipi → dailyProgress üzerinde true mu?
      if (habit.type == HabitType.task) {
        final val = habit.dailyProgress[normalized];
        if (val == true) return true;
        return false;
      }

      // Count tipi → bugünki progress >= targetCount mı?
      if (habit.type == HabitType.count) {
        final v = habit.dailyProgress[normalized];
        final achieved = (v is num) ? v.toInt() : 0;
        return achieved >= (habit.targetCount ?? 1);
      }

      // Time tipi → bugünki saniye >= targetSeconds mı?
      if (habit.type == HabitType.time) {
        final v = habit.dailyProgress[normalized];
        final achievedSeconds = (v is num) ? v.toInt() : 0;
        final targetSecs = habit.targetSeconds ?? 60;
        return achievedSeconds >= targetSecs;
      }

      return false;
    }).length;
  }

  void addHabit({
    required String name,
    String description = '',
    String? group,
    required Color color,
    required HabitType type,
    required IconData icon,
    double? targetCount,
    double? targetSeconds,
    TimeOfDay? reminderTime,
    Set<int>? reminderDays,
    double? maxCount,
  }) {
    // Icon parametresi artık doğru şekilde alınıyor
    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      color: color,
      createdAt: DateTime.now(),
      type: type,
      targetCount: targetCount,
      targetSeconds: targetSeconds,
      reminderTime: reminderTime,
      reminderDays: reminderDays,
      achievedCount: 0,
      icon: icon,
    );

    _habits.add(newHabit);

    // Yeni alışkanlık eklendikten sonra tüm renkleri ColorMixer ile yeniden hesapla
    _recalculateMixedColors();

    _saveHabits();

    // Listeners'ı bilgilendir
    notifyListeners();

    // Eğer reminder ayarlanmışsa planla
    if (reminderTime != null) {
      scheduleReminders(newHabit.id);
    }
  }

  List<Habit> getUniqueGroups(List<Habit> habits) {
    final Map<String, Habit> uniqueMap = {};
    for (var h in habits.where((h) => h.group != null)) {
      uniqueMap[h.group!] = h;
    }
    return uniqueMap.values.toList();
  }

  String? selectedGroup;

  void setGroupToView (String? v){
    selectedGroup = v;
    notifyListeners();
  }
  String? getGroupToView (){
    return selectedGroup;
  }

  void changeSkipHabit(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    final targetDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );

    if (habit.isSkippedOnDate(targetDate)) {
      // zaten skip'liyse geri al
      _habits[index] = habit.unSkipOnDate(targetDate);
    } else {
      _habits[index] = habit.skipOnDate(targetDate);
    }

    notifyListeners();
    _saveHabits();
  }

  List<NeatCleanCalendarEvent> get calendarEvents {
    List<NeatCleanCalendarEvent> events = [];
    for (var habit in habits) {
      // Derive events from dailyProgress (works for task/count/time)
      for (var entry in habit.dailyProgress.entries) {
        final date = entry.key;
        final val = entry.value;

        var shouldAdd = false;
        if (habit.type == HabitType.task) {
          shouldAdd = val == true;
        } else if (habit.type == HabitType.count) {
          final int achieved = (val is num) ? val.toInt() : 0;
          shouldAdd = achieved >= (habit.targetCount ?? 1);
        } else if (habit.type == HabitType.time) {
          final int achievedSeconds = (val is num) ? val.toInt() : 0;
          shouldAdd = achievedSeconds >= (habit.targetSeconds ?? 60);
        }

        if (shouldAdd) {
          events.add(
            NeatCleanCalendarEvent(
              habit.name,
              startTime: date,
              endTime: date,
              color: habit.color,
              isDone: true,
            ),
          );
        }
      }
    }
    return events;
  }

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  Habit getHabitById(String id) {
    return _habits.firstWhere((h) => h.id == id);
  }

  void addHabitFromObject(Habit habit) {
    _habits.add(habit);
    notifyListeners();
    _saveHabits();
  }

  void updateHabit(Habit updatedHabit) {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      _habits[index] = updatedHabit;

      // Her zaman mixed color'ları yeniden hesapla (renk değişti mi diye kontrol etmeye gerek yok)
      _recalculateMixedColors();

      _saveHabits();

      // Bildirimleri güncelle
      if (updatedHabit.reminderTime != null) {
        scheduleReminders(updatedHabit.id);
      } else {
        // Reminder kaldırılmışsa bildirimleri iptal et
        NotificationService()
            .cancelNotification(updatedHabit.id.hashCode);
      }
    }
    notifyListeners();
  }

  void clearAll() {
    _habits.clear();
    notifyListeners();
    _saveHabits();
  }

  void toggleTaskCompletion(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    if (habit.type != HabitType.task) return;

    // BUGÜN yerine SEÇİLEN TARİH
    final targetDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );

    final newProgress = Map<DateTime, dynamic>.from(habit.dailyProgress);

    final currentlyDone = (newProgress[targetDate] == true);

    if (currentlyDone) {
      // GERİ AL
      newProgress[targetDate] = false;
    } else {
      // TAMAMLA
      newProgress[targetDate] = true;
    }

    final newCompletedDates = newProgress.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();

    _habits[index] = habit.copyWith(dailyProgress: newProgress);
    notifyListeners();
    _saveHabits();
  }

  // Alışkanlık için bildirimleri planla
  Future<void> scheduleReminders(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];

    // Eğer reminder ayarlanmamışsa iptal et
    if (habit.reminderTime == null) {
      await NotificationService().cancelNotification(habitId.hashCode);
      debugPrint('🔔 Bildirim iptal edildi: ${habit.name}');
      return;
    }

    try {
      debugPrint('🔄 ${habit.name} için bildirim planlanıyor...');

      // Yeni bildirimleri planla (sadece belirtilen saatte her gün)
      // scheduleDailyNotification içinde zaten eski bildirimler iptal ediliyor
      await NotificationService().scheduleDailyNotification(
        id: habitId.hashCode,
        title: habit.name,
        body: 'Bugün için "${habit.name}" alışkanlığını tamamlamayı hatırla!',
        hour: habit.reminderTime!.hour,
        minute: habit.reminderTime!.minute,
        daysOfWeek: null,
        payload: habitId,
      );

      debugPrint(
          '✅ ${habit.name} planlandı - ${habit.reminderTime!.hour}:${habit.reminderTime!.minute.toString().padLeft(2, '0')}');
    } catch (e) {
      debugPrint('❌ Bildirim planlama hatası: $e');
    }
  }

  // Alışkanlığı sil
  Future<void> deleteHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    // Bildirimleri iptal et
    await NotificationService().cancelNotification(habitId.hashCode);

    _habits.removeAt(index);

    // Silindikten sonra mixed color'ları yeniden hesapla
    _recalculateMixedColors();

    _saveHabits();
  }

  Future<void> _loadHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('habits');
      if (data != null && data.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(data);
        _habits = jsonList
            .map((json) => Habit.fromJson(json as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('HabitProvider: Load error → $e');
    }
  }

  Future<void> _saveHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String data = jsonEncode(_habits.map((h) => h.toJson()).toList());
      await prefs.setString('habits', data);
    } catch (e) {
      debugPrint('HabitProvider: Save error → $e');
    }
  }

}

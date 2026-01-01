import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/neat_and_clean_calendar_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'dart:convert';
// TODO: today olan fonksiyonların that day veya that time halini yapalım çünkü her zaman bugüne bakmıyoruz
// TODO: isdonetoday buraya da ekle

enum TimeElements { minute, second, hour }

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  DateTime? selectedDate = DateTime.now();

  List<Habit> get habits => List.unmodifiable(_habits);
  Timer? _timer;
  Map<String, bool> runningTimers = {};

  HabitProvider() {
    _loadHabits();
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
        // backward compatibility: fallback to completedDates
        return habit.completedDates.any(
          (d) =>
              d.year == normalized.year &&
              d.month == normalized.month &&
              d.day == normalized.day,
        );
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
    required Color color,
    required HabitType type,
    num? targetCount,
    int? targetSeconds,
    TimeOfDay? reminderTime,
    Set<int>? reminderDays,
    int? maxCount,
  }) {
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
      completedDates: [],
      achievedCount: 0,
    );

    _habits.add(newHabit);
    notifyListeners();
    _saveHabits();
  }

  void deleteHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
    _saveHabits();
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
      notifyListeners();
      _saveHabits();
    }
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

    final currentlyDone = (newProgress[targetDate] == true) ||
        habit.completedDates.any((d) =>
        d.year == targetDate.year && d.month == targetDate.month && d.day == targetDate.day);

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

    _habits[index] = habit.copyWith(dailyProgress: newProgress, completedDates: newCompletedDates);
    notifyListeners();
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

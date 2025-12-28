import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/neat_and_clean_calendar_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'dart:convert';
// TODO: today olan fonksiyonların that day veya that time halini yapalım çünkü her zaman bugüne bakmıyoruz
// TODO: isdonetoday buraya da ekle

enum TimeElements {
  minute,
  second,
  hour,
}

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

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final newProgress = Map<DateTime, int>.from(habit.dailyProgress ?? {});
    newProgress[today] = 0; // bugünki süreyi sıfırla

    _habits[index] = habit.copyWith(dailyProgress: newProgress);
    notifyListeners();
    _saveHabits();
  }

  void incrementTime(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    if (habit.type != HabitType.time) return;

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final currentSeconds = (habit.dailyProgress?[today] as int?) ?? 0;
    final newSeconds = currentSeconds + 1; // her çağrıda +1 saniye

    final newProgress = Map<DateTime, int>.from(habit.dailyProgress ?? {});
    newProgress[today] = newSeconds;

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


  void changeCount(String habitId, int value ) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;
    final habit = _habits[index];
    if (habit.type != HabitType.count) return;

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final newValue = value;

    final newProgress = Map<DateTime, dynamic>.from(habit.dailyProgress ?? {});
    newProgress[today] = newValue;

    _habits[index] = habit.copyWith(dailyProgress: newProgress);
    notifyListeners();
    _saveHabits();
  }

  void incrementCount(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;
    final habit = _habits[index];
    if (habit.type != HabitType.count) return;

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final current = habit.dailyProgress?[today] as int? ?? 0;
    final newValue = current + 1;

    final newProgress = Map<DateTime, dynamic>.from(habit.dailyProgress ?? {});
    newProgress[today] = newValue;

    _habits[index] = habit.copyWith(dailyProgress: newProgress);
    notifyListeners();
    _saveHabits();
  }

  void decrementCount(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;
    final habit = _habits[index];
    if (habit.type != HabitType.count) return;

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final current = habit.dailyProgress?[today] as int? ?? 0;
    final newValue = current -1 ;

    final newProgress = Map<DateTime, dynamic>.from(habit.dailyProgress ?? {});
    newProgress[today] = newValue;

    _habits[index] = habit.copyWith(dailyProgress: newProgress);
    notifyListeners();
    _saveHabits();
  }

  void setTodaySeconds(String habitId, int totalSeconds) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    if (habit.type != HabitType.time) return;

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final newProgress = Map<DateTime, int>.from(habit.dailyProgress ?? {});
    newProgress[today] = totalSeconds; // direkt toplamı yaz

    _habits[index] = habit.copyWith(dailyProgress: newProgress);
    notifyListeners();
    _saveHabits();
  }

  dynamic getTimeProgress(String habitId, {String format = 'seconds'}) {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    if (habit == null || habit.type != HabitType.time) {
      return format == 'string' || format == 'hh:mm:ss' ? "0 dk" : 0;
    }

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final totalSeconds = (habit.dailyProgress?[today] as int?) ?? 0;

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

  void toggleTaskCompletion(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];

    // Sadece task tipi için çalışsın
    if (habit.type != HabitType.task) return;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    List<DateTime> newCompletedDates;

    if (habit.isCompletedToday()) {
      // BUGÜN TAMAMLANDIYSA → GERİ AL (Undo)
      newCompletedDates = habit.completedDates
          .where((date) => !date.isAtSameMomentAs(todayDate))
          .toList();
    } else {
      // TAMAMLANMAMIŞSA → TAMAMLA (Do)
      newCompletedDates = [...habit.completedDates, todayDate];
    }

    _habits[index] = habit.copyWith(completedDates: newCompletedDates);

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

  int getCompletedCountForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return habits.where((h) => h.completedDates.any((d) =>
    d.year == normalized.year && d.month == normalized.month && d.day == normalized.day)).length;
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
      skippedDates: [],
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

  void markAsCompleted(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].markAsCompleted();
      notifyListeners();
      _saveHabits();
    }
  }

  void skipToday(String id) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].skipToday();
      notifyListeners();
      _saveHabits();
    }
  }

  List<NeatCleanCalendarEvent> get calendarEvents {
    List<NeatCleanCalendarEvent> events = [];
    for (var habit in habits) {
      for (var date in habit.completedDates) {
        events.add(NeatCleanCalendarEvent(
          habit.name,
          startTime: date,
          endTime: date,
          color: habit.color,
          isDone: true,
        ));
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
}
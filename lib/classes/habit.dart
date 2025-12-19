import 'package:flutter/material.dart';
import 'dart:ui';

// TODO : aynı zamanda da count hebitinin time verisine ulaşmak yasak olsun
// TODO : streak hesaplama düzeltilecek
// TODO: icon eklenecek
// TODO: buradan bağımsız icon eklenecek diye icon paketi lazım ve düzenleme ekranında icon seçme olacak
// TODO: hatırlatma süreleri ve günleri tes edilecek ve yapılacak
// TODO: addhabitsheette max count için de yer olacak


enum HabitType {
  task,   // Sadece yapmalı
  count,  // Sayılı (5 push-up)
  time,   // Süreli (30 dk meditasyon)
}

class Habit {
  final String id;
  final String name;
  final String description;
  final Color color;
  final DateTime createdAt;
  final TimeOfDay? reminderTime;
  final Set<int>? reminderDays;
  final HabitType type;
  final num achievedCount;
  final num? targetCount;
  final int? maxCount;
  final int? achievedSeconds;
  final int? targetSeconds;
  final int? maxSeconds;
  final List<DateTime> completedDates;
  final List<DateTime> skippedDates;
  final Map<DateTime, dynamic> dailyProgress;

  Habit({
    required this.id,
    required this.name,
    this.description = '',
    required this.color,
    required this.createdAt,
    this.reminderTime,
    this.reminderDays,
    required this.type,
    required this.achievedCount,
    this.maxCount,
    this.targetCount,
    this.achievedSeconds,
    this.targetSeconds,
    List<DateTime>? completedDates,
    List<DateTime>? skippedDates,
    Map<DateTime, dynamic>? dailyProgress,
    this.maxSeconds,
  }) :  dailyProgress = dailyProgress ?? {},
        completedDates = completedDates ?? [],
        skippedDates = skippedDates ?? [];

  // === STRENGTH HESAPLAMASI (getter) ===
  /// Alışkanlığın genel gücü (0.0 - 100.0)
  /// Formül:
  ///   - %50 → son 30 gün tamamlanma oranı
  ///   - %30 → mevcut streak (max 30 gün üzerinden)
  ///   - %20 → toplam tamamlanan gün sayısı (max 200 gün üzerinden)
  // TODO: işte bunun biraz ayarlarıyla oynayalım
  int get strength {
    // 1. Son 30 gün tamamlanma oranı (%50 ağırlık)
    final last30 = last30DaysStatus;
    final completionRate30 = last30.where((done) => done).length / 30;
    double score = completionRate30 * 50;

    // 2. Mevcut streak (%30 ağırlık, max 30 gün)
    final streakScore = (currentStreak / 30).clamp(0, 1) * 30;
    score += streakScore;

    // 3. Toplam tamamlanan gün sayısı (%20 ağırlık, max 200 gün)
    int totalCompletedDays = 0;

    if (type == HabitType.task) {
      totalCompletedDays = completedDates.length;
    } else if (type == HabitType.count) {
      totalCompletedDays = dailyProgress?.keys.where((date) {
        final value = dailyProgress![date];
        final int achieved = (value is num) ? value.toInt() : 0;
        return achieved >= (targetCount ?? 1);
      }).length ?? 0;
    } else if (type == HabitType.time) {
      totalCompletedDays = dailyProgress?.keys.where((date) {
        final value = dailyProgress![date];
        final int achievedSeconds = (value is num) ? value.toInt() : 0;
        final int targetSecs = targetSeconds ?? 60;
        return achievedSeconds >= targetSecs;
      }).length ?? 0;
    }

    final longevityScore = (totalCompletedDays / 200.0).clamp(0.0, 1.0) * 20.0;
    score += longevityScore;

    return score.round();
  }

  String get strengthLevel {
    if (strength >= 95) return "Efsane";
    if (strength >= 85) return "Usta";
    if (strength >= 70) return "Güçlü";
    if (strength >= 50) return "Orta";
    if (strength >= 5) return "Zayıf";
    return "Yeni Başladı";
  }

  List<bool> get last7DaysStatus => last30DaysStatus.sublist(23); // son 7 gün


  int get currentStreak {
    int streak = 0;
    // last30DaysStatus zaten bugünden geriye doğru (bugün en sonda)
    // reversed yapmadan doğrudan sondan başa doğru bakıyoruz
    for (int i = last30DaysStatus.length - 1; i >= 0; i--) {
      if (last30DaysStatus[i]) {
        streak++;
      } else {
        break; // ilk yapılmayan günde dur
      }
    }
    return streak;
  }


  List<bool> get last30DaysStatus {
    final List<bool> status = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < 30; i++) {
      final day = today.subtract(Duration(days: i));
      bool doneThatDay = false;

      if (type == HabitType.task) {
        doneThatDay = completedDates.any((d) =>
        d.year == day.year && d.month == day.month && d.day == day.day);
      } else if (type == HabitType.count) {
        final value = dailyProgress?[day];
        final int achieved = (value is num) ? value.toInt() : 0;
        doneThatDay = achieved >= (targetCount ?? 1);
      } else if (type == HabitType.time) {
        final value = dailyProgress?[day];
        final int achievedSeconds = (value is num) ? value.toInt() : 0;
        final int targetSecs = targetSeconds ?? 60; // default 1 dakika
        doneThatDay = achievedSeconds >= targetSecs;
      }

      status.add(doneThatDay);
    }

    // status[0] = 30 gün önce, status[29] = bugün
    // bugün en sonda olsun diye reversed yapıyoruz
    return status.reversed.toList();
  }

  int get todayCountProgress {
    final todayKey = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return (dailyProgress?[todayKey] as int?) ?? 0;
  }

  num get todayMinutesProgress {
    final todayKey = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return (dailyProgress?[todayKey] as int?) ?? 0.0;
  }

  bool get isDoneToday {
    if (type == HabitType.task) {
      return isCompletedToday();
    }

    if (type == HabitType.count) {
      final todayCount = todayCountProgress;        // senin getter’ın
      final target = targetCount ?? 1;
      return todayCount >= target;                  // 5/5 → true, 8/5 → da true!
    }

    if (type == HabitType.time) {
      final todayMinutes = todayMinutesProgress;     // senin getter’ın
      final target = (targetSeconds ?? 1).toDouble();
      return todayMinutes >= target;                // 35 dk / 30 dk → true
    }

    return false;
  }

  int get todaySecondsProgress {
    if (type != HabitType.time) return 0;

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return (dailyProgress?[today] as int?) ?? 0;
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // === DİĞER GETTER'LAR ===
  int get totalDays => completedDates.length;

  bool isCompletedToday() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return completedDates.any((d) => _sameDay(d, todayDate));
  }

  bool isSkippedToday() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return skippedDates.any((d) => _sameDay(d, todayDate));
  }

  // === METODLAR ===
  Habit markAsCompleted() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (isCompletedToday()) return this;

    return copyWith(
      completedDates: [...completedDates, todayDate],
    );
  }

  Habit skipToday() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (isSkippedToday()) return this;

    return copyWith(
      skippedDates: [...skippedDates, todayDate],
    );
  }

  // === COPYWITH (TÜM ALANLAR) ===
  Habit copyWith({
    String? id,
    String? name,
    String? description,
    Color? color,
    DateTime? createdAt,
    TimeOfDay? reminderTime,
    Set<int>? reminderDays,
    HabitType? type,
    num? achievedCount,
    num? targetCount,
    int? maxCount,
    int? achievedMinutes,
    int? targetMinutes,
    int? maxMinutes,
    List<DateTime>? completedDates,
    List<DateTime>? skippedDates,
    Map<DateTime, dynamic>? dailyProgress,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
      type: type ?? this.type,
      achievedCount: achievedCount ?? this.achievedCount,
      targetCount: targetCount ?? this.targetCount,
      maxCount: maxCount ?? this.maxCount,
      achievedSeconds: achievedMinutes ?? this.achievedSeconds,
      targetSeconds: targetMinutes ?? this.targetSeconds,
      maxSeconds: maxMinutes ?? this.maxSeconds,
      completedDates: completedDates ?? this.completedDates,
      skippedDates: skippedDates ?? this.skippedDates,
      dailyProgress: dailyProgress ?? this.dailyProgress,
    );
  }

  // === JSON ===
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'color': color.value,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'reminderTime': reminderTime != null
        ? '${reminderTime!.hour}:${reminderTime!.minute}'
        : null,
    'reminderDays': reminderDays?.toList(),
    'type': type.index,
    'achievedCount' : achievedCount,
    'targetCount': targetCount,
    'maxCount': maxCount,
    'achievedSeconds': achievedSeconds,
    'targetSeconds': targetSeconds,
    'maxSeconds' : maxSeconds,
    'completedDates': completedDates
        .map((date) => date.millisecondsSinceEpoch)
        .toList(),
    'skippedDates': skippedDates
        .map((date) => date.millisecondsSinceEpoch)
        .toList(),
    'dailyProgress': dailyProgress.map((key, value) => MapEntry(
        key.millisecondsSinceEpoch.toString(),
        value,)),
  };

  factory Habit.fromJson(Map<String, dynamic> json) {
    final reminderTimeStr = json['reminderTime'] as String?;
    TimeOfDay? time;
    if (reminderTimeStr != null) {
      final parts = reminderTimeStr.split(':');
      time = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return Habit(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? 'İsimsiz',
      description: json['description'] ?? '',
      color: Color(json['color'] ?? Colors.blue.value),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      reminderTime: time,
      reminderDays: (json['reminderDays'] as List?)?.cast<int>().toSet(),
      type: HabitType.values[json['type'] ?? 0],
      achievedCount: json['achievedCount'],
      targetCount: json['targetCount'],
      maxCount: json['maxCount'],
      achievedSeconds: json['achievedSeconds'],
      targetSeconds: json['targetSeconds'],
      maxSeconds: json['maxSeconds'],
      completedDates: (json['completedDates'] as List?)
          ?.map((ms) => DateTime.fromMillisecondsSinceEpoch(ms as int))
          .toList() ??
          [],
      skippedDates: (json['skippedDates'] as List?)
          ?.map((ms) => DateTime.fromMillisecondsSinceEpoch(ms as int))
          .toList() ??
          [],
      dailyProgress: (json['dailyProgress'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
          DateTime.fromMillisecondsSinceEpoch(int.parse(k)),
          v,
        ),
      ) ?? {},
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Habit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}


extension DurationFormatter on int? {
  // 1. Saat döndürür (örneğin 7200 → 2)
  int get hours {
    if (this == null) return 0;
    return this! ~/ 3600;
  }

  // 2. Dakika döndürür (örneğin 7385 → 3) → kalan dakikalar
  int get minutes {
    if (this == null) return 0;
    return (this! % 3600) ~/ 60;
  }

  // 3. Saniye döndürür (örneğin 7385 → 5) → kalan saniyeler
  int get seconds {
    if (this == null) return 0;
    return this! % 60;
  }

  // BONUS: 7385 → "2s 3dk 5sn" şeklinde güzel string (isteğe bağlı)
  String get formattedHMS {
    if (this == null || this == 0) return "0 dk";
    final h = hours;
    final m = minutes;
    final s = seconds;

    if (h > 0) return "${h}s ${m}dk ${s}sn";
    if (m > 0) return "${m}dk ${s}sn";
    return "${s}sn";
  }

  // BONUS 2: Sadece "02:03:05" formatı (progress bar vs. için ideal)
  String get formattedHHmmSS {
    if (this == null || this == 0) return "00:00:00";
    final h = hours.toString().padLeft(2, '0');
    final m = minutes.toString().padLeft(2, '0');
    final s = seconds.toString().padLeft(2, '0');
    return "$h:$m:$s";
  }
}
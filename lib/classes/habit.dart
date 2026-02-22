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

import 'dart:convert';
import 'package:flutter/material.dart';

enum HabitType {
  task, // Sadece yapmalı
  count, // Sayılı (5 push-up)
  time, // Süreli (30 dk meditasyon)
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
  final String? group;
  final IconData icon;
  final double? targetCount;
  final double? targetSeconds;
  final Map<DateTime, dynamic> dailyProgress;
  final String? notesDelta;

  Habit({
    required this.id,
    required this.name,
    this.description = '',
    required this.color,
    required this.createdAt,
    this.reminderTime,
    this.reminderDays,
    required this.type,
    this.group,
    required this.icon,
    this.targetCount,
    this.targetSeconds,
    Map<DateTime, dynamic>? dailyProgress,
    this.notesDelta,
  }) : dailyProgress = dailyProgress ?? {};

  @Deprecated("tarihe göre alıma geçilmesi önerilir eğer bugünün değerini görmek istiyorsanız basitçe tarih olarak bugünü yollayın")
  int get todayCountProgress => getCountProgressForDate(DateTime.now());

  @Deprecated("tarihe göre alıma geçilmesi önerilir eğer bugünün değerini görmek istiyorsanız basitçe tarih olarak bugünü yollayın")
  int get todaySecondsProgress => getSecondsProgressForDate(DateTime.now());

  @Deprecated("tarihe göre alıma geçilmesi önerilir eğer bugünün değerini görmek istiyorsanız basitçe tarih olarak bugünü yollayın")
  bool get isDoneToday => isCompletedOnDate(DateTime.now());

  @Deprecated("tarihe göre alıma geçilmesi önerilir eğer bugünün değerini görmek istiyorsanız basitçe tarih olarak bugünü yollayın")
  bool isCompletedToday() => isCompletedOnDate(DateTime.now());

  // Seçilen tarihe göre count progress (bugün yerine)
  int getCountProgressForDate(DateTime date) {
    if (type != HabitType.count) return 0;
    final normalized = DateTime(date.year, date.month, date.day);
    final v = dailyProgress[normalized];
    if (v is num) return v.toInt();
    return 0;
  }

  // Seçilen tarihe göre time progress (saniye)
  int getSecondsProgressForDate(DateTime date) {
    if (type != HabitType.time) return 0;
    final normalized = DateTime(date.year, date.month, date.day);
    final v = dailyProgress[normalized];
    if (v is num) return v.toInt();
    return 0;
  }

  // Seçilen tarihte tamamlandı mı?
  bool isCompletedOnDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);

    if (type == HabitType.task) {
      // Öncelikle dailyProgress üzerinden kontrol et (true ise yapıldı)
      final val = dailyProgress[normalized];
      if (val == true) return true;
      return false;
    }

    if (type == HabitType.count) {
      final achieved = getCountProgressForDate(date);
      return achieved >= (targetCount ?? 1);
    }

    if (type == HabitType.time) {
      final achievedSecs = getSecondsProgressForDate(date);
      final targetSecs = targetSeconds ?? 60;
      return achievedSecs >= targetSecs;
    }

    return false;
  }

  // === STRENGTH HESAPLAMASI (getter) ===
  /// Alışkanlığın genel gücü (0.0 - 100.0)
  /// Formül:
  ///   - %50 → son 30 gün tamamlanma oranı
  ///   - %30 → mevcut streak (max 30 gün üzerinden)
  ///   - %20 → toplam tamamlanan gün sayısı (max 200 gün üzerinden)
  // TODO: işte bunun biraz ayarlarıyla oynayalım
  double get strength {
    // 1. Son 30 gün tamamlanma oranı (%50 ağırlık)
    final last30 = last30DaysStatus;
    double completionRate30 = last30.fold(0.0, (previousValue, element) => previousValue + element,) / 30;
    double score = completionRate30 * 50;

    // 2. Mevcut streak (%30 ağırlık, max 30 gün)
    final streakScore = (currentStreak / 30).clamp(0, 1) * 30;
    score += streakScore;

    // 3. Toplam tamamlanan gün sayısı (%20 ağırlık, max 200 gün)
    double totalCompletedDays = 0.0;

    if (type == HabitType.task) {
      totalCompletedDays = dailyProgress.keys.where((date) {
        final value = dailyProgress[date];
        return value == true;
      }).length.toDouble();
    } else if (type == HabitType.count) {
      totalCompletedDays = dailyProgress.values.map((v) {
        final achieved = (v is num) ? v.toDouble() : 0.0;
        final t = targetCount ?? 1.0;
        return (achieved >= t) ? 1.0 : (achieved / t);
      }).fold(0.0, (previousValue, element) => previousValue + element);
    } else if (type == HabitType.time) {
      totalCompletedDays = dailyProgress.values.map((v) {
        final achievedSecs = (v is num) ? v.toDouble() : 0.0;
        final targetSecs = targetSeconds ?? 60.0;
        return (achievedSecs >= targetSecs) ? 1.0 : (achievedSecs / targetSecs);
      }).fold(0.0, (previousValue, element) => previousValue + element);
    }

    final longevityScore = (totalCompletedDays / 200.0).clamp(0.0, 1.0) * 20.0;
    score += longevityScore;

    return score.roundToDouble();
  }

  String get strengthLevel {
    if (strength >= 95) return "Efsane";
    if (strength >= 75) return "Usta";
    if (strength >= 50) return "Güçlü";
    if (strength >= 30) return "Orta";
    if (strength >= 5) return "Zayıf";
    return "Yeni Başladı";
  }

  List<double> get last7DaysStatus => last30DaysStatus.sublist(23); // son 7 gün

  int get currentStreak {
    int streak = 0;
    // last30DaysStatus zaten bugünden geriye doğru (bugün en sonda)
    // reversed yapmadan doğrudan sondan başa doğru bakıyoruz
    for (int i = last30DaysStatus.length - 1; i >= 0; i--) {
      if (last30DaysStatus[i] == 1) {
        streak++;
      } else {
        break; // ilk yapılmayan günde dur
      }
    }
    return streak;
  }

  List<double> get last30DaysStatus {
    final List<double> status = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < 30; i++) {
      final day = today.subtract(Duration(days: i));
      double doneRateOfThatDay = 0.0;

      if (type == HabitType.task) {
        final val = dailyProgress[day];
        doneRateOfThatDay = val == true ? 1 : 0 ;
      } else if (type == HabitType.count) {
        final value = dailyProgress[day];
        final double achieved = (value is num) ? value.toDouble() : 0;
        doneRateOfThatDay = achieved >= (targetCount ?? 1) ? 1 : achieved / (targetCount ?? 1) ;
      } else if (type == HabitType.time) {
        final value = dailyProgress[day];
        final double achievedSecs = (value is num) ? value.toDouble() : 0;
        final double targetSecs = targetSeconds ?? 60; // default 1 dakika
        doneRateOfThatDay = achievedSecs >= targetSecs ? 1 : achievedSecs / targetSecs ;
      }

      status.add(doneRateOfThatDay);
    }

    // status[0] = 30 gün önce, status[29] = bugün
    // bugün en sonda olsun diye reversed yapıyoruz
    return status.reversed.toList();
  }

  // === DİĞER GETTER'LAR ===

  // Gün skip edildi mi?
  bool isSkippedOnDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final value = dailyProgress[normalized];
    return value == "skipped";
  }

  // Gün skip et
  Habit skipOnDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final newProgress = Map<DateTime, dynamic>.from(dailyProgress);
    newProgress[normalized] = "skipped"; // skip işaretle

    return copyWith(dailyProgress: newProgress);
  }

  // Skip’i geri al (normal hale getir, progress 0 olsun)
  Habit unSkipOnDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    if (!isSkippedOnDate(date)) return this;

    final newProgress = Map<DateTime, dynamic>.from(dailyProgress);

    if (type == HabitType.task) {
      newProgress[normalized] = false;

      return copyWith(dailyProgress: newProgress);
    } else {
      // For count/time habits, set progress to 0
      newProgress[normalized] = 0;
      return copyWith(dailyProgress: newProgress);
    }
  }

  Habit copyWith({
    String? id,
    String? name,
    String? description,
    Color? color,
    DateTime? createdAt,
    TimeOfDay? reminderTime,
    Set<int>? reminderDays,
    HabitType? type,
    String? group,
    IconData? icon,
    double? targetCount,
    double? targetSeconds,
    Map<DateTime, dynamic>? dailyProgress,
    String? notesDelta,
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
      group: group,
      icon: icon ?? this.icon,
      targetCount: targetCount ?? this.targetCount,
      targetSeconds: targetSeconds ?? this.targetSeconds,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      notesDelta: notesDelta ?? this.notesDelta,
    );
  }

  // === JSON ===
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'color': color.toARGB32(),
    'createdAt': createdAt.millisecondsSinceEpoch,
    'reminderTime': reminderTime != null
        ? '${reminderTime!.hour}:${reminderTime!.minute}'
        : null,
    'reminderDays': reminderDays?.toList(),
    'type': type.index,
    'group': group,
    'icon': icon.codePoint,
    'targetCount': targetCount,
    'targetSeconds': targetSeconds,
    'completedDates': dailyProgress.entries
        .where((e) => e.value == true)
        .map((e) => e.key.millisecondsSinceEpoch)
        .toList(),
    'dailyProgress': dailyProgress.map(
      (key, value) => MapEntry(key.millisecondsSinceEpoch.toString(), value),
    ),
    'notesDelta': notesDelta,
  };

  factory Habit.fromJson(Map<String, dynamic> json) {
    final reminderTimeStr = json['reminderTime'] as String?;
    TimeOfDay? time;
    if (reminderTimeStr != null) {
      final parts = reminderTimeStr.split(':');
      time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final parsedDaily = (json['dailyProgress'] as Map<String, dynamic>?)?.map(
      (k, v) => MapEntry(DateTime.fromMillisecondsSinceEpoch(int.parse(k)), v),
    ) ?? {};

    String? parsedNotes;
    final rawNotes = json['notesDelta'];
    if (rawNotes is String) {
      parsedNotes = rawNotes;
    } else if (rawNotes is Map) {
      try {
        parsedNotes = jsonEncode(rawNotes);
      } catch (_) {
        parsedNotes = null;
      }
    } else {
      parsedNotes = null;
    }

    return Habit(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? 'İsimsiz',
      description: json['description'] ?? '',
      color: Color(json['color'] ?? Colors.blue.toARGB32()),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      reminderTime: time,
      reminderDays: (json['reminderDays'] as List?)?.cast<int>().toSet(),
      type: HabitType.values[json['type'] ?? 0],
      group: json['group'],
      icon: IconData(
        json['icon'] ?? Icons.favorite.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      targetCount: json['targetCount'],
      targetSeconds: json['targetSeconds'],
      dailyProgress: parsedDaily,
      notesDelta: parsedNotes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

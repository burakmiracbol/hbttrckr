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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    // Timezone'ı ayarla - çok önemli!
    try {
      // Local timezone'ı otomatik algıla ve ayarla
      tz.setLocalLocation(
          tz.getLocation('Europe/Istanbul')); // Varsayılan olarak Istanbul
      debugPrint('Timezone ayarlandı: ${tz.local.name}');
    } catch (e) {
      debugPrint('Timezone ayarlama hatası: $e');
      // Fallback: sistem timezone'ı kullan
      try {
        final locations = tz.timeZoneDatabase.locations;
        if (locations.isNotEmpty) {
          tz.setLocalLocation(locations.values.first);
        }
      } catch (_) {}
    }

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const WindowsInitializationSettings windowsSettings =
    WindowsInitializationSettings(
      appName: 'Habit Tracker',
      appUserModelId: 'com.hbttrckr.app',
      guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb',
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      windows: windowsSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);

    // Android 13+ için izin iste
    await _requestAndroidNotificationPermission();

    _isInitialized = true;
    debugPrint('NotificationService initialize tamam');
  }

  // Android 13+ için bildirim izni iste
  Future<void> _requestAndroidNotificationPermission() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? grantedNotificationPermission =
            await androidImplementation.requestNotificationsPermission();
        if (grantedNotificationPermission == true) {
          debugPrint('Bildirim izni verildi');
        } else {
          debugPrint('Bildirim izni reddedildi');
        }
      }
    } catch (e) {
      debugPrint('Bildirim izni isteme hatası: $e');
    }
  }

  // Basit bildirim gönder
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'habit_channel',
          'Habit Reminders',
          channelDescription: 'Bildirimler',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  // Planlı bildirim gönder
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'habit_channel',
          'Habit Reminders',
          channelDescription: 'Bildirimler',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      payload: payload,
    );
  }

  // Günlük bildirim planla (belirli bir saat)
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    Set<int>? daysOfWeek, // 1-7 (1=Monday, 7=Sunday)
    String? payload,
  }) async {
    // 1. ÖNCEKİ BİLDİRİMLERİ İPTAL ET
    try {
      await flutterLocalNotificationsPlugin.cancel(id: id);
      debugPrint('🗑️ Eski bildirim iptal edildi (ID: $id)');
    } catch (e) {
      debugPrint('❌ İptal hatası: $e');
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'habit_channel',
          'Habit Reminders',
          channelDescription: 'Bildirimler',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    if (daysOfWeek == null || daysOfWeek.isEmpty) {
      // 2. HER GÜN AYNI SAATTE BİLDİRİM GÖSTER - RECURSIVE SCHEDULING
      var now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      debugPrint('⏰ Şu an: ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
      debugPrint('🎯 Hedef: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');

      // Eğer belirtilen saat geçmişse yarın planla
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        debugPrint('✅ Saat geçmiş - YARINKI GÜNE PLAN: ${scheduledDate.day}/${scheduledDate.month} ${scheduledDate.hour}:${scheduledDate.minute.toString().padLeft(2, '0')}');
      } else {
        final minutesUntil = scheduledDate.difference(now).inMinutes;
        final secondsUntil = scheduledDate.difference(now).inSeconds;
        debugPrint('⏳ Kalan: $minutesUntil dakika $secondsUntil saniye');
        debugPrint('✅ BUGÜNE PLAN: ${scheduledDate.day}/${scheduledDate.month} ${scheduledDate.hour}:${scheduledDate.minute.toString().padLeft(2, '0')}');
      }

      // 3. PLANLA - matchDateTimeComponents.time KULLANMA! Kesin zaman kullan
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        // matchDateTimeComponents KALDIR - kesin tarih/saat kullan
        payload: payload,
      );

      debugPrint('📌 Planlandı: $title - ID:$id - ${scheduledDate.toString()}');
    } else {
      // Belirtilen günlerde (kullanılmıyor şu an ama var)
      for (int day in daysOfWeek) {
        var now = tz.TZDateTime.now(tz.local);
        var scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        int daysUntil = (day - now.weekday) % 7;
        if (daysUntil < 0) {
          daysUntil += 7;
        } else if (daysUntil == 0 && scheduledDate.isBefore(now)) {
          daysUntil = 7;
        }

        scheduledDate = scheduledDate.add(Duration(days: daysUntil));

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: id + day,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          payload: payload,
        );
      }
    }
  }

  // Bildirimi iptal et
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

  // Tüm bildirimleri iptal et
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Tüm planlı bildirimleri getir
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {final pending =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    debugPrint('📋 Planlı bildirimler (${pending.length} adet):');
    for (final notif in pending) {
      debugPrint('  - ID: ${notif.id}, Title: ${notif.title}');
    }
    return pending;
  }

  // Pending notifications'ları debug için yazdır
  Future<void> debugPendingNotifications() async {
    await getPendingNotifications();
  }
}

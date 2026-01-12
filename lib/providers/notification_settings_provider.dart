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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hbttrckr/services/notification_service.dart';

class NotificationSettings with ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  TimeOfDay _defaultReminderTime = const TimeOfDay(hour: 9, minute: 0);

  NotificationSettings() {
    _loadSettings();
  }

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  TimeOfDay get defaultReminderTime => _defaultReminderTime;

  // Setters
  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setDefaultReminderTime(TimeOfDay time) async {
    _defaultReminderTime = time;
    await _saveSettings();
    notifyListeners();
  }

  // SharedPreferences işlemleri
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;

    final savedHour = prefs.getInt('reminder_hour') ?? 9;
    final savedMinute = prefs.getInt('reminder_minute') ?? 0;
    _defaultReminderTime = TimeOfDay(hour: savedHour, minute: savedMinute);

    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('vibration_enabled', _vibrationEnabled);
    await prefs.setInt('reminder_hour', _defaultReminderTime.hour);
    await prefs.setInt('reminder_minute', _defaultReminderTime.minute);

    // Ayarlar değiştirilince tüm bildirimleri yeniden planla
    await _rescheduleAllNotifications();
  }

  // Tüm bildirimleri yeniden planla (ayarlar değiştirildiğinde)
  Future<void> _rescheduleAllNotifications() async {
    try {
      debugPrint('🔄 Ayarlar değiştirildi - bildirimleri yeniden planlıyor...');

      // Eğer bildirimler devre dışıysa tümünü iptal et
      if (!_notificationsEnabled) {
        debugPrint('🔕 Bildirimler devre dışı bırakıldı - tüm bildirimler iptal edildi');
        await NotificationService().cancelAllNotifications();
        return;
      }

      // Bildirimler açıksa, NotificationService'i reinitialize et
      debugPrint('🔔 Bildirimler açık - reinitialize ediliyor');
      await NotificationService().initialize();

      debugPrint(
          '✅ Bildirim ayarları güncellendi (Ses: $_soundEnabled, Titreşim: $_vibrationEnabled)');
    } catch (e) {
      debugPrint('❌ Bildirimleri yeniden planlama hatası: $e');
    }
  }
}

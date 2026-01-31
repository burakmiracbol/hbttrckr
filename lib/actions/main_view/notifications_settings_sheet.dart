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

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import '../../classes/all_widgets.dart';
import '../../providers/notification_settings_provider.dart';
import '../../services/notification_service.dart';

void showNotificationsSettingsSheet(BuildContext context) {
  showPlatformModalSheet(
    enableDrag: true,
    useSafeArea: true,
    isScrollControlled: true,
    context: context,
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 8.0),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: PlatformTitle(
                          fontSize: Theme.of(context,).textTheme.headlineSmall!.fontSize,
                          title: 'Bildirim Ayarları',
                          padding: EdgeInsets.fromLTRB(16,2,16,2)
                      ),
                    ),
                  ),
                ),
              ),

              // Bildirimleri Aç/Kapat
              Consumer<NotificationSettings>(
                builder: (ctx, notifSettings, child) {
                  return PlatformListTile(
                    leading: Icon(Icons.notifications_active),
                    title: Text("Bildirimleri Etkinleştir"),
                    trailing: PlatformSwitch(
                      value: notifSettings.notificationsEnabled,
                      onChanged: (value) async {
                        await notifSettings.setNotificationsEnabled(value);
                      },
                    ),
                    onTap: () {},
                  );
                },
              ),
              // Sesi Aç/Kapat
              Consumer<NotificationSettings>(
                builder: (ctx, notifSettings, child) {
                  return PlatformListTile(
                    leading: Icon(Icons.volume_up),
                    title: Text("Ses"),
                    trailing: PlatformSwitch(
                      value: notifSettings.soundEnabled,
                      onChanged: (value) async {
                        await notifSettings.setSoundEnabled(value);
                      },
                    ),
                    onTap: () {},
                  );
                },
              ),
              // Titreşimi Aç/Kapat
              Consumer<NotificationSettings>(
                builder: (ctx, notifSettings, child) {
                  return PlatformListTile(
                    leading: Icon(Icons.vibration),
                    title: Text("Titreşim"),
                    trailing: PlatformSwitch(
                      value: notifSettings.vibrationEnabled,
                      onChanged: (value) async {
                        await notifSettings.setVibrationEnabled(value);
                      },
                    ),
                    onTap: () {},
                  );
                },
              ),
              Divider(),
              // Varsayılan Hatırlatma Saati
              Consumer<NotificationSettings>(
                builder: (ctx, notifSettings, child) {
                  return PlatformListTile(
                    leading: Icon(Icons.schedule),
                    title: Text("Varsayılan Hatırlatma Saati"),
                    subtitle: Text(
                      notifSettings.defaultReminderTime.format(context),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    trailing: Icon(Icons.edit),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: notifSettings.defaultReminderTime,
                      );
                      if (picked != null) {
                        await notifSettings.setDefaultReminderTime(picked);
                      }
                    },
                  );
                },
              ),
              // Test Bildirim Butonu
              PlatformButton(
                onPressed: () async {
                  await NotificationService().showNotification(
                    id: 999,
                    title: '🔔 Test Bildirim',
                    body: 'Bildirim sistemi çalışıyor!',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Test bildirim gönderildi!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: IntrinsicWidth(
                  child: Row(
                    children: [Icon(Icons.send), Text('Test Bildirim Gönder')],
                  ),
                ),
              ),
              // Planlı Bildirimleri Kontrol Et
              PlatformButton(
                onPressed: () async {
                  await NotificationService().debugPendingNotifications();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Planlı bildirimler console\'da gösteriliyor',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: IntrinsicWidth(
                  child: Row(
                    children: [
                      Icon(Icons.list),
                      Text('Planlı Bildirimleri Kontrol Et'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

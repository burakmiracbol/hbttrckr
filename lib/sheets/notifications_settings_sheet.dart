import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_settings_provider.dart';
import '../services/notification_service.dart';

void showNotificationsSettingsSheet (
    BuildContext context
    ){
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
}
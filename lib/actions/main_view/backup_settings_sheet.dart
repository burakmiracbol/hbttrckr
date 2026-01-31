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

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import 'package:hbttrckr/providers/habit_provider.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import '../../services/backup_service.dart';
import '../../services/google_sign-in.dart';
import '../../classes/all_widgets.dart';
import 'local_backup_dialog.dart';

void showBackupSettingsSheet(BuildContext context) {
  showPlatformModalSheet(
    enableDrag: true,
    useSafeArea: true,
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: EdgeInsets.only(bottom: 6, left: 4, right: 4, top: 2),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: PlatformTitle(
                      fontSize: Theme.of(context,).textTheme.headlineSmall!.fontSize,
                      title: 'Yedekleme Ayarları',
                      padding: EdgeInsets.fromLTRB(16,2,16,2)
                  ),
                ),
              ),

              // BACKUP SECTION
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Center(
                  child: Text(
                    'Lokal Yedekleme',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),

              PlatformListTile(
                leading: Icon(Icons.cloud_download),
                title: Text('Tüm Verileri Dışa Aktar (Export)'),
                onTap: () async {
                  final fileName =
                      'hbttrckr_backup_${DateTime.now().millisecondsSinceEpoch}.hbtrckr_backup.json';
                  final file = await BackupService.exportBackup(fileName);

                  if (file != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Yedek kaydedildi: ${file.path}'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Yedekleme hatası'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),

              PlatformListTile(
                leading: Icon(Icons.cloud_upload),
                title: Text('Yedekten Geri Yükle (Import)'),
                onTap: () async {
                  try {
                    // Dosya seçici aç
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['json'],
                    );

                    if (result != null && result.files.single.path != null) {
                      final file = File(result.files.single.path!);

                      // İçeri aktar (Import)
                      final success = await BackupService.importBackup(file);

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ Yedek başarıyla yüklendi!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                        // App'ı restart et (optional)
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Yedek yükleme hatası'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Hata: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),

              PlatformListTile(
                leading: Icon(Icons.folder),
                title: Text('Kaydedilen Yedekleri Görüntüle'),
                onTap: () async {
                  final backups = await BackupService.listBackups();

                  showLocalBackupsDialog(context, backups);
                },
              ),

              // CLOUD SYNC SECTION
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Bulut Senkronizasyonu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),

              ValueListenableBuilder<GoogleSignInCredentials?>(
                valueListenable: googleUserNotifier,
                builder: (context, credentials, child) {
                  if (credentials == null) {
                    return Text(
                      'Bulut senkronizasyonu için Google ile giriş yapın.',
                      style: TextStyle(color: Colors.white60),
                    );
                  }

                  return Column(
                    children: [
                      PlatformListTile(
                        onTap: () async {
                          final success =
                              await BackupService.uploadBackupToCloud(
                                credentials,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? '✅ Buluta yedeklendi.'
                                    : '❌ Buluta yedekleme hatası',
                              ),
                              backgroundColor: success ? null : Colors.red,
                            ),
                          );
                        },
                        leading: Icon(Icons.cloud_upload_outlined),
                        title: Text('Buluta Yedekle'),
                      ),

                      PlatformListTile(
                        onTap: () async {
                          final success =
                              await BackupService.restoreBackupFromCloud(
                                credentials,
                              );

                          // 2. Widget hala ekranda mı kontrol et (En kritik nokta!)
                          if (!context.mounted) return;

                          if (success) {
                            // 3. Verileri Provider üzerinden tekrar yükle
                            // Provider kullanıyorsan notifyListeners() zaten UI'ı yenileyeceği için
                            // ekstradan setState(() {}) yapmana gerek kalmayabilir.
                            await context.read<HabitProvider>().loadHabits();

                            // Eğer ana ekranın (Home) bu değişikliği hemen görmesini istiyorsan
                            // ve Provider içinde notifyListeners() varsa UI otomatik yenilenir.
                          }

                          // 4. SnackBar göster
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? '✅ Buluttan geri yüklendi.'
                                    : '❌ Bulut yedeği bulunamadı',
                              ),
                              backgroundColor: success
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          );

                          // 5. Başarılıysa sheet'i kapat (opsiyonel)
                          if (success) {
                            Navigator.of(context).pop();
                          }
                        },
                        leading: Icon(Icons.cloud_download_outlined),
                        title: Text('Buluttan Geri Yükle'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

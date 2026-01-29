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
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import 'package:hbttrckr/main.dart';
import 'package:hbttrckr/providers/habit_provider.dart';
import 'package:provider/provider.dart';
import '../../services/backup_service.dart';

void showBackupSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    enableDrag: true,
    useSafeArea: true,
    context: context,
    isScrollControlled: true,
    builder: (ctx) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(64)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(64)),
            border: Border.all(
              color: Colors.white.withOpacity(
                0.2,
              ), // İnce ışık yansıması (kenarlık)
              width: 1.5,
            ),
          ),
          child: StatefulBuilder(
            builder: (context, setState) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ayarlar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // BACKUP SECTION
                    Text(
                      'Yedekleme',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Export Button
                    ElevatedButton.icon(
                      onPressed: () async {
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
                      icon: Icon(Icons.cloud_download),
                      label: Text('Tüm Verileri Dışa Aktar (Export)'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 12),

                    // Import Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          // Dosya seçici aç
                          final result = await FilePicker.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['json'],
                          );

                          if (result != null &&
                              result.files.single.path != null) {
                            final file = File(result.files.single.path!);

                            // İçeri aktar (Import)
                            final success = await BackupService.importBackup(
                              file,
                            );

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
                      icon: Icon(Icons.cloud_upload),
                      label: Text('Yedekten Geri Yükle (Import)'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 12),

                    // CLOUD SYNC SECTION
                    Text(
                      'Bulut Senkronizasyonu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 12),
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
                            ElevatedButton.icon(
                              onPressed: () async {
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
                                    backgroundColor:
                                        success ? null : Colors.red,
                                  ),
                                );
                              },
                              icon: Icon(Icons.cloud_upload_outlined),
                              label: Text('Buluta Yedekle'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                                backgroundColor: Colors.indigo[700],
                              ),
                            ),
                            SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final success = await BackupService.restoreBackupFromCloud(credentials);

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
                                      success ? '✅ Buluttan geri yüklendi.' : '❌ Bulut yedeği bulunamadı',
                                    ),
                                    backgroundColor: success ? Colors.green : Colors.red,
                                  ),
                                );

                                // 5. Başarılıysa sheet'i kapat (opsiyonel)
                                if (success) {
                                  Navigator.of(context).pop();
                                }
                              },
                              icon: Icon(Icons.cloud_download_outlined),
                              label: Text('Buluttan Geri Yükle'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                                backgroundColor: Colors.deepPurple[700],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 12),

                    // List Backups Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        final backups = await BackupService.listBackups();

                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Colors.grey[900],
                            title: Text(
                              'Kaydedilen Yedekler (${backups.length})',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: backups.isEmpty
                                ? Text(
                                    'Henüz yedek kaydedilmedi',
                                    style: TextStyle(color: Colors.grey),
                                  )
                                : SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: backups
                                          .map(
                                            (file) => Padding(
                                              padding: EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          file.path
                                                              .split('/')
                                                              .last,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          '${(file.lengthSync() / 1024).toStringAsFixed(2)} KB',
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: 18,
                                                    ),
                                                    onPressed: () async {
                                                      await BackupService.deleteBackup(
                                                        file,
                                                      );
                                                      Navigator.pop(ctx);
                                                      setState(() {});
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text('Kapat'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(Icons.folder),
                      label: Text('Kaydedilen Yedekleri Görüntüle'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.orange[700],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

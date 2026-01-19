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
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BackupService {
  /// Tüm verileri JSON dosyasına export et
  static Future<File?> exportBackup(String fileName) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // SharedPreferences'teki TÜM verileri al
      final Map<String, dynamic> backupData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'preferences': {},
      };

      // Tüm preferences'i al
      final Set<String> keys = prefs.getKeys();
      for (final key in keys) {
        final value = prefs.get(key);
        backupData['preferences'][key] = value;
      }

      // JSON'u format et
      final jsonString = jsonEncode(backupData);

      // Dosya olarak kaydet (Downloads folder'a)
      final directory = Directory('/storage/emulated/0/Downloads'); // Android
      if (!await directory.exists()) {
        // Fallback: Temp directory
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsString(jsonString);
        return file;
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      debugPrint('✅ Backup exported to: ${file.path}');
      return file;
    } catch (e) {
      debugPrint('❌ Export error: $e');
      return null;
    }
  }

  /// JSON dosyasından verileri import et
  static Future<bool> importBackup(File backupFile) async {
    try {
      // Dosyayı oku
      final jsonString = await backupFile.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Version kontrol et
      final version = backupData['version'] ?? '1.0';
      if (version != '1.0') {
        debugPrint('⚠️ Backup version mismatch: $version');
        return false;
      }

      // Preferences'i restore et
      final prefs = await SharedPreferences.getInstance();
      final preferences = backupData['preferences'] as Map<String, dynamic>;

      for (final entry in preferences.entries) {
        final key = entry.key;
        final value = entry.value;

        // Type'a göre set et
        if (value is String) {
          await prefs.setString(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is List) {
          await prefs.setStringList(key, List<String>.from(value));
        }
      }

      debugPrint('✅ Backup imported successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Import error: $e');
      return false;
    }
  }

  /// Backup dosyasını sil
  static Future<bool> deleteBackup(File backupFile) async {
    try {
      if (await backupFile.exists()) {
        await backupFile.delete();
        debugPrint('✅ Backup deleted: ${backupFile.path}');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      return false;
    }
  }

  /// Backup dosyalarını listele
  static Future<List<File>> listBackups() async {
    try {
      final directory = defaultTargetPlatform == TargetPlatform.android ? Directory('/storage/emulated/0/Downloads') : Directory.systemTemp;
      if (!await directory.exists()) {
        return [];
      }

      final files = directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.hbtrckr_backup.json'))
          .toList();

      return files;
    } catch (e) {
      debugPrint('❌ List backups error: $e');
      return [];
    }
  }
}


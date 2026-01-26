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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BackupService {
  static Future<Map<String, dynamic>> _buildBackupPayload() async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> backupData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'preferences': <String, dynamic>{},
    };

    final Set<String> keys = prefs.getKeys();
    for (final key in keys) {
      final value = prefs.get(key);
      backupData['preferences'][key] = value;
    }

    return backupData;
  }

  static Future<void> _restorePreferences(
    Map<String, dynamic> preferences,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in preferences.entries) {
      final key = entry.key;
      final value = entry.value;

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
  }

  /// Tüm verileri JSON dosyasına export et
  static Future<File?> exportBackup(String fileName) async {
    try {
      final backupData = await _buildBackupPayload();

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
      final preferences = backupData['preferences'] as Map<String, dynamic>;
      await _restorePreferences(preferences);

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

  /// Yedeği buluta yükle
  static Future<bool> uploadBackupToCloud(
    GoogleSignInAccount user,
  ) async {
    try {
      final backupData = await _buildBackupPayload();
      await FirebaseFirestore.instance
          .collection('user_backups')
          .doc(user.id)
          .set({
        'user': {
          'id': user.id,
          'email': user.email,
          'displayName': user.displayName,
          'photoUrl': user.photoUrl,
        },
        'data': backupData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ Backup uploaded to cloud for: ${user.email}');
      return true;
    } catch (e) {
      debugPrint('❌ Cloud upload error: $e');
      return false;
    }
  }

  /// Buluttan yedeği geri yükle
  static Future<bool> restoreBackupFromCloud(
    GoogleSignInAccount user,
  ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_backups')
          .doc(user.id)
          .get();

      if (!snapshot.exists) {
        return false;
      }

      final data = snapshot.data();
      if (data == null) {
        return false;
      }

      final rawBackup = data['data'];
      if (rawBackup is! Map) {
        return false;
      }
      final backupData = Map<String, dynamic>.from(rawBackup as Map);

      final version = backupData['version'] ?? '1.0';
      if (version != '1.0') {
        debugPrint('⚠️ Backup version mismatch: $version');
        return false;
      }

      final rawPreferences = backupData['preferences'];
      if (rawPreferences is! Map) {
        return false;
      }

      await _restorePreferences(
        Map<String, dynamic>.from(rawPreferences as Map),
      );
      debugPrint('✅ Backup restored from cloud for: ${user.email}');
      return true;
    } catch (e) {
      debugPrint('❌ Cloud restore error: $e');
      return false;
    }
  }
}


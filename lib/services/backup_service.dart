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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class BackupService {
  static Future<Map<String, dynamic>> _buildBackupPayload() async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> backupData = {
      'version': backupVersion,
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


      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/$fileName');
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
      final version = backupData['version']?.toString() ?? backupVersion;
      if (version != backupVersion) {
        debugPrint(
          '⚠️ Backup version mismatch: $version (expected: $backupVersion)',
        );
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
      final directory = Directory.systemTemp;
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
  // Parametre tipi GoogleSignInCredentials olarak güncellendi
  static Future<bool> uploadBackupToCloud(GoogleSignInCredentials credentials) async {
    try {
      debugPrint('📤 Upload başlatılıyor (All Platforms)...');

      // 1. Firebase Auth durumunu kontrol et
      var firebaseUser = FirebaseAuth.instance.currentUser;
      debugPrint('🔥 Firebase User: ${firebaseUser?.uid}');

      // 2. Eğer Firebase User null ise veya oturum düşmüşse credentials ile tekrar bağlan
      if (firebaseUser == null) {
        debugPrint('❌ Firebase Auth bağlı değil, credentials ile bağlanılıyor...');
        try {
          final credential = GoogleAuthProvider.credential(
            idToken: credentials.idToken,
            accessToken: credentials.accessToken,
          );
          final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          firebaseUser = userCredential.user;
          debugPrint('✅ Firebase Auth yeniden senkronize edildi: ${firebaseUser?.uid}');
        } catch (authError) {
          debugPrint('❌ Firebase Auth senkronizasyon hatası: $authError');
          return false;
        }
      }

      // UID kontrolü
      final currentUid = firebaseUser?.uid;
      if (currentUid == null) {
        debugPrint('❌ UID hala null, işlem iptal ediliyor.');
        return false;
      }

      // 3. Payload oluşturma
      debugPrint('📦 Backup payload oluşturuluyor...');
      final backupPayload = await _buildBackupPayload();

      // 4. Firestore'a yazma
      debugPrint('☁️ Firestore\'a yazılıyor... Doc: $currentUid');

      await FirebaseFirestore.instance
          .collection('user-backups')
          .doc(currentUid)
          .set({
        'user': {
          'uid': currentUid,
          'email': firebaseUser?.email, // Bilgileri Firebase'den çekmek en garantisi
          'displayName': firebaseUser?.displayName,
          'photoUrl': firebaseUser?.photoURL,
        },
        'payload': backupPayload,
        'updatedAt': FieldValue.serverTimestamp(),
        'version': '1.0', // Versiyon kontrolü için ekledik
      }, SetOptions(merge: true));

      debugPrint('✅ Backup uploaded to cloud for: ${firebaseUser?.email}');
      return true;

    } on FirebaseException catch (e) {
      debugPrint('❌ Firebase hatası: Code: ${e.code}, Message: ${e.message}');
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ Cloud upload error: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      return false;
    }
  }

  /// Buluttan yedeği geri yükle
  static Future<bool> restoreBackupFromCloud(GoogleSignInCredentials credentials) async {
    try {
      debugPrint('📥 Cloud restore başlatılıyor (All Platforms)...');

      // UID'yi Firebase'den alıyoruz (Tüm platformlarda ortak anahtar)
      final uid = FirebaseAuth.instance.currentUser?.uid;
      debugPrint('🔥 Firebase User ID: $uid');

      if (uid == null) {
        debugPrint('❌ UID null, işlem iptal ediliyor. Firebase Auth oturumu kontrol edilmeli.');
        return false;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('user-backups')
          .doc(uid)
          .get();

      if (!snapshot.exists) {
        debugPrint('⚠️ Bu kullanıcı için bulut yedeği bulunamadı.');
        return false;
      }

      final data = snapshot.data();
      if (data == null) {
        debugPrint('❌ Snapshot verisi boş.');
        return false;
      }

      debugPrint('📦 Ham yedek alınıyor (payload)...');
      final rawBackup = data['payload'];
      if (rawBackup is! Map) {
        debugPrint('❌ Payload bir harita (Map) değil.');
        return false;
      }

      final backupData = Map<String, dynamic>.from(rawBackup);

      // Versiyon Kontrolü
      final version = backupData['version']?.toString() ?? backupVersion;
      debugPrint('📦 Yedek versiyonu: $version, Beklenen: $backupVersion');
      if (version != backupVersion) {
        debugPrint(
          '⚠️ Yedek versiyonu uyuşmuyor: $version (beklenen: $backupVersion)',
        );
        return false;
      }

      debugPrint('⚙️ Ham tercihler alınıyor (preferences)...');
      final rawPreferences = backupData['preferences'];
      if (rawPreferences is! Map) {
        debugPrint('❌ Tercihler formatı hatalı.');
        return false;
      }

      final preferences = Map<String, dynamic>.from(rawPreferences);

      // Yerel depolamaya (SharedPreferences/Isar vb.) yazma işlemi
      await _restorePreferences(preferences);

      // Başarı logu için emaili Firebase'den alıyoruz
      debugPrint('✅ Yedek buluttan geri yüklendi: ${FirebaseAuth.instance.currentUser?.email}');
      return true;

    } catch (e, stackTrace) {
      debugPrint('❌ Cloud restore hatası: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      return false;
    }
  }

}

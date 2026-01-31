import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

final googleSignIn = GoogleSignIn(
  // See 'How to Get Google OAuth Credentials' section below
  params: const GoogleSignInParams(
    clientId: '1050920329447-i5e1gdora94j3bprsu65p3oee3tv0mre.apps.googleusercontent.com',
    clientSecret: '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', // Don't worry - not truly a secret! See 'Client Secret Requirements'
    redirectPort: 8000,
    scopes: ['email', 'profile'],
  ),
);

final googleUserNotifier = ValueNotifier<GoogleSignInCredentials?>(null);

void initializeGoogleSignIn() {
  // 1. Durum değişikliklerini dinle (Bu stream tüm platformlarda çalışır)
  googleSignIn.authenticationState.listen((credentials) async {
    if (credentials != null) {
      // Kullanıcı verilerini bir şekilde saklamak istersen credentials içinde her şey var
      // googleUserNotifier.value = ... (Burada credentials'ı notifier'a pasla)

      try {
        // --- Firebase Senkronizasyonu ---
        // Bu paket credentials içinde hem idToken hem accessToken'ı doğrudan veriyor

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: credentials.idToken,
          accessToken: credentials.accessToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
        print("✅ Firebase Auth senkronize edildi. UID: ${FirebaseAuth.instance.currentUser?.uid}");

        // Hatırla: Veriyi gördüğün an yedeklemeyi de burada tetikleyebilirsin
        // BackupService.uploadBackupToCloud(...);

      } catch (e) {
        print("❌ Firebase Bağlantı Hatası: $e");
      }
    } else {
      // Kullanıcı çıkış yaptı
      googleUserNotifier.value = null;
      await FirebaseAuth.instance.signOut();
      print("🚪 Firebase Auth oturumu kapatıldı.");
    }
  }).onError((error) {
    print("⚠️ Stream Hatası: $error");
  });

  // 2. Uygulama açılışında önceki oturumu kontrol et (Silent SignIn)
  // Bu, senin eski 'attemptLightweightAuthentication' kısmının yerini alır.
  googleSignIn.silentSignIn();
}

Future<GoogleSignInCredentials?> seamlessAuthentication() async {
  // 1. Önce sessizce dene (Kullanıcı hiçbir şey görmez, token yenilenir)
  final silentCreds = await googleSignIn.silentSignIn();
  if (silentCreds != null) {
    googleUserNotifier.value = silentCreds; // UI'ı güncelliyoruz
    return silentCreds;
  }

  // 2. Hafif giriş dene (Mobil/Web'de 1-2 tık, Windows'ta genelde pas geçer)
  final lightCreds = await googleSignIn.lightweightSignIn();
  if (lightCreds != null) {
    googleUserNotifier.value = lightCreds;
    return lightCreds;
  }

  // 3. Son çare tam akış (Tarayıcı açılır)
  final onlineCreds = await googleSignIn.signInOnline();
  if (onlineCreds != null) {
    googleUserNotifier.value = onlineCreds;
  }
  return onlineCreds;
}
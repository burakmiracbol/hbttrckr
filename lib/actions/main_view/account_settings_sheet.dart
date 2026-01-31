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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in_all_platforms/google_sign_in_all_platforms.dart';

import '../../services/google_sign-in.dart';


void showAccountSettingsSheet (
    BuildContext context,
    ) {
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    enableDrag: true,
    useSafeArea: true,
    isScrollControlled: true,
    context: context,
    builder: (sheetContext) {
      return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(64)),
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(64)),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2), // İnce ışık yansıması (kenarlık)
                    width: 1.5,
                  ),
                ),
        child: Padding(
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
                        "Account",
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
                ValueListenableBuilder<GoogleSignInCredentials?>(
                  valueListenable: googleUserNotifier,
                  builder: (context, credentials, child) {
                    if (credentials == null) {
                      return buildSignInSection();
                    }

                    // Bilgileri paketten değil, Firebase'den çekiyoruz
                    final firebaseUser = FirebaseAuth.instance.currentUser;

                    return Column(
                      children: [
                        Card(
                          child: IntrinsicWidth(
                            child: Padding( // Biraz nefes payı ekleyelim
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Profil fotoğrafını Firebase'den alıyoruz
                                    if (firebaseUser?.photoURL != null)
                                      CircleAvatar(
                                        radius: 32,
                                        backgroundImage: NetworkImage(firebaseUser!.photoURL!),
                                      )
                                    else
                                      const CircleAvatar(
                                        radius: 32,
                                        child: Icon(Icons.person),
                                      ),

                                    const SizedBox(width: 12), // Boşluk olmazsa olmaz

                                    Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            firebaseUser?.displayName ?? 'Google Kullanıcısı',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          Text(
                                            firebaseUser?.email ?? 'Email yok',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                          Text(
                                            // Firebase UID veya Google ID (Credentials'dan gelen idToken decode edilebilir ama UID yeterli)
                                            'ID: ${firebaseUser?.uid.substring(0, 8)}...',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ]
                                    ),
                                  ]
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              await googleSignIn.signOut();
                              // initialize içindeki listen zaten notifier'ı null yapacak ama garantiye alabilirsin
                            },
                            child: const Text('Hesaptan çıkış yap'),
                          ),
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        ),))
      );
    },
  );
}

// backup_settings_sheet.dart içinde butonun olduğu yer:

Widget buildSignInSection() {
  // Eğer Web'deysen paketin kendi butonunu göster
  if (kIsWeb) {
    return googleSignIn.signInButton() ?? const SizedBox.shrink();
  }

  // Diğer platformlarda (Android, Windows vb.) senin kendi butonun
  return ElevatedButton(
    onPressed: () async {
      await seamlessAuthentication(); // Bu metod Android'de lightweight, Windows'ta browser açar
    },
    child: const Text("Google ile Giriş Yap"),
  );
}
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
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hbttrckr/main.dart';


void showAccountSettingsSheet (
    BuildContext context,
    TextEditingController accountController,
    TextEditingController passwordController,
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
                    color: Colors.white.withOpacity(0.2), // İnce ışık yansıması (kenarlık)
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
                ValueListenableBuilder<GoogleSignInAccount?>(
                  valueListenable: googleUserNotifier,
                  builder: (context, user, child) {
                    if (user == null) {
                      return buildSignInButton();
                    }

                    return Column(
                      children: [
                        Card(
                          child: IntrinsicWidth(
                            child: Row(
                              children: [
                                if (user.photoUrl != null)
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundImage: NetworkImage(user.photoUrl!),
                                  )
                                else
                                  const CircleAvatar(
                                    radius: 32,
                                    child: Icon(Icons.person),
                                  ),

                                Column(
                                  children: [
                                    Text(
                                      user.displayName ?? 'Google Kullanıcısı',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      user.email,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      user.id,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ]
                                ),
                              ]
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              await googleSignIn.signOut();
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

Widget buildSignInButton() {
  // Eğer platform klasik authenticate metodunu destekliyorsa (Mobil gibi)
  if (googleSignIn.supportsAuthenticate()) {
    return ElevatedButton(
      onPressed: () async {
        try {
          // Asıl giriş işlemi burada yapılıyor
          await googleSignIn.authenticate();
        } catch (e) {
          print("Giriş Hatası: $e");
        }
      },
      child: const Text('Google Sign-in'),
    );
  } else {
    // Web platformunda iseniz farklı bir buton render edilmelidir
    // return GoogleSignInWeb.renderButton();
    return const SizedBox();
  }
}
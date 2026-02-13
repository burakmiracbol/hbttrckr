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
import 'package:flutter/material.dart';
import 'package:hbttrckr/classes/glass_card.dart';
import 'package:hbttrckr/actions/main_view/backup_settings_sheet.dart';
import 'package:hbttrckr/actions/main_view/general_pref_sheet.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../classes/all_widgets.dart';
import 'account_settings_sheet.dart';
import 'notifications_settings_sheet.dart';

void showMainSettingsSheet(BuildContext context) {
  showPlatformModalSheet(
    enableDrag: true,
    useSafeArea: true,
    isScrollControlled: true,
    context: context,
    builder: (sheetContext) {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 8.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: PlatformTitle(
                    fontSize: Theme.of(
                      context,
                    ).textTheme.headlineSmall!.fontSize,
                    title: 'Ayarlar',
                    padding: EdgeInsets.fromLTRB(16, 2, 16, 2),
                  ),
                ),
              ),
            ),
          ),

          PlatformListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(firebaseUser!.photoURL!),
            ),
            title: Text("Hesap Bilgileri"),
            subtitle: Text("Hesap bilgilerinizi görüntüleyin"),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              showAccountSettingsSheet(context);
            },
          ),

          PlatformListTile(
            leading: CircleAvatar(child: Icon(Icons.notifications_outlined)),
            title: Text("Bildirimler"),
            subtitle: Text("Bildirim ayarlarıını görüntüleyin"),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              showNotificationsSettingsSheet(context);
            },
          ),

          PlatformListTile(
            leading: CircleAvatar(child: Icon(Icons.tune)),
            title: Text("Tercihler"),
            subtitle: Text("Uygulamanın genel tercihlerini görüntüleyin"),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              showGeneralPrefsSheet(context);
            },
          ),

          PlatformListTile(
            leading: CircleAvatar(child: Icon(Icons.backup)),
            title: Text("Yedekler"),
            subtitle: Text("Yedekleri yönetin"),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              showBackupSettingsSheet(context);
            },
          ),
        ],
      );
    },
  );
}

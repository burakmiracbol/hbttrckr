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

import 'package:flutter/material.dart';
import 'package:hbttrckr/classes/glass_card.dart';
import 'package:hbttrckr/sheets/main_view/backup_settings_sheet.dart';
import 'package:hbttrckr/sheets/main_view/preferences_settings_sheet.dart';
import 'account_settings_sheet.dart';
import 'notifications_settings_sheet.dart';

void showMainSettingsSheet(
  BuildContext context,
  TextEditingController accountController,
  TextEditingController passwordController,
) {
  showModalBottomSheet(
    enableDrag: true,
    useSafeArea: true,
    isScrollControlled: true,
    context: context,
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: glassContainer(
                    context: context,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 4.0, 14.0, 8.0),
                      child: Text(
                        "Ayarlar",
                        style: TextStyle(
                          fontSize: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.fontSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.account_circle_outlined),
                    ),
                    title: Text("Hesap Bilgileri"),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      showAccountSettingsSheet(
                        context,
                        accountController,
                        passwordController,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.notifications_outlined),
                    ),
                    title: Text("Bildirimler"),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      showNotificationsSettingsSheet(context);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(Icons.tune)),
                    title: Text("Tercihler"),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      showPreferencesSettingsSheet(context);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(Icons.backup)),
                    title: Text("Yedekler"),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      showBackupSettingsSheet(context);
                    },
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

import 'package:flutter/material.dart';
import 'package:hbttrckr/sheets/backup_settings_sheet.dart';
import 'package:hbttrckr/sheets/preferences_settings_sheet.dart';
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
        padding: const EdgeInsets.only(
          top: 16,
          left: 8,
          right: 8,
          bottom: 8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
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
                    leading: CircleAvatar(
                      child: Icon(Icons.tune),
                    ),
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
                    leading: CircleAvatar(
                      child: Icon(Icons.backup),
                    ),
                    title: Text("Yedekler"),
                    trailing: Icon(Icons.chevron_right),
                    onTap: (){
                      showBackupSettingsSheet(context);
                    },
                  )
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
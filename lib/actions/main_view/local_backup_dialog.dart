

import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/backup_service.dart';

void showLocalBackupsDialog(BuildContext context, List<File> backups) {
  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: backups
                        .map(
                          (file) => Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file.path.split('/').last,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
                                    await BackupService.deleteBackup(file);
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
        );
      },
    ),
  );
}

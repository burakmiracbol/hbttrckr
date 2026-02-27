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
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import '../../classes/all_widgets.dart';
import 'package:hbttrckr/data_types/habit.dart';


Future<String?> showNotesEditorSheet(BuildContext context, Habit current ) async {
  final result = await showPlatformModalSheet<String?>(
    context:
    context,
    isScrollControlled:
    true,
    builder: (ctx) =>
        HabitNotesEditorSheet(
          initialDeltaJson:
          current.notesDelta,
        ),
  );
  return result;
}

/// Modal bottom sheet widget that edits Quill delta JSON and returns the
/// resulting delta string when saved. Uses flutter_quill (Dart 3 compatible).
class HabitNotesEditorSheet extends StatefulWidget {
  final String? initialDeltaJson;

  const HabitNotesEditorSheet({super.key, this.initialDeltaJson});

  @override
  State<HabitNotesEditorSheet> createState() => _HabitNotesEditorSheetState();
}

class _HabitNotesEditorSheetState extends State<HabitNotesEditorSheet> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    // Use basic controller and load document afterwards for compatibility with API
    _controller = QuillController.basic();

    if (widget.initialDeltaJson != null) {
      try {
        final decoded = jsonDecode(widget.initialDeltaJson!);
        if (decoded is List) {
          _controller.document = Document.fromJson(List.from(decoded));
        }
      } catch (_) {
        // ignore and keep empty document
      }
    }

    _controller.changes.listen((event) {
      setState(() {
        _changed = true;
      });
    });
  }

  Future<String> _fileToDataUrlFromFile(File file) async {
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    final mime = lookupMimeType(file.path) ?? 'image/png';
    return 'data:$mime;base64,$base64Str';
  }

  Future<String?> _fileToDataUrl(dynamic file) async {
    if (file == null) return null;
    if (file is XFile) return await _fileToDataUrlFromFile(File(file.path));
    if (file is File) return await _fileToDataUrlFromFile(file);
    return null;
  }

  Future<void> _insertImageManual() async {
    final XFile? xfile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, maxHeight: 1200, imageQuality: 80);
    if (xfile == null) return;
    final dataUrl = await _fileToDataUrl(xfile);
    if (dataUrl == null) return;
    final index = _controller.selection.baseOffset;
    final length = _controller.selection.extentOffset - index;
    _controller.replaceText(index, length, BlockEmbed.image(dataUrl), null);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  ImageProvider? _imageProviderForUrl(BuildContext context, String imageUrl) {
    // data URL
    if (imageUrl.startsWith('data:')) {
      try {
        final base64Str = imageUrl.split(',').last;
        final bytes = base64Decode(base64Str);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }
    // assets
    if (imageUrl.startsWith('assets/')) return AssetImage(imageUrl);
    // file path
    try {
      final f = File(imageUrl);
      if (f.existsSync()) return FileImage(f);
    } catch (_) {}
    return null; // fallback
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: !_changed
                          ? null
                          : () {
                              final delta = _controller.document.toDelta();
                              final jsonStr = jsonEncode(delta.toJson());
                              Navigator.of(context).pop(jsonStr);
                            },
                      child: const Text('Kaydet'),
                    ),
                  ],
                ),
              ),

              QuillSimpleToolbar(
                controller: _controller,
                config: QuillSimpleToolbarConfig(
                  embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                  showClipboardPaste: true,
                ),
              ),

              Expanded(
                child: QuillEditor(
                  controller: _controller,
                  focusNode: _focusNode,
                  scrollController: _scrollController,
                  config: QuillEditorConfig(
                    scrollable: true,
                    autoFocus: false,
                    expands: false,
                    placeholder: 'Notlarını buraya yaz... (resim ekleyebilirsin)',
                    padding: const EdgeInsets.all(12),
                    embedBuilders: [
                      ...FlutterQuillEmbeds.editorBuilders(
                        imageEmbedConfig: QuillEditorImageEmbedConfig(
                          imageProviderBuilder: (context, imageUrl) => _imageProviderForUrl(context, imageUrl),
                        ),
                        videoEmbedConfig: QuillEditorVideoEmbedConfig(
                          customVideoBuilder: (videoUrl, readOnly) => null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // optional manual image insert button area (useful on platforms where toolbar callback differs)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _insertImageManual,
                      icon: const Icon(Icons.image),
                      label: const Text('Resim Ekle'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

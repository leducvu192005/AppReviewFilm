import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:flutter_application_1/services/library_service.dart';

enum EditorTool { crop, text, sticker, filter, draw }

final libraryService = LibraryService();
Uint8List? editedBytes;
Future<String> saveEditedImageLocally(Uint8List bytes) async {
  final dir = await getApplicationDocumentsDirectory();

  final editedDir = Directory('${dir.path}/edited_posters');

  if (!await editedDir.exists()) {
    await editedDir.create(recursive: true);
  }

  final file = File(
    '${editedDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png',
  );

  await file.writeAsBytes(bytes);

  return file.path;
}

Future<void> openImageEditor({
  required BuildContext context,
  required String imageUrl,
  required Function(String path) onComplete,
}) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        final isNetwork = imageUrl.startsWith('http');

        final editorWidget = isNetwork
            ? ProImageEditor.network(
                imageUrl,
                configs: ProImageEditorConfigs(
                  designMode: ImageEditorDesignMode.material,
                  cropRotateEditor: CropRotateEditorConfigs(enabled: true),
                  textEditor: TextEditorConfigs(enabled: true),
                  filterEditor: FilterEditorConfigs(enabled: true),
                  stickerEditor: StickerEditorConfigs(enabled: true),
                  paintEditor: PaintEditorConfigs(enabled: true),

                  emojiEditor: EmojiEditorConfigs(enabled: false),
                  tuneEditor: TuneEditorConfigs(enabled: false),
                  blurEditor: BlurEditorConfigs(enabled: false),
                  theme: ThemeData.dark().copyWith(
                    scaffoldBackgroundColor: const Color(0xFF0F1012),

                    colorScheme: const ColorScheme.dark(
                      primary: Color(0xFFFFD21E),
                    ),

                    iconTheme: const IconThemeData(color: Color(0xFFFFD21E)),

                    appBarTheme: const AppBarTheme(
                      backgroundColor: Color.fromARGB(255, 50, 50, 51),
                    ),

                    bottomNavigationBarTheme:
                        const BottomNavigationBarThemeData(
                          backgroundColor: Color(0xFF1A1C1E),
                          selectedItemColor: Color(0xFFFFD21E),
                          unselectedItemColor: Colors.white54,
                        ),
                  ),
                ),
                callbacks: ProImageEditorCallbacks(
                  onImageEditingComplete: (Uint8List bytes) async {
                    editedBytes = bytes;

                    final localPath = await saveEditedImageLocally(bytes);

                    onComplete(localPath);
                  },
                  onCloseEditor: (_) {
                    Navigator.pop(context);
                  },
                ),
              )
            : ProImageEditor.file(
                File(imageUrl),
                configs: ProImageEditorConfigs(
                  designMode: ImageEditorDesignMode.material,
                  cropRotateEditor: CropRotateEditorConfigs(enabled: true),
                  textEditor: TextEditorConfigs(enabled: true),
                  filterEditor: FilterEditorConfigs(enabled: true),
                  stickerEditor: StickerEditorConfigs(enabled: true),
                  paintEditor: PaintEditorConfigs(enabled: true),

                  emojiEditor: EmojiEditorConfigs(enabled: false),
                  tuneEditor: TuneEditorConfigs(enabled: false),
                  blurEditor: BlurEditorConfigs(enabled: false),
                ),
                callbacks: ProImageEditorCallbacks(
                  onImageEditingComplete: (Uint8List bytes) async {
                    editedBytes = bytes;

                    final localPath = await saveEditedImageLocally(bytes);

                    onComplete(localPath);
                  },
                  onCloseEditor: (_) {
                    Navigator.pop(context);
                  },
                ),
              );

        return editorWidget;
      },
    ),
  );
}

Future<void> openImageEditorFromBytes({
  required BuildContext context,
  required Uint8List bytes,
  required Function(String path) onComplete,
}) async {
  final tmpDir = await getTemporaryDirectory();
  final tmpFile = File(
    '${tmpDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await tmpFile.writeAsBytes(bytes);
  await openImageEditor(
    context: context,
    imageUrl: tmpFile.path,
    onComplete: onComplete,
  );
}

class MainActionsToolbar extends StatelessWidget {
  final VoidCallback onEditPressed;
  final VoidCallback onSavedPressed;
  final VoidCallback onDownloadPressed;
  final bool showAddButton;

  const MainActionsToolbar({
    super.key,
    required this.onEditPressed,
    required this.onSavedPressed,
    required this.onDownloadPressed,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 60, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onEditPressed,
            child: const ActionButton(
              icon: Icons.edit_note,
              label: 'Edit',
              bgColor: Colors.white24,
            ),
          ),
          const SizedBox(width: 8),
          if (showAddButton) ...[
            GestureDetector(
              onTap: onSavedPressed,
              child: const ActionButton(
                icon: Icons.image,
                label: 'Add to Library',
                bgColor: Colors.white24,
              ),
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: onDownloadPressed,
            child: const ActionButton(
              icon: Icons.download_for_offline,
              label: 'Save',
              bgColor: Color(0xFF323335),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final bool isDisable;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.bgColor,
    this.isDisable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDisable
              ? Colors.transparent
              : const Color(0xFFFFD21E).withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDisable ? Colors.grey : const Color(0xFFFFD21E),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDisable ? Colors.grey : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _toolButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFFFFD21E), size: 24),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    ),
  );
}

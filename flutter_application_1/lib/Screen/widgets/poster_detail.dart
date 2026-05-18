import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screen/edit/home_edit.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PosterDetailScreen extends StatefulWidget {
  final String posterUrl;
  final bool showAddButton;
  const PosterDetailScreen({
    super.key,
    required this.posterUrl,
    this.showAddButton = true,
  });

  @override
  State<PosterDetailScreen> createState() => _PosterDetailScreenState();
}

class _PosterDetailScreenState extends State<PosterDetailScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final isNetwork = widget.posterUrl.startsWith('http');
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 91, 91, 91),
      body: Stack(
        children: [
          Positioned.fill(
            child: isNetwork
                ? Image.network(widget.posterUrl, fit: BoxFit.cover)
                : Image.file(File(widget.posterUrl), fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color.fromARGB(255, 118, 118, 118).withOpacity(0.7),
                      const Color.fromARGB(255, 127, 127, 127).withOpacity(0.9),
                      const Color(0xFF101112),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(top: 32, bottom: _isEditing ? 100 : 65),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                  border: _isEditing
                      ? Border.all(color: Colors.white54, width: 1)
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_isEditing ? 0 : 8),
                  child: isNetwork
                      ? Image.network(
                          widget.posterUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        )
                      : Image.file(
                          File(widget.posterUrl),
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _isEditing
                    ? [
                        TextButton(
                          onPressed: () => setState(() => _isEditing = false),
                          child: const Text(
                            "Exit",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.undo, color: Colors.white, size: 20),
                            SizedBox(width: 20),
                            Icon(Icons.redo, color: Colors.white, size: 20),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.check,
                            color: Color(0xFFFFD21E),
                          ),
                          onPressed: () => setState(() => _isEditing = false),
                        ),
                      ]
                    : [
                        CircleAvatar(
                          backgroundColor: Colors.black26,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                if (isNetwork) {
                                  Share.share(widget.posterUrl);
                                } else {
                                  await Share.shareXFiles([
                                    XFile(widget.posterUrl),
                                  ]);
                                }
                              },
                              icon: const Icon(
                                Icons.share_outlined,
                                color: Color(0xFFFFD21E),
                              ),
                            ),

                            const SizedBox(width: 10),

                            IconButton(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: const Color(0xFF1A1C1E),
                                      title: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: const Text(
                                        "Do you want to delete this image?",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          child: const Text("Cancel"),
                                        ),

                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: Color(0xFFFFD21E),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirm == true) {
                                  if (!isNetwork) {
                                    final file = File(widget.posterUrl);

                                    if (await file.exists()) {
                                      await file.delete();
                                    }
                                  }

                                  await libraryService.removeLibraryImage(
                                    widget.posterUrl,
                                  );

                                  if (!context.mounted) return;

                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Deleted successfully"),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFFFFD21E),
                              ),
                            ),
                          ],
                        ),
                      ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MainActionsToolbar(
              showAddButton: widget.showAddButton,
              onEditPressed: () async {
                try {
                  if (isNetwork) {
                    await openImageEditor(
                      context: context,
                      imageUrl: widget.posterUrl,
                      onComplete: (path) async {
                        await libraryService.addEditedImage(path);

                        debugPrint(path);
                      },
                    );
                  } else {
                    final file = File(widget.posterUrl);

                    if (!await file.exists()) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('File not found')),
                      );

                      return;
                    }

                    final bytes = await file.readAsBytes();

                    await openImageEditorFromBytes(
                      context: context,
                      bytes: bytes,
                      onComplete: (path) async {
                        await libraryService.addEditedImage(path);

                        debugPrint('Edited local: $path');
                      },
                    );
                  }
                } catch (e) {
                  debugPrint('Edit error: $e');

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Editing failed')),
                  );
                }
              },

              onSavedPressed: () async {
                try {
                  if (editedBytes != null) {
                    final path = await libraryService.saveImage(editedBytes!);
                    await libraryService.addToLibrary(path);
                    await libraryService.addEditedImage(path);
                  } else if (isNetwork) {
                    await libraryService.addToLibrary(widget.posterUrl);
                  } else {
                    await libraryService.addToLibrary(widget.posterUrl);
                  }

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Added to library")),
                  );
                } catch (e) {
                  debugPrint('Add to library failed: $e');
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to add to library")),
                  );
                }
              },

              onDownloadPressed: () async {
                try {
                  await Permission.storage.request();
                  await Permission.photos.request();

                  Uint8List bytes;

                  if (editedBytes != null) {
                    bytes = editedBytes!;
                  } else if (isNetwork) {
                    final response = await http.get(
                      Uri.parse(widget.posterUrl),
                    );

                    bytes = response.bodyBytes;
                  } else {
                    final file = File(widget.posterUrl);

                    bytes = await file.readAsBytes();
                  }

                  await ImageGallerySaverPlus.saveImage(
                    bytes,
                    quality: 100,
                    name: "poster_${DateTime.now().millisecondsSinceEpoch}",
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Saved to gallery")),
                  );
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

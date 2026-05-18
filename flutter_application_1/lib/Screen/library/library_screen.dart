import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_application_1/models/movie.dart';
import 'package:flutter_application_1/services/library_service.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:flutter_application_1/Screen/movie/movie_detail.dart';
import 'package:flutter_application_1/Screen/TV_show/TV_Show_detail.dart';
import 'package:flutter_application_1/Screen/widgets/poster_detail.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryService _libraryService = LibraryService();

  List<Movie> movies = [];
  List<String> images = [];
  List<String> editedImages = [];
  bool isLoading = true;
  bool isSelectMode = false;
  Set<int> selectedIds = {};
  int selectedTab = 0;
  @override
  void initState() {
    super.initState();

    loadLibrary();
  }

  Future<void> loadLibrary() async {
    final imageResult = await _libraryService.getLibraryImages();
    final editedResult = await _libraryService.getEditedImages();

    debugPrint(
      'LibraryScreen: loadLibrary images=${imageResult.length} edited=${editedResult.length}',
    );

    setState(() {
      images = imageResult;
      editedImages = editedResult;

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            const SizedBox(height: 16),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFD21E),
                      ),
                    )
                  : (selectedTab == 0
                        ? (movies.isEmpty && images.isEmpty)
                        : (movies.isEmpty && editedImages.isEmpty))
                  ? buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: selectedTab == 0
                          ? movies.length + images.length
                          : movies.length + editedImages.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.58,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                          ),
                      itemBuilder: (context, index) {
                        final currentImages = selectedTab == 0
                            ? images
                            : editedImages;

                        if (index < currentImages.length) {
                          final imagePath = currentImages[index];
                          final isNetwork = imagePath.startsWith('http');

                          return GestureDetector(
                            onLongPress: () {
                              setState(() {
                                isSelectMode = true;
                                selectedIds.add(index);
                              });
                            },

                            onTap: () {
                              if (isSelectMode) {
                                setState(() {
                                  if (selectedIds.contains(index)) {
                                    selectedIds.remove(index);

                                    if (selectedIds.isEmpty) {
                                      isSelectMode = false;
                                    }
                                  } else {
                                    selectedIds.add(index);
                                  }
                                });

                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PosterDetailScreen(
                                    posterUrl: imagePath,
                                    showAddButton: false,
                                  ),
                                ),
                              );
                            },

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border:
                                                (isSelectMode &&
                                                    selectedIds.contains(index))
                                                ? Border.all(
                                                    color: const Color(
                                                      0xFFFFD700,
                                                    ),
                                                    width: 3,
                                                  )
                                                : null,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              9,
                                            ),
                                            child: isNetwork
                                                ? Image.network(
                                                    imagePath,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.file(
                                                    File(imagePath),
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      if (isSelectMode &&
                                          selectedIds.contains(index))
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black45,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 8),

                                const SizedBox.shrink(),
                              ],
                            ),
                          );
                        }

                        final movie = movies[index - currentImages.length];

                        return GestureDetector(
                          onTap: () {
                            if (movie.mediaType == 'movie') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MovieDetailScreen(movieId: movie.id),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TVShowDetailScreen(tvShowId: movie.id),
                                ),
                              );
                            }
                          },

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),

                                        child: Image.network(
                                          movie.posterUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                movie.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.video_library_outlined, size: 80, color: Colors.white24),

          SizedBox(height: 16),

          Text(
            'Your library is empty',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Movies and TV shows you save\nwill appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isSelectMode
              ? TextButton(
                  onPressed: () {
                    setState(() {
                      isSelectMode = false;
                      selectedIds.clear();
                    });
                  },
                  child: const Text(
                    "Exit",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton(context, "Recents", index: 0),
                      const SizedBox(width: 8),
                      _buildTabButton(context, "Edited", index: 1),
                    ],
                  ),
                ),
          Row(
            children: [
              if (isSelectMode) ...[
                IconButton(
                  onPressed: selectedIds.isNotEmpty
                      ? () async {
                          try {
                            await Permission.storage.request();
                            await Permission.photos.request();

                            for (final index in selectedIds) {
                              final imagePath = images[index];

                              Uint8List bytes;

                              if (imagePath.startsWith('http')) {
                                final resp = await http.get(
                                  Uri.parse(imagePath),
                                );
                                bytes = resp.bodyBytes;
                              } else {
                                bytes = await File(imagePath).readAsBytes();
                              }

                              await ImageGallerySaverPlus.saveImage(
                                bytes,
                                quality: 100,
                                name:
                                    "poster_${DateTime.now().millisecondsSinceEpoch}",
                              );
                            }

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Saved to gallery")),
                            );
                          } catch (e) {
                            debugPrint(e.toString());
                          }
                        }
                      : null,
                  icon: const Icon(Icons.download, color: Color(0xFFFFD700)),
                ),

                IconButton(
                  onPressed: selectedIds.isNotEmpty
                      ? () async {
                          final shouldRemove = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color.fromARGB(
                                255,
                                81,
                                81,
                                81,
                              ),
                              title: const Text(
                                'Remove from library?',
                                style: TextStyle(color: Colors.white),
                              ),
                              actions: [
                                ElevatedButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey,
                                  ),
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFD700),
                                  ),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          );

                          if (shouldRemove == true) {
                            for (final index in selectedIds) {
                              if (selectedTab == 0) {
                                await _libraryService.removeLibraryImage(
                                  images[index],
                                );
                              } else {
                                await _libraryService.removeEditedImage(
                                  editedImages[index],
                                );
                              }
                            }

                            await loadLibrary();

                            setState(() {
                              selectedIds.clear();
                              isSelectMode = false;
                            });
                          }
                        }
                      : null,
                  icon: Icon(
                    Icons.delete,
                    color: selectedIds.isNotEmpty
                        ? const Color(0xFFFFD700)
                        : const Color(0xFFFFD700),
                  ),
                ),
              ],

              if (!isSelectMode)
                TextButton(
                  onPressed: () {
                    setState(() {
                      isSelectMode = true;
                      selectedIds.clear();
                    });
                  },
                  child: const Text(
                    "Select",
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    String label, {
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
        loadLibrary();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: index == selectedTab
              ? const Color(0xFFFFD700)
              : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: index == selectedTab ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

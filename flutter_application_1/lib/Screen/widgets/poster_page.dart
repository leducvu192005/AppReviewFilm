import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/movie_service.dart';
import 'package:flutter_application_1/models/movie.dart';
import 'package:flutter_application_1/Screen/widgets/poster_detail.dart';
import 'package:flutter_application_1/services/library_service.dart';
import 'package:flutter_application_1/layout.dart';

enum MediaType { movie, tv }

class PosterScreen extends StatefulWidget {
  final int id;
  final MediaType type;

  const PosterScreen({super.key, required this.id, required this.type});

  @override
  State<PosterScreen> createState() => _PosterScreenState();
}

class _PosterScreenState extends State<PosterScreen> {
  final MovieService _movieService = MovieService();
  final LibraryService _libraryService = LibraryService();
  late Future<List<String>> _postersFuture;
  late Future<Movie> _mediaFuture;
  Set<int> _savedIndexes = {};
  @override
  void initState() {
    super.initState();

    if (widget.type == MediaType.movie) {
      _postersFuture = _movieService.fetchMoviePosters(widget.id);
      _mediaFuture = _movieService.fetchMovieDetails(widget.id);
    } else {
      _postersFuture = _movieService.fetchPosterTVShow(widget.id);
      _mediaFuture = _movieService.fetchTVShowDetails(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),

          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          'Posters',

          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      body: FutureBuilder<List<String>>(
        future: _postersFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD21E)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'No posters found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final posters = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 2 / 3,
            ),

            itemCount: posters.length,

            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PosterDetailScreen(
                        posterUrl: posters[index],
                        showAddButton: true,
                      ),
                    ),
                  );
                },

                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),

                        child: Image.network(posters[index], fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            _savedIndexes.contains(index)
                                ? Icons.check_circle
                                : Icons.add_circle,
                            color: const Color(0xFFFFD21E),
                            size: 18,
                          ),
                          onPressed: () async {
                            try {
                              final isSaved = _savedIndexes.contains(index);

                              final imageUrl = posters[index];

                              await _libraryService.addToLibrary(imageUrl);

                              setState(() {
                                if (isSaved) {
                                  _savedIndexes.remove(index);
                                } else {
                                  _savedIndexes.add(index);
                                }
                              });

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(
                                    0xFF4E4E4E,
                                  ).withOpacity(0.9),
                                  behavior: SnackBarBehavior.floating,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                  content: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          isSaved
                                              ? 'Removed from your library'
                                              : 'Added to your library',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).hideCurrentSnackBar();

                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const Layout(initialIndex: 2),
                                            ),
                                            (route) => false,
                                          );
                                        },
                                        child: const Text(
                                          'Go to Library',
                                          style: TextStyle(
                                            color: Color(0xFFFFD21E),
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        constraints: const BoxConstraints(
                                          maxWidth: 30,
                                        ),
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white70,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).hideCurrentSnackBar();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } catch (e) {
                              print(e);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

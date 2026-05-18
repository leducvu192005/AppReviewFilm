import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screen/TV_show/TV_Show_detail.dart';
import 'package:flutter_application_1/Screen/movie/movie_detail.dart';
import '../../models/movie.dart';
import '../../services/favorite_service.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen>
    with SingleTickerProviderStateMixin {
  final FavoriteService movieService = FavoriteService();

  List<Movie> favoriteMovies = [];
  List<Movie> favoriteTVShows = [];

  bool isSelectMode = false;
  Set<int> selectedIds = {};

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final favorites = await movieService.getFavorites();
    if (mounted) {
      setState(() {
        favoriteMovies = favorites
            .where((m) => m.mediaType == 'movie')
            .toList();
        favoriteTVShows = favorites.where((m) => m.mediaType == 'tv').toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2C322E), Color(0xFF121413)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Builder(builder: (innerContext) => _buildHeader(innerContext)),
                Expanded(
                  child: TabBarView(
                    children: [
                      buildMovieGrid(favoriteMovies, isMovie: true),
                      buildMovieGrid(favoriteTVShows, isMovie: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
                      _buildTabButton(context, "Movies", index: 0),
                      const SizedBox(width: 8),
                      _buildTabButton(context, "TV Shows", index: 1),
                    ],
                  ),
                ),
          Row(
            children: [
              if (isSelectMode)
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
                                'Remove from favorites?',
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
                            await movieService.deleteFavorites(
                              selectedIds.toList(),
                            );
                            await loadFavorites();
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
    final controller = DefaultTabController.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final isActive = controller.index == index;
        return GestureDetector(
          onTap: () => controller.animateTo(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFFD700) : Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.white10,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildMovieGrid(List<Movie> movies, {required bool isMovie}) {
    if (movies.isEmpty) {
      return const Center(
        child: Text("No favorites", style: TextStyle(color: Colors.white60)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: movies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.58,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final movie = movies[index];

        return GestureDetector(
          onTap: () {
            if (isSelectMode) {
              setState(() {
                if (selectedIds.contains(movie.id)) {
                  selectedIds.remove(movie.id);
                } else {
                  selectedIds.add(movie.id);
                }
              });
              return;
            }

            if (isMovie) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetailScreen(movieId: movie.id),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TVShowDetailScreen(tvShowId: movie.id),
                ),
              );
            }
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          movie.localPosterPath != null &&
                              movie.localPosterPath!.isNotEmpty
                          ? Image.file(
                              File(movie.localPosterPath!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Image.network(
                              movie.posterUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (ctx, err, stack) => Container(
                                color: Colors.white10,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.white24,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    height: 66,
                    width: 123,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 124, 122, 122),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          movie.releaseDate.isNotEmpty
                              ? movie.releaseDate
                              : "Unknown",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isSelectMode)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedIds.contains(movie.id)
                          ? Colors.black54
                          : Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedIds.contains(movie.id)
                            ? Colors.yellow
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

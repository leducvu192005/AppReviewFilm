import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screen/widgets/tvshow_card.dart';
import 'package:flutter_application_1/models/movie.dart';
import 'package:flutter_application_1/services/movie_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'poster_tv.dart';
import 'package:url_launcher/url_launcher.dart';

class TVShowDetailScreen extends StatefulWidget {
  final int tvShowId;

  const TVShowDetailScreen({super.key, required this.tvShowId});

  @override
  State<TVShowDetailScreen> createState() => _TVShowDetailScreenState();
}

class _TVShowDetailScreenState extends State<TVShowDetailScreen> {
  final MovieService _movieService = MovieService();

  late Future<Movie> _movieFuture;
  late Future<List<dynamic>> _castFuture;
  late Future<List<String>> _posterFuture;
  late Future<List<Movie>> _similarFuture;
  late Future<List<dynamic>> _seasonsFuture;

  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();

    _movieFuture = _movieService.fetchTVShowDetails(widget.tvShowId);

    _castFuture = _movieService.fetchTVShowCast(widget.tvShowId);

    _seasonsFuture = _movieService.fetchAllSeason(widget.tvShowId);
    _posterFuture = _movieService.fetchPosterTVShow(widget.tvShowId);
    _similarFuture = _movieService.fetchSimilarTVShows(widget.tvShowId);
    _checkIfFavorite();
  }

  Future<void> _playTrailer(int movieId) async {
    final movieService = MovieService();
    final trailerKey = await movieService.getYoutubeTrailerKey(movieId);

    if (trailerKey != null) {
      final Uri url = Uri.parse('https://www.youtube.com/watch?v=$trailerKey');

      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch trailer');
      } else {
        debugPrint('No trailer found for this movie');
      }
    }
  }

  Future<void> _checkIfFavorite() async {
    final favorites = await FavoriteService.getFavorites();

    setState(() {
      _isFavorite = favorites.contains(widget.tvShowId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111315),

      body: FutureBuilder<Movie>(
        future: _movieFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD21E)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final movie = snapshot.data!;

          final year = movie.releaseDate.isNotEmpty
              ? movie.releaseDate.split('-')[0]
              : '';

          return Stack(
            children: [
              SizedBox(
                height: 320,
                width: double.infinity,

                child: Image.network(movie.backdropUrl, fit: BoxFit.cover),
              ),

              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,

                    colors: [
                      Colors.transparent,
                      Color(0xCC111315),
                      Color(0xFF111315),
                    ],

                    stops: [0.2, 0.55, 0.8],
                  ),
                ),
              ),

              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),

                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                _circleButton(
                                  icon: Icons.arrow_back_ios_new,
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),

                                _circleButton(
                                  icon: _isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,

                                  onTap: () async {
                                    setState(() {
                                      _isFavorite = !_isFavorite;
                                    });

                                    await FavoriteService.toggleFavorite(
                                      movie.id,
                                    );
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 110),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),

                                  child: Image.network(
                                    movie.posterUrl,
                                    width: 110,
                                    height: 165,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      const SizedBox(height: 20),

                                      Text(
                                        movie.title,

                                        style: const TextStyle(
                                          color: Colors.white,

                                          fontSize: 28,

                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Text(
                                        '$year  |  Drama  |  ${movie.runtime ?? 0}m',

                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: .55,
                                          ),

                                          fontSize: 12,
                                        ),
                                      ),

                                      const SizedBox(height: 22),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () =>
                                                  _playTrailer(widget.tvShowId),

                                              icon: const Icon(
                                                Icons.play_arrow_rounded,

                                                color: Colors.white,
                                              ),

                                              label: const Text(
                                                'Play Trailer',

                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              /*Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _playTrailer(widget.movieId),
            icon: const Icon(Icons.play_circle_outline, color: Colors.white),
            label: const Text(
              'Play Trailer',
              style: TextStyle(color: Colors.white),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(88),
              ),
            ),
          ),*/
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color: Colors.white
                                                      .withValues(alpha: .2),
                                                ),

                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),

                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,

                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PosterTv(
                                                          tvShowId:
                                                              widget.tvShowId,
                                                        ),
                                                  ),
                                                );
                                              },

                                              icon: const Icon(
                                                Icons.image_outlined,

                                                color: Color(0xFF1D1D1D),
                                              ),

                                              label: const Text(
                                                'Posters',

                                                style: TextStyle(
                                                  color: Color(0xFF1D1D1D),
                                                ),
                                              ),

                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFFFFD21E,
                                                ),

                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),

                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 26),

                            const Text(
                              'Overview',

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              movie.overview,

                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .7),

                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: 28),

                            const Text(
                              'Cast',

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 8),

                            _buildCastList(),

                            const SizedBox(height: 24),
                            const Text(
                              'Seasons',

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildSeasonList(),
                            const Text(
                              'Similar',

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildSimilarMovies(),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 42,
      height: 42,

      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .35),
        shape: BoxShape.circle,
      ),

      child: IconButton(
        onPressed: onTap,

        icon: Icon(icon, size: 18, color: const Color(0xFFFFD21E)),
      ),
    );
  }

  Widget _buildSeasonList() {
    return FutureBuilder<List<dynamic>>(
      future: _movieService.fetchAllSeason(widget.tvShowId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final seasons = snapshot.data!;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TVShowDetailScreen(tvShowId: widget.tvShowId),
              ),
            );
          },
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: seasons.length,
            itemBuilder: (context, index) {
              final season = seasons[index];
              final String airDate = season['air_date'] ?? '';
              final String year = airDate.isNotEmpty
                  ? airDate.split('-')[0]
                  : '';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w300${season['poster_path']}',
                        width: 110,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 110,
                          height: 160,
                          color: Colors.grey[900],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            season['name'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$year | ${season['episode_count']} Episodes',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            season['overview'] != null &&
                                    season['overview'].toString().isNotEmpty
                                ? season['overview']
                                : 'Season ${season['season_number']} of the series premiered on $airDate.',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCastList() {
    return FutureBuilder<List<dynamic>>(
      future: _castFuture,

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 120);
        }

        final cast = snapshot.data!;

        return SizedBox(
          height: 140,

          child: ListView.separated(
            scrollDirection: Axis.horizontal,

            itemCount: cast.length > 10 ? 10 : cast.length,

            separatorBuilder: (context, index) => const SizedBox(width: 18),

            itemBuilder: (context, index) {
              final person = cast[index];

              final profile = person['profile_path'];

              return SizedBox(
                width: 100,

                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,

                      backgroundColor: Colors.grey.shade800,

                      backgroundImage: profile != null
                          ? NetworkImage(
                              'https://image.tmdb.org/t/p/w185$profile',
                            )
                          : null,

                      child: profile == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      person['name'] ?? '',

                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .8),

                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSimilarMovies() {
    return FutureBuilder<List<Movie>>(
      future: _similarFuture,

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 200);
        }

        final movies = snapshot.data!;

        return SizedBox(
          height: 200,

          child: ListView.separated(
            scrollDirection: Axis.horizontal,

            itemCount: movies.length,

            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final movie = movies[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TVShowDetailScreen(
                        key: ValueKey(movie.id),
                        tvShowId: movie.id,
                      ),
                    ),
                  );
                },
                child: AbsorbPointer(
                  child: TvshowCard(movie: movie, width: 120, height: 180),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class FavoriteService {
  static const String _key = 'favorite_movies';

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> toggleFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> favorites = prefs.getStringList(_key) ?? [];

    String id = movieId.toString();

    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }

    await prefs.setStringList(_key, favorites);
  }
}

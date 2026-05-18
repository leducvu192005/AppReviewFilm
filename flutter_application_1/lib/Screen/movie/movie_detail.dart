import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screen/widgets/poster_page.dart';
import 'package:flutter_application_1/models/movie.dart';
import 'package:flutter_application_1/services/movie_service.dart';
import 'package:flutter_application_1/services/favorite_service.dart';
import 'package:flutter_application_1/Screen/widgets/movie_card.dart';
import 'package:flutter_svg/svg.dart';
import "package:url_launcher/url_launcher.dart";

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieService _movieService = MovieService();
  late Future<Movie> _movieFuture;
  late Future<List<dynamic>> _castFuture;
  late Future<List<Movie>> _similarFuture;
  List<Movie> movies = [];
  @override
  void initState() {
    super.initState();
    _movieFuture = _movieService.fetchMovieDetails(widget.movieId);
    _castFuture = _movieService.fetchMovieCast(widget.movieId);
    _similarFuture = _movieService.fetchSimilarMovies(widget.movieId);
    _checkIfFavorite(widget.movieId);
  }

  final FavoriteService _favoriteService = FavoriteService();
  bool _favoriteChecked = false;

  Future<void> _checkIfFavorite(int id) async {
    final fav = await _favoriteService.isFavorite(id);
    if (mounted) {
      setState(() {
        _isFavorite = fav;
        _favoriteChecked = true;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
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
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final movie = snapshot.data!;
          final year = movie.releaseDate.isNotEmpty
              ? movie.releaseDate.split('-')[0]
              : 'N/A';
          final genres = movie.genres?.join(', ') ?? 'N/A';
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 400,
                child: Image.network(movie.backdropUrl, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        const Color(0xFF0F1012).withValues(alpha: 0.8),
                        const Color.fromARGB(255, 35, 36, 36),
                      ],
                      stops: const [0.0, 0.4, 0.7],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildAppBar(context, movie),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderInfo(movie, year, genres),
                            const SizedBox(height: 16),
                            _buildActionButtons(),
                            const SizedBox(height: 20),
                            _buildSectionTitle('Overview'),
                            const SizedBox(height: 12),
                            _buildOverview(movie.overview),
                            const SizedBox(height: 32),
                            _buildSectionTitle('Cast'),
                            const SizedBox(height: 16),
                            _buildCastList(),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Similar'),
                            const SizedBox(height: 8),
                            _buildSimilarMovies(),
                            const SizedBox(height: 40),
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

  bool _isFavorite = false;
  Widget _buildAppBar(BuildContext context, Movie movie) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 18),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.5),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 18),
          child: CircleAvatar(
            backgroundColor: Colors.black.withValues(alpha: 0.5),
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: const Color(0xFFFFD21E),
                size: 20,
              ),
              onPressed: () async {
                setState(() {
                  _isFavorite = !_isFavorite;
                });

                await _favoriteService.toggleFavorite(movie);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderInfo(Movie movie, String year, String genres) {
    final runtimeText = movie.runtimeFormatted.isNotEmpty
        ? movie.runtimeFormatted
        : '${movie.runtime}m';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            movie.posterUrl,
            width: 120,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 62),
              Text(
                '${movie.title} ($year)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${movie.releaseDate}  |  $genres  |  $runtimeText',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
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
          ),
        ),

        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PosterScreen(id: widget.movieId, type: MediaType.movie),
                ),
              );
            },
            icon: SvgPicture.asset(
              'assets/icons/image-01.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFFFFD21E),
                BlendMode.srcIn,
              ),
            ),
            label: const Text(
              'Posters',
              style: TextStyle(
                color: Color(0xFFFFD21E),
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: const BorderSide(color: Color(0xFFFFD21E), width: 1),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(88),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildOverview(String overview) {
    return Text(
      overview,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  Widget _buildCastList() {
    return FutureBuilder<List<dynamic>>(
      future: _castFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 100);
        final cast = snapshot.data!;
        return SizedBox(
          height: 116,
          width: 560,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length > 10 ? 10 : cast.length,
            separatorBuilder: (context, index) => const SizedBox(width: 62),
            itemBuilder: (context, index) {
              final person = cast[index];
              final profilePath = person['profile_path'];
              return Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: profilePath != null
                        ? NetworkImage(
                            'https://image.tmdb.org/t/p/w185$profilePath',
                          )
                        : null,
                    child: profilePath == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 80,
                    height: 28,
                    child: Text(
                      person['name'] ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
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
        if (!snapshot.hasData) return const SizedBox(height: 206);
        final movies = snapshot.data!;
        return SizedBox(
          height: 234,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) => MovieCard(
              movie: movies[index],
              width: 120,
              height: 180,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MovieDetailScreen(movieId: movies[index].id),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

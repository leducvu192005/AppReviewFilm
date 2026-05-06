import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screen/poster_page.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import 'widgets/movie_card.dart';

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

  @override
  void initState() {
    super.initState();
    // Gọi API lấy chi tiết phim, cast và phim tương tự
    _movieFuture = _movieService.fetchMovieDetails(widget.movieId);
    _castFuture = _movieService.fetchMovieCast(widget.movieId);
    _similarFuture = _movieService.fetchSimilarMovies(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012), // Màu xám đen chuẩn thiết kế
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
              // 1. Backdrop Image & Gradient
              Positioned.fill(
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
                        const Color(0xFF0F1012),
                      ],
                      stops: const [0.0, 0.4, 0.7],
                    ),
                  ),
                ),
              ),

              // 2. Nội dung chi tiết
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildAppBar(context),
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

  Widget _buildAppBar(BuildContext context) {
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
            child: const Icon(Icons.favorite_border, color: Color(0xFFFFD21E)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderInfo(Movie movie, String year, String genres) {
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
                '${movie.releaseDate}  |  $genres  |  ${movie.runtime ?? 0}m',
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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PosterScreen(movieId: widget.movieId),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
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
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.image_outlined, color: Color(0xFF1D1D1D)),
              label: const Text(
                'Posters',
                style: TextStyle(color: Color(0xFF1D1D1D)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFFFFD21E,
                ), // Màu vàng thương hiệu
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(88),
                ),
              ),
            ),
          ),
        ],
      ),
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
            itemBuilder: (context, index) =>
                MovieCard(movie: movies[index], width: 120, height: 180),
          ),
        );
      },
    );
  }
}

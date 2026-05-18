import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screen/movie/movie_detail.dart';
import 'package:flutter_application_1/Screen/widgets/empty_movies.dart';
import 'package:flutter_application_1/Screen/widgets/movie_card.dart';
import 'package:flutter_application_1/Screen/widgets/poster_fallback.dart';
import 'package:flutter_application_1/models/movie.dart';

class MediaHomeContent extends StatefulWidget {
  const MediaHomeContent({super.key});

  @override
  State<MediaHomeContent> createState() => _MediaHomeContentState();
}

class _MediaHomeContentState extends State<MediaHomeContent> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class FeaturedMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const FeaturedMovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              movie.backdropUrl,
              width: 288,
              height: 162,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            movie.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          if (movie.mediaType == 'tv' && (movie.seasonCount ?? 0) > 0) ...[
            Text(
              movie.releaseDate,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .6),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Season ${movie.seasonCount}${movie.episodeCount != null && movie.episodeCount! > 0 ? '  |  ${movie.episodeCount} Episodes' : ''}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .6),
                fontSize: 11,
              ),
            ),
          ] else ...[
            Text(
              movie.runtimeFormatted.isNotEmpty
                  ? '${movie.releaseDate}  |  ${movie.runtimeFormatted}'
                  : movie.releaseDate,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .6),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.showViewAll = false,
    this.onViewAll,
  });

  final String title;
  final bool showViewAll;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (showViewAll)
          GestureDetector(
            onTap: onViewAll,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'View all',
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: onViewAll == null ? .35 : .68,
                  ),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class FeaturedPoster extends StatelessWidget {
  const FeaturedPoster({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        movie.backdropUrl.isEmpty ? movie.posterUrl : movie.backdropUrl,
        width: 228,
        height: 140,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const PosterFallback(width: 228, height: 140),
      ),
    );
  }
}

class SidePoster extends StatelessWidget {
  const SidePoster({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Opacity(
        opacity: .72,
        child: Image.network(
          movie.posterUrl,
          width: 74,
          height: 104,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const PosterFallback(width: 74, height: 104),
        ),
      ),
    );
  }
}

class MovieShelf extends StatelessWidget {
  const MovieShelf({
    super.key,
    required this.title,
    required this.movies,
    this.isLoading = false,
    this.showViewAll = true,
    this.onViewAll,
    this.onTapMovie,
  });

  final String title;
  final List<Movie> movies;
  final bool isLoading;
  final bool showViewAll;
  final VoidCallback? onViewAll;
  final Function(Movie)? onTapMovie;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: title,
          showViewAll: showViewAll,
          onViewAll: onViewAll,
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const SizedBox(
            height: 96,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD21E)),
            ),
          )
        else if (movies.isEmpty)
          const EmptyMovies()
        else
          SizedBox(
            height: 251,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: movies.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final movie = movies[index];

                return MovieCard(
                  movie: movie,
                  rank: index + 1,
                  onTap: () {
                    if (onTapMovie != null) {
                      onTapMovie!(movie);
                    }
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class FeaturedCarousel extends StatelessWidget {
  const FeaturedCarousel({super.key, required this.movies});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const EmptyMovies();

    final featured = movies.first;

    final String infoLine =
        (featured.mediaType == 'tv' && (featured.seasonCount ?? 0) > 0)
        ? '${featured.releaseDate}  •  Season ${featured.seasonCount}${featured.episodeCount != null && featured.episodeCount! > 0 ? '  |  ${featured.episodeCount} Episodes' : ''}'
        : (featured.runtimeFormatted.isNotEmpty
              ? '${featured.releaseDate}  |  ${featured.runtimeFormatted}'
              : featured.releaseDate);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: -40,
                child: SidePoster(movie: movies[movies.length > 1 ? 1 : 0]),
              ),
              Positioned(
                right: -40,
                child: SidePoster(movie: movies[movies.length > 2 ? 2 : 0]),
              ),
              FeaturedPoster(movie: featured),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          featured.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          infoLine,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .55),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => Icon(
              index < featured.voteAverage.round() ~/ 2
                  ? Icons.star
                  : Icons.star_border,
              color: const Color(0xFFFFD21E),
              size: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class Movieupcoming extends StatelessWidget {
  const Movieupcoming({
    super.key,
    required this.title,
    required this.movies,
    this.isLoading = false,
    this.showViewAll = true,
    this.onViewAll,
  });

  final String title;
  final List<Movie> movies;
  final bool isLoading;
  final bool showViewAll;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: title,
          showViewAll: showViewAll,
          onViewAll: onViewAll,
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const SizedBox(
            height: 96,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD21E)),
            ),
          )
        else if (movies.isEmpty)
          const EmptyMovies()
        else
          SizedBox(
            height: 251,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: movies.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) => MovieCard(
                movie: movies[index],
                rank: index < 0 ? index + 1 : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MovieDetailScreen(movieId: movies[index].id),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

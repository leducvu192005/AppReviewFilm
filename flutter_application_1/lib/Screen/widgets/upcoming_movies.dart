import 'package:flutter/material.dart';

import 'package:flutter_application_1/models/movie.dart';
import 'package:flutter_application_1/Screen/widgets/empty_movies.dart';

class UpComingMoviesPage extends StatelessWidget {
  const UpComingMoviesPage({super.key, required this.movies});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8A6B4C),
              Color(0xFF624435),
              Color(0xFF221A18),
              Color(0xFF070708),
            ],
            stops: [0, .22, .52, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const _UpComingHeader(),
              Expanded(
                child: movies.isEmpty
                    ? const EmptyMovies()
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                        physics: const BouncingScrollPhysics(),
                        itemCount: movies.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: .62,
                            ),
                        itemBuilder: (context, index) =>
                            _UpComingMovieTile(movie: movies[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpComingHeader extends StatelessWidget {
  const _UpComingHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(width: 32),
              Text(
                '9:41',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              Icon(Icons.signal_cellular_alt, color: Colors.white, size: 16),
              SizedBox(width: 5),
              Icon(Icons.wifi, color: Colors.white, size: 16),
              SizedBox(width: 5),
              Icon(Icons.battery_full, color: Colors.white, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const Text(
                'Up Coming Movies',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpComingMovieTile extends StatelessWidget {
  const _UpComingMovieTile({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFF3A3537)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                movie.posterUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.white.withValues(alpha: .12),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white70,
                    size: 24,
                  ),
                ),
              ),
            ),
            Container(
              height: 48,
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 6),
              color: const Color(0xFF5A4A45),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    movie.releaseDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .55),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

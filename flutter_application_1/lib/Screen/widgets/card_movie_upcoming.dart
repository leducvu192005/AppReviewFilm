import 'package:flutter/material.dart';
import '../movie/movie_detail.dart';
import '../../models/movie.dart';

class CardMovieUpcoming extends StatelessWidget {
  const CardMovieUpcoming({
    super.key,
    required this.movie,
    this.rank,
    this.width = 120,
    this.height = 180,
  });

  final Movie movie;
  final int? rank;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MovieDetailScreen(movieId: movie.id),
        ),
      ),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    movie.posterUrl,
                    width: width,
                    height: height - 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: width,
                        height: height - 50,
                        color: Colors.grey,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                if (rank != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD21E),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        '#$rank',
                        style: const TextStyle(
                          color: Color(0xFF1D1D1D),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              movie.releaseDate,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

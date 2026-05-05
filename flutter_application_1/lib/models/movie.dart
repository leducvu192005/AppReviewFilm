class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.overview,
    required this.releaseDate,
    required this.runtime,
    required this.voteAverage,
  });

  final int id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final String overview;
  final String releaseDate;
  final int runtime;
  final double voteAverage;

  factory Movie.fromJson(Map<String, dynamic> json) {
    const imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
    final posterPath = json['poster_path'] as String?;
    final backdropPath = json['backdrop_path'] as String?;

    return Movie(
      id: json['id'] as int? ?? 0,
      title:
          json['title'] as String? ??
          json['name'] as String? ??
          'Untitled movie',
      posterUrl: posterPath == null ? '' : '$imageBaseUrl$posterPath',
      backdropUrl: backdropPath == null ? '' : '$imageBaseUrl$backdropPath',
      overview: json['overview'] as String? ?? '',
      releaseDate:
          json['release_date'] as String? ??
          json['first_air_date'] as String? ??
          'Coming soon',
      runtime: json['runtime'] as int? ?? 120,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
    );
  }
}

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
    required this.mediaType,
    this.seasonCount,
    this.episodeCount,
    this.genres,
    this.localPosterPath,
    this.localBackdropPath,
  });

  final int id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final String overview;
  final String releaseDate;
  final int runtime;
  final double voteAverage;
  final String? mediaType;
  final int? seasonCount;
  final int? episodeCount;
  final List<String>? genres;
  final String? localPosterPath;
  final String? localBackdropPath;

  String get runtimeFormatted {
    if (runtime <= 0) return '';

    final int hours = runtime ~/ 60;
    final int minutes = runtime % 60;

    if (hours > 0) {
      if (minutes > 0) return '${hours}h${minutes}m';
      return '${hours}h';
    }

    return '${minutes}m';
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    const posterBaseUrl = 'https://image.tmdb.org/t/p/w500';
    const backdropBaseUrl = 'https://image.tmdb.org/t/p/w1280';
    final posterPath = json['poster_path'] as String?;
    final backdropPath = json['backdrop_path'] as String?;

    String resolvePoster(Map<String, dynamic> j) {
      final p1 = j['posterUrl'] as String? ?? j['poster_url'] as String?;
      if (p1 != null && p1.isNotEmpty) return p1;
      if (posterPath != null && posterPath.isNotEmpty) {
        return '$posterBaseUrl$posterPath';
      }
      return '';
    }

    String resolveBackdrop(Map<String, dynamic> j) {
      final b1 = j['backdropUrl'] as String? ?? j['backdrop_url'] as String?;
      if (b1 != null && b1.isNotEmpty) return b1;
      if (backdropPath != null && backdropPath.isNotEmpty) {
        return '$backdropBaseUrl$backdropPath';
      }
      return '';
    }

    final mediaTypeRaw = json['mediaType'] ?? json['media_type'];

    final mediaType = mediaTypeRaw?.toString().toLowerCase();
    final localPoster =
        (json['localPosterPath'] ?? json['local_poster_path']) as String?;
    final localBackdrop =
        (json['localBackdropPath'] ?? json['local_backdrop_path']) as String?;

    return Movie(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      posterUrl: resolvePoster(json),
      backdropUrl: resolveBackdrop(json),
      overview: json['overview'] as String? ?? '',
      releaseDate:
          json['releaseDate'] as String? ??
          json['release_date'] as String? ??
          json['first_air_date'] as String? ??
          '',
      runtime: () {
        final rt = json['runtime'];
        if (rt is int) return rt;

        final episodeRun =
            json['episode_run_time'] ?? json['episode_run_times'];
        if (episodeRun is List && episodeRun.isNotEmpty) {
          final first = episodeRun.first;
          if (first is int) return first;
          if (first is num) return first.toInt();
        }

        return 0;
      }(),
      voteAverage:
          (json['voteAverage'] as num?)?.toDouble() ??
          (json['vote_average'] as num?)?.toDouble() ??
          0,
      mediaType:
          mediaType ?? (json.containsKey('first_air_date') ? 'tv' : 'movie'),
      genres: (json['genres'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map((g) => g['name'] as String)
          .toList(),
      seasonCount:
          json['number_of_seasons'] as int? ?? json['seasons_count'] as int?,
      episodeCount:
          json['number_of_episodes'] as int? ?? json['episodes_count'] as int?,
      localPosterPath: localPoster,
      localBackdropPath: localBackdrop,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "posterUrl": posterUrl,
      "backdropUrl": backdropUrl,
      "overview": overview,
      "releaseDate": releaseDate,
      "runtime": runtime,
      "number_of_seasons": seasonCount,
      "number_of_episodes": episodeCount,
      "voteAverage": voteAverage,
      "mediaType": mediaType?.toLowerCase(),
      "localPosterPath": localPosterPath,
      "localBackdropPath": localBackdropPath,
    };
  }
}

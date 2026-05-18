import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  MovieService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String tmdbApiKey = 'fe23aeacfc9437a181282a055c1ce55d';

  static const _host = 'api.themoviedb.org';

  Future<HomeMovieData> fetchHomeMovies() async {
    final responses = await Future.wait([
      _get('/movie/popular'),
      _get('/movie/top_rated'),
      _get('/movie/upcoming'),
    ]);

    final popular = _parseMovieList(responses[0]);
    final topRated = _parseMovieList(responses[1]);
    final upcoming = _parseMovieList(responses[2]);

    final enrichedPopular = await _enrichMovies(popular);
    final enrichedTopRated = await _enrichMovies(topRated);
    final enrichedUpcoming = await _enrichMovies(upcoming);

    return HomeMovieData(
      popular: enrichedPopular,
      topRated: enrichedTopRated,
      upcoming: enrichedUpcoming,
    );
  }

  Future<List<Movie>> _enrichMovies(List<Movie> movies) async {
    final futures = movies.map((m) async {
      if (m.mediaType == 'movie') {
        try {
          return await fetchMovieDetails(m.id);
        } catch (_) {
          return m;
        }
      }
      return m;
    }).toList();

    return await Future.wait(futures);
  }

  Future<HomeTVShowData> fetchHomeTVShow() async {
    final responses = await Future.wait([
      _get('/tv/popular'),
      _get('/tv/top_rated'),
      _get('/tv/airing_today'),
    ]);

    final popular = _parseMovieList(responses[0]);
    final topRated = _parseMovieList(responses[1]);
    final airingToday = _parseMovieList(responses[2]);

    final enrichedPopular = await _enrichTVShows(popular);
    final enrichedTopRated = await _enrichTVShows(topRated);
    final enrichedAiring = await _enrichTVShows(airingToday);

    return HomeTVShowData(
      popular: enrichedPopular,
      topRated: enrichedTopRated,
      airingToday: enrichedAiring,
    );
  }

  Future<List<Movie>> _enrichTVShows(List<Movie> movies) async {
    final futures = movies.map((m) async {
      if (m.mediaType == 'tv') {
        try {
          return await fetchTVShowDetails(m.id);
        } catch (_) {
          return m;
        }
      }
      return m;
    }).toList();

    return await Future.wait(futures);
  }

  Future<List<Movie>> fetchSimilarTVShows(int tvShowId) async {
    try {
      final response = await _get('/tv/$tvShowId/similar');
      return _parseMovieList(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> fetchPosterTVShow(int tvShowId) async {
    try {
      final response = await _get('/tv/$tvShowId/images');

      final List<dynamic> postersJson = response['posters'] ?? [];

      const imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

      return postersJson
          .map((item) => '$imageBaseUrl${item['file_path']}')
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> fetchAllSeason(int tvShowId) async {
    final response = await _get('/tv/$tvShowId');
    return response['seasons'] as List<dynamic>? ?? [];
  }

  Future<List<dynamic>> fetchSeasonEpisodes(
    int tvShowId,
    int seasonNumber,
  ) async {
    final response = await _get('/tv/$tvShowId/season/$seasonNumber');
    return response['episodes'] as List<dynamic>? ?? [];
  }

  Future<List<dynamic>> fetchTVShowCast(int tvShowId) async {
    final response = await _get('/tv/$tvShowId/credits');
    return response['cast'] as List<dynamic>? ?? [];
  }

  Future<List<Movie>> fetchPopularNow() async {
    try {
      final response = await _get('/movie/popular');
      return _parseMovieList(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Movie>> fetchEsdipodes() async {
    try {
      final respone = await _get('/tv/season');
      return _parseMovieList(respone);
    } catch (e) {
      return [];
    }
  }

  Future<List<Movie>> searchMulti(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) return [];

    final response = await _get(
      '/search/multi',
      queryParameters: {'query': trimmedQuery, 'include_adult': 'false'},
    );

    return _parseMovieList(response);
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String> queryParameters = const {},
  }) async {
    final uri = Uri.https(_host, '/3$path', {
      'api_key': tmdbApiKey,
      'language': 'en-US',
      'page': '1',
      ...queryParameters,
    });

    final response = await _client.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MovieServiceException(
        'TMDB request failed with status ${response.statusCode}',
      );
    }

    final decodedBody = jsonDecode(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw const MovieServiceException('TMDB returned an invalid response.');
    }

    return decodedBody;
  }

  List<Movie> _parseMovieList(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where(
          (movie) =>
              movie.posterUrl.isNotEmpty &&
              (movie.mediaType == null ||
                  movie.mediaType == 'movie' ||
                  movie.mediaType == 'tv'),
        )
        .toList();
  }

  Future<Movie> fetchTVShowDetails(int tvShowId) async {
    final response = await _get('/tv/$tvShowId');
    return Movie.fromJson(response);
  }

  Future<Movie> fetchMovieDetails(int movieId) async {
    final response = await _get('/movie/$movieId');
    return Movie.fromJson(response);
  }

  Future<List<dynamic>> fetchMovieCast(int movieId) async {
    final response = await _get('/movie/$movieId/credits');
    return response['cast'] as List<dynamic>? ?? [];
  }

  Future<List<Movie>> fetchSimilarMovies(int movieId) async {
    final response = await _get('/movie/$movieId/similar');
    return _parseMovieList(response);
  }

  Future<List<Movie>> fetchMovieTrailer(int movieId) async {
    final response = await _get('/movie/$movieId/videos');

    final results = response['results'] as List<dynamic>? ?? [];

    return results
        .whereType<Map<String, dynamic>>()
        .where(
          (video) => video['site'] == 'YouTube' && video['type'] == 'Trailer',
        )
        .map(
          (video) => Movie(
            id: movieId,
            title: video['name'] as String? ?? 'Trailer',
            posterUrl: 'https://img.youtube.com/vi/${video['key']}/0.jpg',
            backdropUrl: '',
            overview: '',
            releaseDate: '',
            runtime: 0,
            voteAverage: 0,
            mediaType: 'trailer',
          ),
        )
        .toList();
  }

  Future<String?> getYoutubeTrailerKey(int movieId) async {
    final response = await _get('/movie/$movieId/videos');

    final results = response['results'] as List<dynamic>? ?? [];

    final trailer = results.firstWhere(
      (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
      orElse: () => null,
    );

    return trailer?['key'] as String?;
  }

  Future<String?> getYoutubeTVTrailerKey(int tvShowId) async {
    final response = await _get('/tv/$tvShowId/videos');

    final results = response['results'] as List<dynamic>? ?? [];

    final trailer = results.firstWhere(
      (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
      orElse: () => null,
    );

    return trailer?['key'] as String?;
  }

  Future<List<String>> fetchMoviePosters(int movieId) async {
    final response = await _get(
      '/movie/$movieId/images',
      queryParameters: {'include_image_language': 'en,null'},
    );

    final List<dynamic> postersJson = response['posters'] ?? [];

    const imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

    return postersJson
        .map((item) => '$imageBaseUrl${item['file_path']}')
        .toList();
  }
}

class MovieServiceException implements Exception {
  const MovieServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class HomeMovieData {
  const HomeMovieData({
    required this.popular,
    required this.topRated,
    required this.upcoming,
  });

  final List<Movie> popular;
  final List<Movie> topRated;
  final List<Movie> upcoming;
}

class HomeTVShowData {
  const HomeTVShowData({
    required this.popular,
    required this.topRated,
    required this.airingToday,
  });

  final List<Movie> popular;
  final List<Movie> topRated;
  final List<Movie> airingToday;
}

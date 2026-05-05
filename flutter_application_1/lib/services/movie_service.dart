import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie.dart';

class MovieService {
  MovieService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _apiKey = String.fromEnvironment('TMDB_API_KEY');
  static const _baseUrl = 'https://api.themoviedb.org/3';

  Future<HomeMovieData> fetchHomeMovies() async {
    if (_apiKey.isEmpty) {
      return HomeMovieData.demo();
    }

    final responses = await Future.wait([
      _get('/movie/popular'),
      _get('/movie/top_rated'),
      _get('/movie/upcoming'),
    ]);

    return HomeMovieData(
      popular: _parseMovieList(responses[0]),
      topRated: _parseMovieList(responses[1]),
      upcoming: _parseMovieList(responses[2]),
    );
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse(
      '$_baseUrl$path?api_key=$_apiKey&language=en-US&page=1',
    );
    final response = await _client.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Movie API failed with status ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  List<Movie> _parseMovieList(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>? ?? [];
    return results
        .map((item) => Movie.fromJson(item as Map<String, dynamic>))
        .where((movie) => movie.posterUrl.isNotEmpty)
        .toList();
  }
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

  factory HomeMovieData.demo() {
    final movies = _demoMovies.map(Movie.fromJson).toList();
    return HomeMovieData(
      popular: movies,
      topRated: movies.reversed.toList(),
      upcoming: [movies[2], movies[0], movies[3], movies[1]],
    );
  }
}

const _demoMovies = <Map<String, dynamic>>[
  {
    'id': 1,
    'title': 'The Super Mario Galaxy Movie',
    'poster_path': '/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg',
    'backdrop_path': '/5YZbUmjbMa3ClvSW1Wj3D6XGolb.jpg',
    'release_date': '2026-04-03',
    'runtime': 95,
    'vote_average': 8.9,
    'overview': 'A bright adventure across new worlds.',
  },
  {
    'id': 2,
    'title': 'The Shawshank Redemption',
    'poster_path': '/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg',
    'backdrop_path': '/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg',
    'release_date': '1994-09-23',
    'runtime': 142,
    'vote_average': 9.3,
    'overview': 'Hope finds a way inside a prison sentence.',
  },
  {
    'id': 3,
    'title': 'The Godfather',
    'poster_path': '/3bhkrj58Vtu7enYsRolD1fZdja1.jpg',
    'backdrop_path': '/tmU7GeKVybMWFButWEGl2M4GeiP.jpg',
    'release_date': '1972-03-14',
    'runtime': 175,
    'vote_average': 9.2,
    'overview': 'A family crime saga about power and loyalty.',
  },
  {
    'id': 4,
    'title': 'Spirited Away',
    'poster_path': '/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg',
    'backdrop_path': '/Ab8mkHmkYADjU7wQiOkia9BzGvS.jpg',
    'release_date': '2001-07-20',
    'runtime': 125,
    'vote_average': 8.5,
    'overview': 'A girl enters a strange world of spirits.',
  },
];

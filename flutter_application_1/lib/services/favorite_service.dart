import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class FavoriteService {
  FavoriteService._privateConstructor();

  static final FavoriteService _instance =
      FavoriteService._privateConstructor();

  factory FavoriteService() => _instance;

  static const String _key = 'favorites_v1';

  Future<List<Movie>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((s) {
      final decoded = jsonDecode(s) as Map<String, dynamic>;
      return Movie.fromJson(decoded);
    }).toList();
  }

  Future<bool> isFavorite(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.any((s) {
      try {
        final decoded = jsonDecode(s) as Map<String, dynamic>;
        return decoded['id'] == id;
      } catch (_) {
        return false;
      }
    });
  }

  Future<void> toggleFavorite(Movie movie) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    final existsIndex = list.indexWhere((s) {
      try {
        final decoded = jsonDecode(s) as Map<String, dynamic>;
        return decoded['id'] == movie.id;
      } catch (_) {
        return false;
      }
    });

    if (existsIndex >= 0) {
      try {
        final decoded = jsonDecode(list[existsIndex]) as Map<String, dynamic>;
        final localPoster = decoded['localPosterPath'] as String?;
        final localBackdrop = decoded['localBackdropPath'] as String?;
        if (localPoster != null && localPoster.isNotEmpty) {
          final f = File(localPoster);
          if (await f.exists()) await f.delete();
        }
        if (localBackdrop != null && localBackdrop.isNotEmpty) {
          final f2 = File(localBackdrop);
          if (await f2.exists()) await f2.delete();
        }
      } catch (_) {}

      list.removeAt(existsIndex);
    } else {
      final Map<String, dynamic> data = movie.toJson();

      try {
        if (movie.posterUrl.isNotEmpty) {
          final local = await _downloadAndSave(
            movie.posterUrl,
            'poster_${movie.id}.jpg',
          );
          if (local != null) data['localPosterPath'] = local;
        }
        if (movie.backdropUrl.isNotEmpty) {
          final local2 = await _downloadAndSave(
            movie.backdropUrl,
            'backdrop_${movie.id}.jpg',
          );
          if (local2 != null) data['localBackdropPath'] = local2;
        }
      } catch (_) {}

      list.add(jsonEncode(data));
    }

    await prefs.setStringList(_key, list);
  }

  Future<void> deleteFavorites(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    final newList = <String>[];

    for (final s in list) {
      try {
        final decoded = jsonDecode(s) as Map<String, dynamic>;
        final id = decoded['id'];

        if (ids.contains(id)) {
          final localPoster = decoded['localPosterPath'] as String?;
          final localBackdrop = decoded['localBackdropPath'] as String?;

          if (localPoster != null && localPoster.isNotEmpty) {
            final f = File(localPoster);
            if (await f.exists()) await f.delete();
          }

          if (localBackdrop != null && localBackdrop.isNotEmpty) {
            final f2 = File(localBackdrop);
            if (await f2.exists()) await f2.delete();
          }
        } else {
          newList.add(s);
        }
      } catch (_) {
        newList.add(s);
      }
    }

    await prefs.setStringList(_key, newList);
  }

  Future<String?> _downloadAndSave(String url, String filename) async {
    try {
      final uri = Uri.parse(url);
      final res = await http.get(uri);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final bytes = res.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final favDir = Directory('${dir.path}/favorites');
        if (!await favDir.exists()) await favDir.create(recursive: true);
        final file = File('${favDir.path}/$filename');
        await file.writeAsBytes(bytes);
        return file.path;
      }
    } catch (_) {}
    return null;
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/movie.dart';
import 'package:http/http.dart' as http;

class LibraryService {
  static const String libraryKey = 'library_movies';
  static const String key = 'library_images';
  static const String editedKey = 'edited_images';

  Future<void> saveMovie(Movie movie) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> movies = prefs.getStringList(libraryKey) ?? [];

    final exists = movies.any((e) {
      final data = jsonDecode(e);

      return data['id'] == movie.id;
    });

    if (!exists) {
      movies.add(jsonEncode(movie.toJson()));

      await prefs.setStringList(libraryKey, movies);
    }
  }

  Future<String> saveNetworkImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));

    final bytes = response.bodyBytes;

    return await saveImage(bytes);
  }

  Future<String> saveImage(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();

    final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png';

    final file = File(path);

    await file.writeAsBytes(bytes);

    return path;
  }

  Future<void> addToLibrary(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> images = prefs.getStringList(key) ?? [];

    images.add(imagePath);

    await prefs.setStringList(key, images);
  }

  Future<void> addEditedImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> images = prefs.getStringList(editedKey) ?? [];

    images.add(imagePath);

    await prefs.setStringList(editedKey, images);
    debugPrint('LibraryService: addEditedImage saved -> $imagePath');
  }

  Future<List<String>> getLibraryImages() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(key) ?? [];
  }

  Future<List<String>> getEditedImages() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(editedKey) ?? [];
  }

  Future<List<Movie>> getMovies() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> moviesString = prefs.getStringList(libraryKey) ?? [];

    return moviesString.map((e) => Movie.fromJson(jsonDecode(e))).toList();
  }

  Future<void> removeMovie(int movieId) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> movies = prefs.getStringList(libraryKey) ?? [];

    movies.removeWhere((e) {
      final data = jsonDecode(e);

      return data['id'] == movieId;
    });

    await prefs.setStringList(libraryKey, movies);
  }

  Future<bool> isSaved(int movieId) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> movies = prefs.getStringList(libraryKey) ?? [];

    return movies.any((e) {
      final data = jsonDecode(e);

      return data['id'] == movieId;
    });
  }

  Future<bool> isImageSaved(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> images = prefs.getStringList(key) ?? [];

    return images.contains(imagePath);
  }

  Future<void> removeLibraryImage(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> images = prefs.getStringList(key) ?? [];

    images.remove(imageUrl);

    await prefs.setStringList(key, images);
  }

  Future<void> removeEditedImage(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> images = prefs.getStringList(editedKey) ?? [];

    images.remove(imageUrl);

    await prefs.setStringList(editedKey, images);
  }

  Future<void> toggleLibraryImage(String imagePath) async {
    final exists = await isImageSaved(imagePath);

    if (exists) {
      await removeLibraryImage(imagePath);
    } else {
      await addToLibrary(imagePath);
    }
  }

  Future<void> toggleLibraryMovie(Movie movie) async {
    final exists = await isSaved(movie.id);

    if (exists) {
      await removeMovie(movie.id);
    } else {
      await saveMovie(movie);
    }
  }
}

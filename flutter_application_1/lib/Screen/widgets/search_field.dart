import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../movie/movie_detail.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key, this.controller, this.onChanged});

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      readOnly: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchPage()),
        );
      },
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search for Movies, Tv Shows,...',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.48),
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFFFFD21E),
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.11),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(88),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// --- 2. TRANG SEARCH CHI TIẾT ---
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final MovieService _movieService = MovieService();
  late Future<List<Movie>> _popularMoviesFuture;

  @override
  void initState() {
    super.initState();
    _popularMoviesFuture = _movieService.fetchPopularNow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13110C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: const Color(0xFFFFD21E),
                      decoration: InputDecoration(
                        hintText: 'Search for Movies, Tv Shows,...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    "Search",
                    style: TextStyle(
                      color: Color(0xFFFFD21E),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              _buildHistoryItem("The Shawshank Redemption"),
              _buildHistoryItem("The Super Mario Galaxy Movie"),
              _buildHistoryItem("Spirited Away"),

              const SizedBox(height: 24),
              Container(
                height: 1,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 16),
                color: Colors.white10,
              ),
              const SizedBox(height: 24),
              const Text(
                "Popular Now",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: FutureBuilder<List<Movie>>(
                  future: _popularMoviesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFD21E),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          "Lỗi tải dữ liệu",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "Không có phim nào",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }

                    final movies = snapshot.data!;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieDetailScreen(movieId: movies[0].id),
                          ),
                        );
                      },
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.6,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 18,
                            ),
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          return _buildMovieCard(movies[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.white54, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.close, color: Colors.white54, size: 18),
        ],
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(
                  movie.posterUrl.isNotEmpty
                      ? movie.posterUrl
                      : 'https://via.placeholder.com/500x750?text=No+Image',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          movie.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          movie.releaseDate.isNotEmpty ? movie.releaseDate : "N/A",
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}

class SearchHistoryService {
  static const String _key = 'search_history';

  static Future<void> saveSearch(String query) async {
    if (query.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];

    history.remove(query);

    history.insert(0, query);

    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    await prefs.setStringList(_key, history);
  }

  static Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> deleteSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    history.remove(query);
    await prefs.setStringList(_key, history);
  }
}

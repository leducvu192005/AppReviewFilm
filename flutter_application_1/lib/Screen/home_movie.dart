import 'dart:async';
import 'widgets/color_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';
import 'widgets/empty_movies.dart';
import 'widgets/home_error_state.dart';
import 'widgets/movie_card.dart';
import 'widgets/poster_fallback.dart';
import 'widgets/search_field.dart';
import 'top_rated_movies.dart';
import 'upcoming_movies.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final MovieService _movieService = MovieService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  HomeMovieData? _movieData;
  List<Movie> _searchResults = [];
  String _query = '';
  bool _isLoading = true;
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final movieData = await _movieService.fetchHomeMovies();
      if (!mounted) return;
      setState(() {
        _movieData = movieData;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    _searchDebounce?.cancel();

    setState(() {
      _query = query;
      _searchResults = query.isEmpty ? [] : _searchResults;
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      setState(() => _isSearching = false);
      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 450),
      () => _searchMovies(query),
    );
  }

  Future<void> _searchMovies(String query) async {
    try {
      final results = await _movieService.searchMulti(query);
      if (!mounted || query != _query) return;

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (error) {
      if (!mounted || query != _query) return;

      setState(() {
        _error = error.toString();
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: MovieHomeBackground(child: SafeArea(child: _buildBody())),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD21E)),
      );
    }

    if (_error != null) {
      return HomeErrorState(
        message: _error ?? 'Something went wrong.',
        onRetry: _loadMovies,
      );
    }

    final movieData = _movieData;
    if (movieData == null) {
      return HomeErrorState(
        message: 'No movie data was loaded. Please try again.',
        onRetry: _loadMovies,
      );
    }

    return MovieHomeContent(
      data: movieData,
      query: _query,
      searchResults: _searchResults,
      isSearching: _isSearching,
      searchController: _searchController,
      onSearchChanged: _onSearchChanged,
      onRefresh: _loadMovies,
    );
  }
}

class _CarouselWrapper extends StatefulWidget {
  const _CarouselWrapper({super.key, required this.movies});

  final List<Movie> movies;

  @override
  State<_CarouselWrapper> createState() => _CarouselWrapperState();
}

class _CarouselWrapperState extends State<_CarouselWrapper> {
  final PageController _controller = PageController(viewportFraction: 0.75);
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _page = _controller.page ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              double scale = (1 - (_page - index).abs() * 0.2).clamp(0.8, 1.0);

              return Center(
                child: Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    width: 288,
                    height: 213,
                    child: FeaturedMovieCard(movie: movie),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            // Vị trí index == 2 là vị trí chính giữa
            bool isCenter = index == 2;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              // Nếu là thanh giữa thì rộng 12, còn lại là 4
              width: isCenter ? 12 : 4,
              // Nếu là thanh giữa thì cao 4, còn lại là 4 (tạo thành hình vuông/tròn)
              height: 4,
              decoration: BoxDecoration(
                color: isCenter
                    ? const Color(0xFFFFD21E) // Màu vàng thương hiệu
                    : Colors.white.withValues(alpha: 0.3),
                // Bo góc: thanh giữa bo nhẹ, các chấm tròn bo hoàn toàn
                borderRadius: BorderRadius.circular(isCenter ? 2 : 4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class MovieHomeContent extends StatelessWidget {
  const MovieHomeContent({
    super.key,
    required this.data,
    required this.query,
    required this.searchResults,
    required this.isSearching,
    required this.searchController,
    required this.onSearchChanged,
    required this.onRefresh,
  });

  final HomeMovieData data;
  final String query;
  final List<Movie> searchResults;
  final bool isSearching;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final isSearchMode = query.isNotEmpty;

    return RefreshIndicator(
      color: const Color(0xFFFFD21E),
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔍 Search
                  SearchField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                  ),

                  const SizedBox(height: 16),

                  if (isSearchMode) ...[
                    MovieShelf(
                      title: 'Search Results',
                      movies: searchResults,
                      isLoading: isSearching,
                      showViewAll: false,
                    ),
                  ] else ...[
                    // 🎬 TITLE
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/Vector.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFFFD21E),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: SectionTitle(title: 'Most Popular Movies'),
                        ),
                      ],
                    ),

                    _CarouselWrapper(movies: data.popular),

                    // ⭐ Top Rated
                    MovieShelf(
                      title: 'Top Rated',
                      movies: data.topRated,
                      onViewAll: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                TopRatedMoviesPage(movies: data.topRated),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 5),

                    // ⏳ Upcoming
                    Movieupcoming(
                      title: 'Up Coming',
                      movies: data.upcoming,
                      onViewAll: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                UpComingMoviesPage(movies: data.upcoming),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
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

class FeaturedMovieCard extends StatelessWidget {
  final Movie movie;

  const FeaturedMovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 🎬 IMAGE
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

        // 🎬 TITLE
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

        // 📅 DATE + ⏱ TIME
        Text(
          '${movie.releaseDate}  |  ${movie.runtime ?? 0}m',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .6),
            fontSize: 11,
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
          '${featured.releaseDate}  |  ${featured.runtime}m',
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

// thẻ MovieShelf đại diện cho một phần của giao diện người dùng hiển thị một danh sách phim theo một chủ đề nhất định
class MovieShelf extends StatelessWidget {
  const MovieShelf({
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
                rank: index + 1, // Thêm rank dựa trên vị trí trong danh sách
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
              ),
            ),
          ),
      ],
    );
  }
}

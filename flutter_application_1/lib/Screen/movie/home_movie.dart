import 'dart:async';
import 'package:flutter_application_1/Screen/TV_show/TV_Show_detail.dart';

import '../widgets/color_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/movie.dart';
import '../../services/movie_service.dart';
import '../widgets/home_error_state.dart';
import '../widgets/search_field.dart';
import 'movie_detail.dart';
import 'package:flutter_application_1/Screen/widgets/media_home_content.dart';
import 'package:flutter_application_1/Screen/widgets/top_rated_movies.dart';
import 'package:flutter_application_1/Screen/widgets/upcoming_movies.dart';

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

  void dispose() {
    _controller.dispose();
    super.dispose();
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
                    child: FeaturedMovieCard(
                      movie: movie,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieDetailScreen(movieId: movie.id),
                          ),
                        );
                      },
                    ),
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
            int currentIndex = _page.round();

            bool isActive = index == (currentIndex % 5);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 12 : 4,
              height: 4,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFFFD21E)
                    : Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
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
                      onTapMovie: (movie) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieDetailScreen(movieId: movie.id),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 5),

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

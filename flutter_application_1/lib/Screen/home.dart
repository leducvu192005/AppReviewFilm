import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final MovieService _movieService = MovieService();
  final TextEditingController _searchController = TextEditingController();

  HomeMovieData? _movieData;
  String _query = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  @override
  void dispose() {
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

  List<Movie> _filtered(List<Movie> movies) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return movies;
    return movies
        .where((movie) => movie.title.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2423),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: const _BottomMovieNav(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD21E)),
      );
    }

    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _loadMovies);
    }

    return _MovieHomeContent(
      data: _movieData!,
      searchController: _searchController,
      onSearchChanged: (value) => setState(() => _query = value),
      filtered: _filtered,
      onRefresh: _loadMovies,
    );
  }
}

class _MovieHomeContent extends StatelessWidget {
  const _MovieHomeContent({
    required this.data,
    required this.searchController,
    required this.onSearchChanged,
    required this.filtered,
    required this.onRefresh,
  });

  final HomeMovieData data;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<Movie> Function(List<Movie>) filtered;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final popular = filtered(data.popular);
    final topRated = filtered(data.topRated);
    final upcoming = filtered(data.upcoming);
    final featured = popular.isNotEmpty ? popular.first : data.popular.first;

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
                  const _StatusHeader(),
                  const SizedBox(height: 12),
                  _SearchField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                  ),
                  const SizedBox(height: 22),
                  const _SectionTitle(title: 'Most Popular Movies'),
                  const SizedBox(height: 12),
                  _FeaturedCarousel(movies: popular, featured: featured),
                  const SizedBox(height: 18),
                  _MovieShelf(title: 'Top Rated', movies: topRated),
                  const SizedBox(height: 18),
                  _MovieShelf(title: 'Up Coming', movies: upcoming),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '9:41',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.signal_cellular_alt,
          color: Colors.white.withValues(alpha: .9),
          size: 16,
        ),
        const SizedBox(width: 5),
        Icon(Icons.wifi, color: Colors.white.withValues(alpha: .9), size: 16),
        const SizedBox(width: 5),
        Icon(
          Icons.battery_full,
          color: Colors.white.withValues(alpha: .9),
          size: 18,
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      cursorColor: const Color(0xFFFFD21E),
      decoration: InputDecoration(
        hintText: 'Search for Movies, Tv Shows,...',
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: .48),
          fontSize: 12,
        ),
        prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD21E), size: 18),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .11),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.showViewAll = false});

  final String title;
  final bool showViewAll;

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
          Text(
            'View all',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .55),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _FeaturedCarousel extends StatelessWidget {
  const _FeaturedCarousel({required this.movies, required this.featured});

  final List<Movie> movies;
  final Movie featured;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const _EmptyMovies();

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: -40,
                child: _SidePoster(movie: movies[movies.length > 1 ? 1 : 0]),
              ),
              Positioned(
                right: -40,
                child: _SidePoster(movie: movies[movies.length > 2 ? 2 : 0]),
              ),
              _FeaturedPoster(movie: featured),
            ],
          ),
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 3),
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

class _FeaturedPoster extends StatelessWidget {
  const _FeaturedPoster({required this.movie});

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
        errorBuilder: (_, __, ___) =>
            const _PosterFallback(width: 228, height: 140),
      ),
    );
  }
}

class _SidePoster extends StatelessWidget {
  const _SidePoster({required this.movie});

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
          errorBuilder: (_, __, ___) =>
              const _PosterFallback(width: 74, height: 104),
        ),
      ),
    );
  }
}

class _MovieShelf extends StatelessWidget {
  const _MovieShelf({required this.title, required this.movies});

  final String title;
  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title, showViewAll: true),
        const SizedBox(height: 12),
        if (movies.isEmpty)
          const _EmptyMovies()
        else
          SizedBox(
            height: 206,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: movies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) => _MovieCard(
                movie: movies[index],
                rank: index < 2 ? index + 1 : null,
              ),
            ),
          ),
      ],
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie, this.rank});

  final Movie movie;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 126,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  movie.posterUrl,
                  width: 126,
                  height: 158,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const _PosterFallback(width: 126, height: 158),
                ),
              ),
              if (rank != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD21E),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
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
              fontSize: 11,
              height: 1.05,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            movie.releaseDate,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .45),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomMovieNav extends StatelessWidget {
  const _BottomMovieNav();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(34, 0, 34, 12),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF44484D).withValues(alpha: .9),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD21E),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.movie, color: Color(0xFF1D1D1D), size: 15),
                  SizedBox(width: 5),
                  Text(
                    'Movie',
                    style: TextStyle(
                      color: Color(0xFF1D1D1D),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const _NavIcon(Icons.tv_outlined),
            const _NavIcon(Icons.explore_outlined),
            const _NavIcon(Icons.favorite_border),
            const _NavIcon(Icons.person_outline),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: Colors.white.withValues(alpha: .48), size: 18);
  }
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.white.withValues(alpha: .12),
      child: const Icon(Icons.movie, color: Color(0xFFFFD21E)),
    );
  }
}

class _EmptyMovies extends StatelessWidget {
  const _EmptyMovies();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      alignment: Alignment.center,
      child: Text(
        'No movies found',
        style: TextStyle(color: Colors.white.withValues(alpha: .6)),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFFD21E), size: 42),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: .75)),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD21E),
                foregroundColor: const Color(0xFF1D1D1D),
              ),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

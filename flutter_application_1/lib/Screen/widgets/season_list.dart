import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/movie_service.dart';

class SeasonList extends StatefulWidget {
  final int tvShowId;
  final int seasonNumber;
  final String? seasonName;

  const SeasonList({
    super.key,
    required this.tvShowId,
    required this.seasonNumber,
    this.seasonName,
  });

  @override
  State<SeasonList> createState() => _SeasonListState();
}

class _SeasonListState extends State<SeasonList> {
  late Future<List<dynamic>> _episodesFuture;

  @override
  void initState() {
    super.initState();

    _episodesFuture = MovieService().fetchSeasonEpisodes(
      widget.tvShowId,
      widget.seasonNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1012),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1012),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          widget.seasonName ?? 'Season ${widget.seasonNumber}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        centerTitle: true,
      ),

      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _episodesFuture,

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD21E)),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Lỗi: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            final episodes = snapshot.data ?? [];

            if (episodes.isEmpty) {
              return const Center(
                child: Text(
                  'Không có tập nào',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),

              itemCount: episodes.length,

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),

              itemBuilder: (context, index) {
                final ep = episodes[index] as Map<String, dynamic>;

                final stillPath = ep['still_path'] as String?;

                final imageUrl = stillPath != null && stillPath.isNotEmpty
                    ? 'https://image.tmdb.org/t/p/w500$stillPath'
                    : '';

                return GestureDetector(
                  onTap: () {},

                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1B1D),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Expanded(
                          flex: 7,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),

                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(color: Colors.grey[800]),
                          ),
                        ),

                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Text(
                                  ep['name'] ?? 'Episode',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  ep['air_date'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

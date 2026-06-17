import 'package:chipileta_movies_app/domain/entities/movie.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:flutter/material.dart';

class HomeFeatured extends StatefulWidget {
  final List<Movie> movies;
  final Map<int, String> genres;

  const HomeFeatured({
    super.key,
    required this.movies,
    required this.genres,
  });

  @override
  State<HomeFeatured> createState() => _HomeFeaturedState();
}

class _HomeFeaturedState extends State<HomeFeatured> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  List<Movie> get _movies => widget.movies.take(5).toList();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _controller,
            itemCount: _movies.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _FeaturedCard(
                movie: _movies[index],
                genres: widget.genres,
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _movies.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: index == _currentPage ? 18 : 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index == _currentPage
                    ? AppColors.yellow
                    : AppColors.white70,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Movie movie;
  final Map<int, String> genres;

  const _FeaturedCard({
    required this.movie,
    required this.genres,
  });

  @override
  Widget build(BuildContext context) {
    final genreText = movie.genreIds
        .map((id) => genres[id])
        .whereType<String>()
        .take(2)
        .join(', ');

    final imagePath = movie.backdropPath.isNotEmpty
        ? movie.backdropPath
        : movie.posterPath;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 9,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Películas\ndestacadas',
                    style: TextStyle(
                      color: AppColors.heroText,
                      fontSize: 18,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    genreText.isEmpty
                        ? 'Descubre una película para disfrutar.'
                        : genreText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.heroText,
                      fontSize: 9,
                      height: 1.25,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        backgroundColor: Colors.black,
                        foregroundColor: AppColors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Ver ahora',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 13,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imagePath.isNotEmpty)
                  Image.network(
                    'https://image.tmdb.org/t/p/w780$imagePath',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const ColoredBox(
                        color: AppColors.imagePlaceholder,
                      );
                    },
                  )
                else
                  const ColoredBox(
                    color: AppColors.imagePlaceholder,
                  ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.yellow,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 8,
                  bottom: 8,
                  child: Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          blurRadius: 5,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
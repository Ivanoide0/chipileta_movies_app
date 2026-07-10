import 'dart:async';

import 'package:chipileta_movies_app/domain/entities/movie.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/presentation/controllers/movie_lists_controller.dart';
import 'package:flutter/material.dart';

import 'movie_action_feedback.dart';

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

  Timer? _autoScrollTimer;
  int _currentPage = 0;

  List<Movie> get _movies => widget.movies.take(5).toList();

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(covariant HomeFeatured oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldLength = oldWidget.movies.take(5).length;
    final newLength = _movies.length;

    if (oldLength != newLength && _currentPage >= newLength) {
      _currentPage = 0;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_controller.hasClients) {
          return;
        }

        _controller.jumpToPage(0);
      });
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();

    _autoScrollTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (!mounted || !_controller.hasClients || _movies.length < 2) {
          return;
        }

        if (_controller.position.isScrollingNotifier.value) {
          return;
        }

        final nextPage = (_currentPage + 1) % _movies.length;

        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      },
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
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
          height: 170,
          child: PageView.builder(
            controller: _controller,
            itemCount: _movies.length,
            onPageChanged: (index) {
              if (!mounted) {
                return;
              }

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
            (index) {
              final isSelected = index == _currentPage;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isSelected ? 18 : 5,
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.yellow
                      : AppColors.white70,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
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
                      fontSize: 21,
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
                      fontSize: 11,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 34,
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
                          fontSize: 12,
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

                Positioned(
                  top: 8,
                  right: 8,
                  child: AnimatedBuilder(
                    animation: movieListsController,
                    builder: (context, _) {
                      final isFavorite =
                          movieListsController.isFavorite(movie);
                      final isSaved = movieListsController.isSaved(movie);

                      return Row(
                        children: [
                          _MovieActionButton(
                            icon: isFavorite
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            isActive: isFavorite,
                            onTap: () => handleFavoriteTap(context, movie),
                          ),
                          const SizedBox(width: 6),
                          _MovieActionButton(
                            icon: isSaved
                                ? Icons.save
                                : Icons.save,
                            isActive: isSaved,
                            onTap: () => handleSavedTap(context, movie),
                          ),
                        ],
                      );
                    },
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
                      fontSize: 13,
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

class _MovieActionButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _MovieActionButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 160),
            scale: isActive ? 1.15 : 1,
            curve: Curves.easeOutBack,
            child: Icon(
              icon,
              size: 19,
              color: isActive ? AppColors.yellow : AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
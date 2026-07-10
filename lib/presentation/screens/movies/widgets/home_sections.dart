import 'package:chipileta_movies_app/domain/datasources/database_helper.dart';
import 'package:chipileta_movies_app/domain/datasources/movies_remote_datasource.dart';
import 'package:chipileta_movies_app/domain/datasources/opinions_local_datasource.dart';
import 'package:chipileta_movies_app/domain/datasources/session_service.dart';
import 'package:chipileta_movies_app/domain/entities/movie.dart';
import 'package:chipileta_movies_app/domain/entities/opinion_view.dart';
import 'package:chipileta_movies_app/domain/entities/opinion_with_author.dart';
import 'package:chipileta_movies_app/domain/entities/review.dart';
import 'package:chipileta_movies_app/domain/repositories/movies_repository_impl.dart';
import 'package:chipileta_movies_app/domain/repositories/opinions_repository_impl.dart';
import 'package:chipileta_movies_app/domain/usercases/add_opinion_usecase.dart';
import 'package:chipileta_movies_app/domain/usercases/get_all_opinions_with_author_usecase.dart';
import 'package:chipileta_movies_app/domain/usercases/get_top_reviews_usecase.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/presentation/controllers/movie_lists_controller.dart';
import 'movie_action_feedback.dart';
import 'media_detail_screen.dart';
import 'package:flutter/material.dart';

class HomeSections extends StatelessWidget {
  final Key? recommendationsKey;
  final Key? savedKey;
  final Key? opinionsKey;

  final List<Movie> recommendations;
  final List<Movie> movies;
  final List<Movie> series;

  final Map<int, String> movieGenres;
  final Map<int, String> tvGenres;

  const HomeSections({
    super.key,
    this.recommendationsKey,
    this.savedKey,
    this.opinionsKey,
    required this.recommendations,
    required this.movies,
    required this.series,
    required this.movieGenres,
    required this.tvGenres,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            key: recommendationsKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                title: 'Chipi recomendaciones',
                action: 'Ver todo',
              ),
              const SizedBox(height: 14),
              _MediaList(
                movies: recommendations.take(10).toList(),
                genres: movieGenres,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Column(
            key: savedKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                title: 'Chipi lista de películas',
              ),
              const SizedBox(height: 14),
              _MediaList(
                movies: movies.take(5).toList(),
                genres: movieGenres,
              ),
              const SizedBox(height: 28),
              const _SectionTitle(
                title: 'Chipi lista de series',
              ),
              const SizedBox(height: 14),
              _MediaList(
                movies: series.take(5).toList(),
                genres: tvGenres,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            key: opinionsKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _OpinionsTitle(),
              const SizedBox(height: 18),
              _OpinionsSection(
                movies: recommendations,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? action;

  const _SectionTitle({
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (action != null)
          Text(
            action!,
            style: const TextStyle(
              color: AppColors.yellow,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _Recommendations extends StatelessWidget {
  final List<Movie> movies;
  final Map<int, String> genres;

  const _Recommendations({
    required this.movies,
    required this.genres,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const _EmptyMessage(
        'No hay recomendaciones disponibles.',
      );
    }

    return ClipRect(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [
              0.0,
              0.88,
              1.0,
            ],
            colors: [
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
          ).createShader(bounds);
        },
        child: SizedBox(
          height: 225,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 4,
              right: 28,
            ),
            itemCount: movies.length,
            separatorBuilder: (_, __) {
              return const SizedBox(width: 13);
            },
            itemBuilder: (context, index) {
              final movie = movies[index];

              return SizedBox(
                width: 112,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 112,
                        height: 164,
                        child: _MovieImage(
                          path: movie.posterPath,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _genreText(movie, genres),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MediaList extends StatelessWidget {
  final List<Movie> movies;
  final Map<int, String> genres;

  const _MediaList({
    required this.movies,
    required this.genres,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const _EmptyMessage(
        'No hay contenido disponible.',
      );
    }

    return Column(
      children: [
        for (var index = 0; index < movies.length; index++) ...[
          _MediaTile(
            movie: movies[index],
            genres: genres,
          ),
          if (index < movies.length - 1)
            const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _MediaTile extends StatelessWidget {
  final Movie movie;
  final Map<int, String> genres;

  const _MediaTile({
    required this.movie,
    required this.genres,
  });

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MediaDetailScreen(
          movie: movie,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = movie.backdropPath.isNotEmpty
        ? movie.backdropPath
        : movie.posterPath;

    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _openDetails(context),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 112,
                      height: 76,
                      child: _MovieImage(
                        path: imagePath,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          _genreText(movie, genres),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.yellow,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        AnimatedBuilder(
          animation: movieListsController,
          builder: (context, _) {
            final isFavorite =
                movieListsController.isFavorite(movie);
            final isSaved =
                movieListsController.isSaved(movie);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _MovieActionButton(
                  icon: isFavorite
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  isActive: isFavorite,
                  onTap: () {
                    handleFavoriteTap(context, movie);
                  },
                ),
                const SizedBox(height: 6),
                _MovieActionButton(
                  icon: Icons.save,
                  isActive: isSaved,
                  onTap: () {
                    handleSavedTap(context, movie);
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
class _MovieActionButton extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _MovieActionButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_MovieActionButton> createState() => _MovieActionButtonState();
}

class _MovieActionButtonState extends State<_MovieActionButton> {
  bool _isPressed = false;

  Future<void> _handleTap() async {
    setState(() {
      _isPressed = true;
    });

    await Future.delayed(const Duration(milliseconds: 90));

    widget.onTap();

    await Future.delayed(const Duration(milliseconds: 120));

    if (!mounted) return;

    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double activeScale = widget.isActive ? 1.15 : 1;
    final double pressScale = _isPressed ? 0.82 : activeScale;

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      scale: pressScale,
      child: Material(
        color: Colors.black.withOpacity(0.45),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _handleTap,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: Icon(
                widget.icon,
                key: ValueKey(widget.icon),
                size: 17,
                color: widget.isActive
                    ? AppColors.yellow
                    : AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OpinionsTitle extends StatelessWidget {
  const _OpinionsTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.dividerBlue,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: Text(
            'Chipi opiniones',
            style: TextStyle(
              color: AppColors.yellow,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.dividerBlue,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

class _MovieImage extends StatelessWidget {
  final String path;

  const _MovieImage({
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return const _ImagePlaceholder();
    }

    return Image.network(
      'https://image.tmdb.org/t/p/w500$path',
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return const _ImagePlaceholder(
          showLoader: true,
        );
      },
      errorBuilder: (_, __, ___) {
        return const _ImagePlaceholder();
      },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final bool showLoader;

  const _ImagePlaceholder({
    this.showLoader = false,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.imagePlaceholder,
      child: Center(
        child: showLoader
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.yellow,
                ),
              )
            : const Icon(
                Icons.movie_outlined,
                color: AppColors.white54,
              ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String message;

  const _EmptyMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.white70,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

String _genreText(
  Movie movie,
  Map<int, String> genres,
) {
  final names = movie.genreIds
      .map((id) => genres[id])
      .whereType<String>()
      .take(2)
      .toList();

  if (names.isEmpty) {
    return 'Sin género';
  }

  return names.join(', ');
}

class _OpinionsSection extends StatefulWidget {
  final List<Movie> movies;

  const _OpinionsSection({
    required this.movies,
  });

  @override
  State<_OpinionsSection> createState() {
    return _OpinionsSectionState();
  }
}

class _OpinionsSectionState extends State<_OpinionsSection> {
  late final AddOpinionUseCase _addOpinion;
  late final GetAllOpinionsWithAuthorUseCase _getOpinions;
  late final GetTopReviewsUseCase _getTopReviews;

  late Future<List<OpinionView>> _opinionsFuture;

  final TextEditingController _commentController =
      TextEditingController();

  Movie? _selectedMovie;

  int _rating = 5;
  bool _isSending = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();

    final datasource = OpinionsLocalDataSource(
      DatabaseHelper.instance,
    );

    final repository = OpinionsRepositoryImpl(
      datasource,
    );

    _addOpinion = AddOpinionUseCase(
      repository,
    );

    _getOpinions = GetAllOpinionsWithAuthorUseCase(
      repository,
    );

    final moviesDatasource = MoviesRemoteDatasource();

    final moviesRepository = MoviesRepositoryImpl(
      moviesDatasource,
    );

    _getTopReviews = GetTopReviewsUseCase(
      moviesRepository,
    );

    _opinionsFuture = _loadAll();

    if (widget.movies.isNotEmpty) {
      _selectedMovie = widget.movies.first;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _opinionsFuture = _loadAll();
    });
  }

  Future<List<OpinionView>> _loadAll() async {
    final localFuture = _getOpinions();

    final tmdbFuture = _getTopReviews(
      movies: widget.movies,
    );

    final local = await localFuture;

    List<Review> tmdb;

    try {
      tmdb = await tmdbFuture;
    } catch (_) {
      tmdb = const [];
    }

    return [
      ...local.map(_fromLocal),
      ...tmdb.map(_fromTmdb),
    ];
  }

  Future<void> _submit() async {
    setState(() {
      _errorText = null;
    });

    final user = SessionService.instance.currentUser;

    if (user == null || user.id == null) {
      setState(() {
        _errorText =
            'Inicia sesión con tu correo para dejar una opinión.';
      });

      return;
    }

    if (_selectedMovie == null) {
      setState(() {
        _errorText = 'Selecciona una película.';
      });

      return;
    }

    if (_commentController.text.trim().isEmpty) {
      setState(() {
        _errorText = 'Escribe tu opinión.';
      });

      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _addOpinion(
        movieId: _selectedMovie!.id,
        userId: user.id!,
        rating: _rating.toDouble(),
        comment: _commentController.text,
      );

      _commentController.clear();

      if (!mounted) {
        return;
      }

      _reload();
    } catch (error) {
      setState(() {
        _errorText = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<List<OpinionView>>(
          future: _opinionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                ),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.yellow,
                    ),
                  ),
                ),
              );
            }

            final opinions = snapshot.data ?? const [];

            if (opinions.isEmpty) {
              return const _EmptyMessage(
                'Aún no hay opiniones. ¡Sé el primero!',
              );
            }

            return Column(
              children: [
                for (
                  var index = 0;
                  index < opinions.length;
                  index++
                ) ...[
                  _OpinionTile(
                    item: opinions[index],
                  ),
                  if (index < opinions.length - 1)
                    const SizedBox(height: 20),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _OpinionTile extends StatelessWidget {
  final OpinionView item;

  const _OpinionTile({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: AppColors.white70,
          child: Text(
            item.initials,
            style: const TextStyle(
              color: AppColors.heroText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.authorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.yellow,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                item.comment,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white70,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.star_rounded,
          color: AppColors.yellow,
          size: 19,
        ),
        const SizedBox(width: 3),
        Text(
          item.rating.toStringAsFixed(1),
          style: const TextStyle(
            color: AppColors.yellow,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

OpinionView _fromLocal(OpinionWithAuthor opinion) {
  return OpinionView(
    authorName: opinion.fullName,
    comment: opinion.opinion.comment,
    rating: opinion.opinion.rating,
    fromTmdb: false,
  );
}

OpinionView _fromTmdb(Review review) {
  return OpinionView(
    authorName: review.author,
    comment: review.content,
    rating: (review.rating ?? 0) / 2,
    fromTmdb: true,
  );
}
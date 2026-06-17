import 'package:chipileta_movies_app/domain/entities/movie.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:flutter/material.dart';
//!Imports para las opiniones D:
import 'package:chipileta_movies_app/domain/entities/opinion_with_author.dart';
import 'package:chipileta_movies_app/domain/datasources/database_helper.dart';
import 'package:chipileta_movies_app/domain/datasources/opinions_local_datasource.dart';
import 'package:chipileta_movies_app/domain/datasources/session_service.dart';
import 'package:chipileta_movies_app/domain/repositories/opinions_repository_impl.dart';
import 'package:chipileta_movies_app/domain/usercases/add_opinion_usecase.dart';
import 'package:chipileta_movies_app/domain/usercases/get_all_opinions_with_author_usecase.dart';
import 'package:chipileta_movies_app/domain/entities/opinion_view.dart';
import 'package:chipileta_movies_app/domain/entities/review.dart';
import 'package:chipileta_movies_app/domain/datasources/movies_remote_datasource.dart';
import 'package:chipileta_movies_app/domain/repositories/movies_repository_impl.dart';
import 'package:chipileta_movies_app/domain/usercases/get_top_reviews_usecase.dart';

class HomeSections extends StatelessWidget {
  final List<Movie> recommendations;
  final List<Movie> movies;
  final List<Movie> series;
  final Map<int, String> movieGenres;
  final Map<int, String> tvGenres;

  const HomeSections({
    super.key,
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
          const _SectionTitle(
            title: 'Chipi recomendaciones',
            action: 'Ver todo',
          ),
          const SizedBox(height: 12),
          _Recommendations(
            movies: recommendations.take(10).toList(),
            genres: movieGenres,
          ),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Chipi lista de películas'),
          const SizedBox(height: 12),
          _MediaList(
            movies: movies.take(3).toList(),
            genres: movieGenres,
          ),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Chipi lista de series'),
          const SizedBox(height: 12),
          _MediaList(
            movies: series.take(3).toList(),
            genres: tvGenres,
          ),
          const SizedBox(height: 28),
          const _OpinionsTitle(),
          const SizedBox(height: 28),
          _OpinionsSection(movies: recommendations)
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
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null)
          Text(
            action!,
            style: const TextStyle(
              color: AppColors.yellow,
              fontSize: 10,
              fontWeight: FontWeight.w600,
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
      return const _EmptyMessage('No hay recomendaciones disponibles.');
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: movies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final movie = movies[index];

          return SizedBox(
            width: 88,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: SizedBox(
                    width: 88,
                    height: 128,
                    child: _MovieImage(path: movie.posterPath),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _genreText(movie, genres),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.yellow,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
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
      return const _EmptyMessage('No hay contenido disponible.');
    }

    return Column(
      children: [
        for (var index = 0; index < movies.length; index++) ...[
          _MediaTile(
            movie: movies[index],
            genres: genres,
          ),
          if (index < movies.length - 1) const SizedBox(height: 12),
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

  @override
  Widget build(BuildContext context) {
    final imagePath = movie.backdropPath.isNotEmpty
        ? movie.backdropPath
        : movie.posterPath;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 88,
            height: 62,
            child: _MovieImage(path: imagePath),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _genreText(movie, genres),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.yellow,
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Chipi opiniones',
            style: TextStyle(
              color: AppColors.yellow,
              fontSize: 11,
              fontWeight: FontWeight.w600,
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

  const _MovieImage({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return const _ImagePlaceholder();
    }

    return Image.network(
      'https://image.tmdb.org/t/p/w500$path',
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        return progress == null
            ? child
            : const _ImagePlaceholder(showLoader: true);
      },
      errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
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
          style: const TextStyle(
            color: AppColors.white70,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}

String _genreText(Movie movie, Map<int, String> genres) {
  final names = movie.genreIds
      .map((id) => genres[id])
      .whereType<String>()
      .take(2)
      .toList();

  return names.isEmpty ? 'Sin género' : names.join(', ');
}


//! Clases para las opiniones:
class _OpinionsSection extends StatefulWidget {
  final List<Movie> movies;

  const _OpinionsSection({required this.movies});

  @override
  State<_OpinionsSection> createState() => _OpinionsSectionState();
}

class _OpinionsSectionState extends State<_OpinionsSection> {
  late final AddOpinionUseCase _addOpinion;
  late final GetAllOpinionsWithAuthorUseCase _getOpinions;
  late final GetTopReviewsUseCase _getTopReviews;

  late Future<List<OpinionView>> _opinionsFuture;

  final _commentController = TextEditingController();
  Movie? _selectedMovie;
  int _rating = 5;
  bool _isSending = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final datasource = OpinionsLocalDataSource(DatabaseHelper.instance);
    final repository = OpinionsRepositoryImpl(datasource);
    _addOpinion = AddOpinionUseCase(repository);
    _getOpinions = GetAllOpinionsWithAuthorUseCase(repository);

    final moviesDatasource = MoviesRemoteDatasource();
    final moviesRepository = MoviesRepositoryImpl(moviesDatasource);
    _getTopReviews = GetTopReviewsUseCase(moviesRepository);
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
    // Las dos fuentes en paralelo.
    final localFuture = _getOpinions();
    final tmdbFuture = _getTopReviews(movies: widget.movies);

    final local = await localFuture;
    List<Review> tmdb;
    try {
      tmdb = await tmdbFuture;
    } catch (_) {
      tmdb = const []; // si TMDB falla, al menos mostramos las locales
    }

    return [
      ...local.map(_fromLocal),
      ...tmdb.map(_fromTmdb),
    ];
  }

  Future<void> _submit() async {
    setState(() => _errorText = null);

    final user = SessionService.instance.currentUser;
    if (user == null || user.id == null) {
      setState(() => _errorText =
          'Inicia sesión con tu correo para dejar una opinión.');
      return;
    }

    if (_selectedMovie == null) {
      setState(() => _errorText = 'Selecciona una película.');
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      setState(() => _errorText = 'Escribe tu opinión.');
      return;
    }

    setState(() => _isSending = true);

    try {
      await _addOpinion(
        movieId: _selectedMovie!.id,
        userId: user.id!,
        rating: _rating.toDouble(),
        comment: _commentController.text,
      );

      _commentController.clear();
      if (!mounted) return;
      _reload();
    } catch (e) {
      setState(() {
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
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
                for (var i = 0; i < opinions.length; i++) ...[
                  _OpinionTile(item: opinions[i]),
                  if (i < opinions.length - 1) const SizedBox(height: 20),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _OpinionForm(
          movies: widget.movies,
          selectedMovie: _selectedMovie,
          rating: _rating,
          commentController: _commentController,
          isSending: _isSending,
          errorText: _errorText,
          onMovieChanged: (m) => setState(() => _selectedMovie = m),
          onRatingChanged: (r) => setState(() => _rating = r),
          onSubmit: _submit,
        ),
      ],
    );
  }
}

class _OpinionTile extends StatelessWidget {
  final OpinionView item;

  const _OpinionTile({required this.item});

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
              fontSize: 10,
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
                  fontSize: 10,
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
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.star_rounded,
          color: AppColors.yellow,
          size: 15,
        ),
        const SizedBox(width: 3),
        Text(
          item.rating.toStringAsFixed(1),
          style: const TextStyle(
            color: AppColors.yellow,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _OpinionForm extends StatelessWidget {
  final List<Movie> movies;
  final Movie? selectedMovie;
  final int rating;
  final TextEditingController commentController;
  final bool isSending;
  final String? errorText;
  final ValueChanged<Movie?> onMovieChanged;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  const _OpinionForm({
    required this.movies,
    required this.selectedMovie,
    required this.rating,
    required this.commentController,
    required this.isSending,
    required this.errorText,
    required this.onMovieChanged,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de película
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.white70, width: 1.4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Movie>(
              value: selectedMovie,
              isExpanded: true,
              dropdownColor: AppColors.homeGradientBottom,
              hint: const Text(
                'Elige una película',
                style: TextStyle(color: AppColors.white54, fontSize: 10),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.yellow),
              items: movies.map((m) {
                return DropdownMenuItem<Movie>(
                  value: m,
                  child: Text(
                    m.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
              onChanged: isSending ? null : onMovieChanged,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Estrellas 1-5
        Row(
          children: List.generate(5, (index) {
            final value = index + 1;
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: isSending ? null : () => onRatingChanged(value),
              icon: Icon(
                value <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                color: AppColors.yellow,
                size: 26,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        // Campo de texto
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.white70, width: 1.4),
          ),
          child: TextField(
            controller: commentController,
            enabled: !isSending,
            maxLines: 2,
            style: const TextStyle(color: AppColors.white, fontSize: 11),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Deja tu chipi opinión aquí....',
              hintStyle: TextStyle(color: AppColors.white54, fontSize: 9),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: AppColors.yellow,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            onPressed: isSending ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.heroText,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Text(
                    'Enviar opinión',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

OpinionView _fromLocal(OpinionWithAuthor o) => OpinionView(
      authorName: o.fullName,
      comment: o.opinion.comment,
      rating: o.opinion.rating,
      fromTmdb: false,
    );

OpinionView _fromTmdb(Review r) => OpinionView(
      authorName: r.author,
      comment: r.content,
      rating: (r.rating ?? 0) / 2,
      fromTmdb: true,
    );
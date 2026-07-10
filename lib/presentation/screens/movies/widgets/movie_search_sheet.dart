import 'dart:async';
import 'package:chipileta_movies_app/domain/datasources/movies_remote_datasource.dart';
import 'package:chipileta_movies_app/domain/entities/movie.dart';
import 'package:chipileta_movies_app/domain/repositories/movies_repository_impl.dart';
import 'package:chipileta_movies_app/domain/usercases/search_movies_usecase.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:flutter/material.dart';
import 'media_detail_screen.dart';

class MovieSearchSheet extends StatefulWidget {
  final Map<int, String> movieGenres;

  const MovieSearchSheet({
    super.key,
    required this.movieGenres,
  });

  @override
  State<MovieSearchSheet> createState() => _MovieSearchSheetState();
}

class _MovieSearchSheetState extends State<MovieSearchSheet> {
  late final SearchMoviesUseCase _searchMovies;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;
  String _lastQuery = '';

  List<Movie> _results = const [];
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();

    final datasource = MoviesRemoteDatasource();
    final repository = MoviesRepositoryImpl(datasource);
    _searchMovies = SearchMoviesUseCase(repository);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();

    final query = value.trim();

    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _isLoading = false;
        _errorText = null;
        _lastQuery = '';
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _runSearch(query);
    });
  }

  Future<void> _runSearch(String query) async {
    _lastQuery = query;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final movies = await _searchMovies(query);

      if (!mounted || query != _lastQuery) return;

      setState(() {
        _results = movies;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || query != _lastQuery) return;

      setState(() {
        _isLoading = false;
        _errorText = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.homeGradient,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(22),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Barra superior con campo de texto.
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.yellow,
                      ),
                    ),
                    Expanded(
                      child: _SearchField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: _onChanged,
                        onClear: _clear,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: _buildBody(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(
            color: AppColors.yellow,
          ),
        ),
      );
    }

    if (_errorText != null) {
      return _SearchMessage(
        icon: Icons.cloud_off_rounded,
        message: _errorText!,
      );
    }

    if (_controller.text.trim().isEmpty) {
      return const _SearchMessage(
        icon: Icons.search_rounded,
        message: 'Busca una película por su nombre.',
      );
    }

    if (_results.isEmpty) {
      return const _SearchMessage(
        icon: Icons.movie_filter_outlined,
        message: 'No se encontraron películas con ese nombre.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return _SearchResultTile(
          movie: _results[index],
          genres: widget.movieGenres,
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 15,
      ),
      cursorColor: AppColors.yellow,
      decoration: InputDecoration(
        hintText: 'Buscar película...',
        hintStyle: const TextStyle(
          color: AppColors.white54,
          fontSize: 15,
        ),
        filled: true,
        fillColor: AppColors.backgroundDark.withValues(alpha: 0.35),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.yellow,
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) {
              return const SizedBox.shrink();
            }
            return IconButton(
              onPressed: onClear,
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.white70,
              ),
            );
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Movie movie;
  final Map<int, String> genres;

  const _SearchResultTile({
    required this.movie,
    required this.genres,
  });

  Future<void> _openDetails(BuildContext context) async {
    /*
     * Guardamos el Navigator antes de cerrar el buscador porque el
     * context de esta tarjeta dejará de existir al cerrar el modal.
     */
    final navigator = Navigator.of(context);

    await navigator.maybePop();

    if (!navigator.mounted) return;

    await navigator.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MediaDetailScreen(
          movie: movie,
        ),
      ),
    );
  }

  String get _subtitle {
    final year = movie.releaseDate?.year.toString();
    final typeText = movie.mediaTypeLabel;

    /*
     * Home actualmente entrega únicamente los géneros de películas.
     * Para las series no usamos ese mapa porque los IDs de género
     * pueden representar nombres distintos.
     */
    if (movie.isTv) {
      return year == null ? typeText : '$typeText · $year';
    }

    final genreText = _genreText(movie, genres);

    if (year == null) {
      return '$typeText · $genreText';
    }

    return '$typeText · $year · $genreText';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 2,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 54,
                  height: 80,
                  child: _PosterImage(
                    path: movie.posterPath,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _subtitle,
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
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _PosterImage extends StatelessWidget {
  final String path;

  const _PosterImage({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return const ColoredBox(
        color: AppColors.imagePlaceholder,
        child: Icon(
          Icons.movie_outlined,
          color: AppColors.white54,
          size: 20,
        ),
      );
    }

    return Image.network(
      'https://image.tmdb.org/t/p/w185$path',
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(color: AppColors.imagePlaceholder);
      },
      errorBuilder: (_, __, ___) {
        return const ColoredBox(
          color: AppColors.imagePlaceholder,
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.white54,
            size: 20,
          ),
        );
      },
    );
  }
}

class _SearchMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _SearchMessage({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: AppColors.white54),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white70,
                fontSize: 14,
              ),
            ),
          ],
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

  if (names.isEmpty) return 'Sin género';
  return names.join(', ');
}
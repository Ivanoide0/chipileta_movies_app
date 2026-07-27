import 'package:flutter/material.dart';

import 'package:chipileta_movies_app/domain/entities/movie.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/presentation/controllers/movie_lists_controller.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/widgets/home_footer.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/widgets/media_detail_screen.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/widgets/favorites_pdf.dart';

class FavoritesScreen extends StatelessWidget {
  static const name = 'favorites-screen';

  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeGradientBottom,
      bottomNavigationBar: const HomeFooter(currentIndex: 1),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.homeGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: AnimatedBuilder(
            animation: movieListsController,
            builder: (context, _) {
              final movies = movieListsController.favorites;

              if (movies.isEmpty) {
                return const _EmptyFavorites();
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Favoritos',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _ExportPdfButton(movies: movies),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tus películas favoritas aparecerán aquí.',
                      style: TextStyle(
                        color: AppColors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: movies.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.66,
                        ),
                        itemBuilder: (context, index) {
                          final movie = movies[index];

                          return _MovieCard(
                            movie: movie,
                            icon: Icons.star_rounded,
                            onRemove: () {
                              movieListsController.removeFavorite(movie);
                            },
                          );
                        },
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

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 38),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border_rounded,
              color: AppColors.yellow,
              size: 92,
            ),
            SizedBox(height: 24),
            Text(
              'Aún no tienes películas\nfavoritas chipiboy',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 14),
            Text(
              'Cuando marques una película como favorita, aparecerá aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 82),
          ],
        ),
      ),
    );
  }
}

class _ExportPdfButton extends StatefulWidget {
  final List<Movie> movies;

  const _ExportPdfButton({required this.movies});

  @override
  State<_ExportPdfButton> createState() => _ExportPdfButtonState();
}

class _ExportPdfButtonState extends State<_ExportPdfButton> {
  bool _loading = false;

  Future<void> _run(Future<void> Function(List<Movie>) action) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await action(widget.movies);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo generar el PDF.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _chooseAction() async {
    if (_loading) return;
    final action = await showModalBottomSheet<Future<void> Function(List<Movie>)>(
      context: context,
      backgroundColor: AppColors.homeGradientBottom,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Tus películas favoritas en PDF',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              ListTile(
                leading: const Icon(Icons.download_rounded, color: AppColors.yellow),
                title: const Text('Descargar',
                    style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700)),
                subtitle: const Text('Guardar el PDF en tu dispositivo',
                    style: TextStyle(color: AppColors.white70, fontSize: 12)),
                onTap: () => Navigator.pop(sheetContext, downloadFavoritesPdf),
              ),
              ListTile(
                leading: const Icon(Icons.ios_share_rounded, color: AppColors.turquoise),
                title: const Text('Compartir',
                    style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700)),
                subtitle: const Text('Enviar a otra app',
                    style: TextStyle(color: AppColors.white70, fontSize: 12)),
                onTap: () => Navigator.pop(sheetContext, shareFavoritesPdf),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (action != null) await _run(action);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.yellow,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: _loading ? null : _chooseAction,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.heroText,
                  ),
                )
              else
                const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppColors.heroText,
                  size: 18,
                ),
              const SizedBox(width: 7),
              const Text(
                'PDF',
                style: TextStyle(
                  color: AppColors.heroText,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movie movie;
  final IconData icon;
  final VoidCallback onRemove;

  const _MovieCard({
    required this.movie,
    required this.icon,
    required this.onRemove,
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
    final imagePath = movie.posterPath.isNotEmpty
        ? movie.posterPath
        : movie.backdropPath;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imagePath.isNotEmpty)
            Image.network(
              'https://image.tmdb.org/t/p/w500$imagePath',
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

          /*
           * Esta capa abre el detalle al tocar cualquier parte
           * de la tarjeta, excepto el botón de eliminar.
           */
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openDetails(context),
                splashColor: AppColors.yellow.withValues(alpha: .18),
                highlightColor: Colors.transparent,
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: .85),
                    ],
                  ),
                ),
                child: Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: Colors.black.withValues(alpha: .55),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Icon(
                    icon,
                    color: AppColors.yellow,
                    size: 19,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
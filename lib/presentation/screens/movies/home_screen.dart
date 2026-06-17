import 'package:chipileta_movies_app/domain/datasources/movies_remote_datasource.dart';
import 'package:chipileta_movies_app/domain/entities/home_content.dart';
import 'package:chipileta_movies_app/domain/repositories/movies_repository_impl.dart';
import 'package:chipileta_movies_app/domain/usercases/get_home_content_usecase.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:flutter/material.dart';

import 'widgets/home_featured.dart';
import 'widgets/home_header.dart';
import 'widgets/home_sections.dart';

class HomeScreen extends StatefulWidget {
  static const name = 'home-screen';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GetHomeContentUseCase _getHomeContent;
  late Future<HomeContent> _contentFuture;

  @override
  void initState() {
    super.initState();

    final datasource = MoviesRemoteDatasource();
    final repository = MoviesRepositoryImpl(datasource);

    _getHomeContent = GetHomeContentUseCase(repository);
    _contentFuture = _getHomeContent();
  }

  Future<void> _reload() async {
    final newFuture = _getHomeContent();

    setState(() {
      _contentFuture = newFuture;
    });

    await newFuture;
  }

  void _retry() {
    setState(() {
      _contentFuture = _getHomeContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.homeGradient,
        ),
        child: SafeArea(
          child: FutureBuilder<HomeContent>(
            future: _contentFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.yellow,
                  ),
                );
              }

              if (snapshot.hasError) {
                return _ErrorView(
                  error: snapshot.error,
                  onRetry: _retry,
                );
              }

              final content = snapshot.data;

              if (content == null) {
                return const Center(
                  child: Text(
                    'No hay contenido disponible.',
                    style: TextStyle(color: AppColors.white),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.yellow,
                backgroundColor: AppColors.homeGradientBottom,
                onRefresh: _reload,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    const HomeHeader(),
                    const SizedBox(height: 20),
                    HomeFeatured(
                      movies: content.featured,
                      genres: content.movieGenres,
                    ),
                    const SizedBox(height: 28),
                    HomeSections(
                      recommendations: content.recommendations,
                      movies: content.movies,
                      series: content.series,
                      movieGenres: content.movieGenres,
                      tvGenres: content.tvGenres,
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

class _ErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: AppColors.white70,
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar el contenido',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Error desconocido',
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: AppColors.heroText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
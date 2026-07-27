import 'dart:io';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

import 'package:chipileta_movies_app/domain/datasources/movies_remote_datasource.dart';
import 'package:chipileta_movies_app/domain/entities/home_content.dart';
import 'package:chipileta_movies_app/domain/repositories/movies_repository_impl.dart';
import 'package:chipileta_movies_app/domain/usercases/get_home_content_usecase.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/presentation/screens/error/error_view.dart';
import 'package:chipileta_movies_app/presentation/controllers/notifications_controller.dart';
import 'widgets/notifications_sheet.dart';

import 'widgets/home_featured.dart';
import 'widgets/home_footer.dart';
import 'widgets/home_header.dart';
import 'widgets/home_sections.dart';
import 'widgets/movie_search_sheet.dart';

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
    notificationsController.load();
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
      backgroundColor: AppColors.homeGradientBottom,
      bottomNavigationBar: const HomeFooter(currentIndex: 0),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.homeGradient,
        ),
        child: SafeArea(
          bottom: false,
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
                final error = snapshot.error;
                final isConnectionError = error is SocketException || error is ClientException;

                if(isConnectionError){
                  return ErrorView.noConnection(onRetry: _retry);
                }
                return const ErrorView.general();
              }

              final content = snapshot.data;

              if (content == null) {
                return const Center(
                  child: Text(
                    'No hay contenido disponible.',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
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
                  padding: const EdgeInsets.only(bottom: 10),
                  children: [
                    HomeHeader(
                      onSearchTap: () => _openSearch(content.movieGenres),
                      onNotificationsTap: _openNotifications,
                    ),
                    const SizedBox(height: 22),
                    HomeFeatured(
                      movies: content.featured,
                      genres: content.movieGenres,
                    ),
                    const SizedBox(height: 32),
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

  void _openSearch(Map<int, String> movieGenres){
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: MovieSearchSheet(movieGenres: movieGenres)
        );
      }
    );
  }

  void _openNotifications() {
    notificationsController
        .load()
        .then((_) => notificationsController.markAllRead());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const FractionallySizedBox(
          heightFactor: 0.92,
          child: NotificationsSheet(),
        );
      },
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
              size: 56,
              color: AppColors.white70,
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar el contenido',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
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
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Reintentar',
                style: TextStyle(fontSize: 15),
              ),
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
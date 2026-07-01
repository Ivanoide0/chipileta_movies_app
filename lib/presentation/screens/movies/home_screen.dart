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

  final ScrollController _scrollController = ScrollController();

  final GlobalKey _recommendationsKey = GlobalKey();
  final GlobalKey _savedKey = GlobalKey();
  final GlobalKey _opinionsKey = GlobalKey();

  int _selectedFooterIndex = 0;
  bool _isNavigatingFromFooter = false;

  @override
  void initState() {
    super.initState();

    final datasource = MoviesRemoteDatasource();
    final repository = MoviesRepositoryImpl(datasource);

    _getHomeContent = GetHomeContentUseCase(repository);
    _contentFuture = _getHomeContent();

    _scrollController.addListener(_syncFooterWithScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_syncFooterWithScroll);
    _scrollController.dispose();

    super.dispose();
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

  Future<void> _scrollToSection(int index) async {
    if (_selectedFooterIndex != index) {
      setState(() {
        _selectedFooterIndex = index;
      });
    }

    _isNavigatingFromFooter = true;

    try {
      // Inicio: lleva a la parte superior.
      if (index == 0) {
        if (_scrollController.hasClients) {
          await _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeInOutCubic,
          );
        }

        return;
      }

      GlobalKey? targetKey;

      switch (index) {
        case 1:
          targetKey = _recommendationsKey;
          break;

        case 2:
          targetKey = _savedKey;
          break;

        case 3:
          targetKey = _opinionsKey;
          break;
      }

      final targetContext = targetKey?.currentContext;

      if (targetContext == null) {
        return;
      }

      await Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
        alignment: 0.03,
      );
    } finally {
      _isNavigatingFromFooter = false;
      _syncFooterWithScroll();
    }
  }

  void _syncFooterWithScroll() {
    if (!mounted ||
        !_scrollController.hasClients ||
        _isNavigatingFromFooter) {
      return;
    }

    var visibleIndex = 0;

    // Altura aproximada a partir de la que una sección se considera activa.
    const activationLine = 170.0;

    final sectionKeys = <GlobalKey>[
      _recommendationsKey,
      _savedKey,
      _opinionsKey,
    ];

    for (var index = 0; index < sectionKeys.length; index++) {
      final sectionContext = sectionKeys[index].currentContext;
      final renderObject = sectionContext?.findRenderObject();

      if (renderObject is RenderBox && renderObject.hasSize) {
        final position = renderObject.localToGlobal(Offset.zero);
        final top = position.dy;

        if (top <= activationLine) {
          visibleIndex = index + 1;
        }
      }
    }

    // Cuando llega al final, selecciona Opiniones.
    if (_scrollController.position.extentAfter < 48) {
      visibleIndex = 3;
    }

    if (visibleIndex != _selectedFooterIndex) {
      setState(() {
        _selectedFooterIndex = visibleIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeGradientBottom,
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
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  children: [
                    const HomeHeader(),
                    const SizedBox(height: 22),

                    HomeFeatured(
                      movies: content.featured,
                      genres: content.movieGenres,
                    ),

                    const SizedBox(height: 32),

                    HomeSections(
                      recommendationsKey: _recommendationsKey,
                      savedKey: _savedKey,
                      opinionsKey: _opinionsKey,
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

      // Footer fijo en la parte inferior.
      bottomNavigationBar: _HomeFooter(
        currentIndex: _selectedFooterIndex,
        onTap: _scrollToSection,
      ),
    );
  }
}

class _HomeFooter extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _HomeFooter({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.footerBackground,
      elevation: 14,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(
          top: 8,
        ),
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              _FooterItem(
                label: 'Inicio',
                icon: Icons.home_outlined,
                selected: currentIndex == 0,
                onTap: () {
                  onTap(0);
                },
              ),
              _FooterItem(
                label: 'Favoritos',
                icon: Icons.star_border_rounded,
                selected: currentIndex == 1,
                onTap: () {
                  onTap(1);
                },
              ),
              _FooterItem(
                label: 'Guardados',
                icon: Icons.save,
                boxedIcon: true,
                selected: currentIndex == 2,
                onTap: () {
                  onTap(2);
                },
              ),
              _FooterItem(
                label: 'Opiniones',
                icon: Icons.person_outline_rounded,
                selected: currentIndex == 3,
                onTap: () {
                  onTap(3);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool boxedIcon;
  final bool selected;
  final VoidCallback onTap;

  const _FooterItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.boxedIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.footerActive
        : AppColors.footerInactive;

    final Widget iconWidget;

    if (boxedIcon) {
      iconWidget = Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(
            color: color,
            width: 2.2,
          ),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          icon,
          size: 27,
          color: color,
        ),
      );
    } else {
      iconWidget = Icon(
        icon,
        size: 36,
        color: color,
      );
    }

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
                child: Center(
                  child: iconWidget,
                ),
              ),
              const SizedBox(height: 7),

              // Línea amarilla debajo del icono seleccionado.
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 42 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.footerActive
                      : const Color.fromARGB(0, 63, 6, 6),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
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
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Reintentar',
                style: TextStyle(
                  fontSize: 15,
                ),
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
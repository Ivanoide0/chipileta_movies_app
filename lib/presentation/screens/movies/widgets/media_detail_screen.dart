import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:chipileta_movies_app/domain/datasources/database_helper.dart';
import 'package:chipileta_movies_app/domain/datasources/movies_remote_datasource.dart';
import 'package:chipileta_movies_app/domain/datasources/opinions_local_datasource.dart';
import 'package:chipileta_movies_app/domain/datasources/session_service.dart';
import 'package:chipileta_movies_app/domain/entities/movie.dart';
import 'package:chipileta_movies_app/domain/entities/opinion_with_author.dart';
import 'package:chipileta_movies_app/domain/entities/review.dart';
import 'package:chipileta_movies_app/domain/repositories/opinions_repository_impl.dart';  
import 'package:chipileta_movies_app/domain/usercases/add_opinion_usecase.dart';
import 'package:chipileta_movies_app/domain/usercases/get_all_opinions_with_author_usecase.dart';
import 'package:chipileta_movies_app/presentation/controllers/movie_lists_controller.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/widgets/home_footer.dart';
import 'package:chipileta_movies_app/presentation/screens/movies/widgets/movie_action_feedback.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';

class MediaDetailScreen extends StatefulWidget {
  final Movie movie;

  const MediaDetailScreen({
    super.key,
    required this.movie,
  });

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  late final MoviesRemoteDatasource _moviesDatasource;
  late final AddOpinionUseCase _addOpinion;
  late final GetAllOpinionsWithAuthorUseCase _getAllOpinions;

  late Future<Movie> _detailFuture;
  late Future<List<OpinionWithAuthor>> _opinionsFuture;

  final TextEditingController _commentController = TextEditingController();
  final GlobalKey _trailerSectionKey = GlobalKey();

  int _rating = 5;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    _moviesDatasource = MoviesRemoteDatasource();

    final opinionsRepository = OpinionsRepositoryImpl(
      OpinionsLocalDataSource(DatabaseHelper.instance),
    );

    _addOpinion = AddOpinionUseCase(opinionsRepository);
    _getAllOpinions = GetAllOpinionsWithAuthorUseCase(
      opinionsRepository,
    );

    _detailFuture = _moviesDatasource.getMediaDetail(widget.movie);
    _opinionsFuture = _loadOpinions();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<List<OpinionWithAuthor>> _loadOpinions() async {
    final opinions = await _getAllOpinions();

    return opinions
        .where(
          (item) => item.opinion.movieId == widget.movie.opinionId,
        )
        .toList(growable: false);
  }

  Future<void> _refresh() async {
    final detailFuture = _moviesDatasource.getMediaDetail(widget.movie);
    final opinionsFuture = _loadOpinions();

    setState(() {
      _detailFuture = detailFuture;
      _opinionsFuture = opinionsFuture;
    });

    await Future.wait([
      detailFuture,
      opinionsFuture,
    ]);
  }

  void _retry() {
    setState(() {
      _detailFuture = _moviesDatasource.getMediaDetail(widget.movie);
      _opinionsFuture = _loadOpinions();
    });
  }

  void _scrollToTrailer() {
    final trailerContext = _trailerSectionKey.currentContext;

    if (trailerContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      trailerContext,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  Future<void> _submitOpinion() async {
    final user = SessionService.instance.currentUser;
    final comment = _commentController.text.trim();

    if (user == null || user.id == null) {
      _showMessage(
        'Inicia sesión con tu correo para publicar una opinión.',
      );
      return;
    }

    if (comment.isEmpty) {
      _showMessage('Escribe tu opinión antes de publicarla.');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _addOpinion(
        movieId: widget.movie.opinionId,
        userId: user.id!,
        rating: _rating.toDouble(),
        comment: comment,
      );

      _commentController.clear();
      FocusScope.of(context).unfocus();

      if (!mounted) {
        return;
      }

      setState(() {
        _rating = 5;
        _opinionsFuture = _loadOpinions();
      });

      _showMessage('Tu opinión fue publicada.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.footerBackground,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeGradientBottom,
      bottomNavigationBar: const HomeFooter(currentIndex: -1),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.homeGradient,
        ),
        child: FutureBuilder<Movie>(
          future: _detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _LoadingView(
                movie: widget.movie,
                onBack: () => Navigator.of(context).pop(),
              );
            }

            if (snapshot.hasError || snapshot.data == null) {
              return _ErrorView(
                message: snapshot.error
                    ?.toString()
                    .replaceFirst('Exception: ', ''),
                onBack: () => Navigator.of(context).pop(),
                onRetry: _retry,
              );
            }

            final movie = snapshot.data!;

            return RefreshIndicator(
              color: AppColors.yellow,
              backgroundColor: AppColors.homeGradientBottom,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  _DetailAppBar(
                    movie: movie,
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                      child: _PrimaryActions(
                        movie: movie,
                        onTrailerTap: _scrollToTrailer,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 28, 18, 0),
                      child: _OverviewSection(movie: movie),
                    ),
                  ),
                  SliverToBoxAdapter(
                    key: _trailerSectionKey,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 28, 18, 0),
                      child: _TrailerSection(
                        videoId: movie.trailerKey,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 30, 0, 0),
                      child: _CastSection(cast: movie.cast),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 32, 18, 0),
                      child: _LocalOpinionsSection(
                        opinionsFuture: _opinionsFuture,
                        commentController: _commentController,
                        rating: _rating,
                        isSending: _isSending,
                        onRatingChanged: (value) {
                          setState(() {
                            _rating = value;
                          });
                        },
                        onSubmit: _submitOpinion,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 32, 18, 38),
                      child: _TmdbReviewsSection(
                        reviews: movie.tmdbReviews,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  final Movie movie;
  final VoidCallback onBack;

  const _DetailAppBar({
    required this.movie,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      expandedHeight: 420,
      backgroundColor: AppColors.homeGradientTop,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: _CircleIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _DetailHero(movie: movie),
      ),
    );
  }
}

class _DetailHero extends StatelessWidget {
  final Movie movie;

  const _DetailHero({required this.movie});

  @override
  Widget build(BuildContext context) {
    final backdropPath = movie.backdropPath.isNotEmpty
        ? movie.backdropPath
        : movie.posterPath;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (backdropPath.isNotEmpty)
          Image.network(
            'https://image.tmdb.org/t/p/w1280$backdropPath',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: AppColors.imagePlaceholder,
            ),
          )
        else
          const ColoredBox(color: AppColors.imagePlaceholder),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 0.48, 1],
              colors: [
                Color(0x22000000),
                Color(0xAA061D2C),
                AppColors.homeGradientBottom,
              ],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 88, 18, 18),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Poster(path: movie.posterPath),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TypeBadge(label: movie.mediaTypeLabel),
                          const SizedBox(height: 9),
                          Text(
                            movie.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 25,
                              height: 1.08,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 7,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (movie.releaseDate != null)
                                _MetadataText(
                                  text: movie.releaseDate!.year.toString(),
                                ),
                              if (movie.runtime != null)
                                _MetadataText(
                                  text: _formatRuntime(movie.runtime!),
                                ),
                              _RatingPill(rating: movie.voteAverage),
                            ],
                          ),
                          if (movie.genres.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              movie.genres.take(3).join(' · '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.white70,
                                fontSize: 12,
                                height: 1.3,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Poster extends StatelessWidget {
  final String path;

  const _Poster({required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 174,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.yellow.withValues(alpha: .55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .38),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: path.isEmpty
          ? const Icon(
              Icons.movie_outlined,
              color: AppColors.white54,
              size: 44,
            )
          : Image.network(
              'https://image.tmdb.org/t/p/w342$path',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.movie_outlined,
                color: AppColors.white54,
                size: 44,
              ),
            ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;

  const _TypeBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.turquoise.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.turquoise.withValues(alpha: .75),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.turquoise,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MetadataText extends StatelessWidget {
  final String text;

  const _MetadataText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;

  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .42),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.yellow,
            size: 17,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActions extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTrailerTap;

  const _PrimaryActions({
    required this.movie,
    required this.onTrailerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: movie.hasTrailer ? onTrailerTap : null,
            icon: const Icon(Icons.play_arrow_rounded, size: 25),
            label: Text(
              movie.hasTrailer
                  ? 'Ver tráiler'
                  : 'Tráiler no disponible',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.heroText,
              disabledBackgroundColor: AppColors.white54,
              disabledForegroundColor: AppColors.heroText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: movieListsController,
          builder: (context, _) {
            final isFavorite = movieListsController.isFavorite(movie);
            final isSaved = movieListsController.isSaved(movie);

            return Row(
              children: [
                Expanded(
                  child: _DetailActionButton(
                    icon: isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    label: isFavorite ? 'En favoritos' : 'Favoritos',
                    isActive: isFavorite,
                    onTap: () => handleFavoriteTap(context, movie),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DetailActionButton(
                    icon: Icons.save,
                    label: isSaved ? 'Guardada' : 'Guardar',
                    isActive: isSaved,
                    onTap: () => handleSavedTap(context, movie),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DetailActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: .34),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? AppColors.yellow
                  : AppColors.white54,
              width: 1.1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 160),
                scale: isActive ? 1.15 : 1,
                curve: Curves.easeOutBack,
                child: Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? AppColors.yellow
                      : AppColors.white,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive
                        ? AppColors.yellow
                        : AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  final Movie movie;

  const _OverviewSection({required this.movie});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Sinopsis',
      icon: Icons.subject_rounded,
      child: Text(
        movie.overview.trim().isEmpty
            ? 'TMDB no tiene una sinopsis disponible para este título.'
            : movie.overview,
        style: const TextStyle(
          color: AppColors.white70,
          fontSize: 14,
          height: 1.55,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TrailerSection extends StatelessWidget {
  final String videoId;

  const _TrailerSection({required this.videoId});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Tráiler',
      icon: Icons.play_circle_outline_rounded,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: videoId.isEmpty
          ? const _EmptySection(
              icon: Icons.videocam_off_outlined,
              text: 'No hay un tráiler disponible para este título.',
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _YoutubeTrailer(videoId: videoId),
            ),
    );
  }
}

class _YoutubeTrailer extends StatefulWidget {
  final String videoId;

  const _YoutubeTrailer({required this.videoId});

  @override
  State<_YoutubeTrailer> createState() => _YoutubeTrailerState();
}

class _YoutubeTrailerState extends State<_YoutubeTrailer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _buildController(widget.videoId);
  }

  @override
  void didUpdateWidget(covariant _YoutubeTrailer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoId == widget.videoId) {
      return;
    }

    _controller.close();
    _controller = _buildController(widget.videoId);
  }

  YoutubePlayerController _buildController(String videoId) {
    return YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      aspectRatio: 16 / 9,
    );
  }
}

class _CastSection extends StatelessWidget {
  final List<CastMember> cast;

  const _CastSection({required this.cast});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 18),
          child: _SectionHeading(
            title: 'Reparto',
            icon: Icons.groups_2_outlined,
          ),
        ),
        const SizedBox(height: 14),
        if (cast.isEmpty)
          const Padding(
            padding: EdgeInsets.only(right: 18),
            child: _EmptySection(
              icon: Icons.person_off_outlined,
              text: 'No hay información de reparto disponible.',
            ),
          )
        else
          SizedBox(
            height: 188,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: cast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _CastCard(member: cast[index]);
              },
            ),
          ),
      ],
    );
  }
}

class _CastCard extends StatelessWidget {
  final CastMember member;

  const _CastCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: Column(
        children: [
          Container(
            width: 104,
            height: 132,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.imagePlaceholder,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.dividerBlue.withValues(alpha: .48),
              ),
            ),
            child: member.profilePath.isEmpty
                ? const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.white54,
                    size: 42,
                  )
                : Image.network(
                    'https://image.tmdb.org/t/p/w185${member.profilePath}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.white54,
                      size: 42,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            member.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            member.character.isEmpty ? 'Reparto' : member.character,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white54,
              fontSize: 10,
              height: 1.15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalOpinionsSection extends StatelessWidget {
  final Future<List<OpinionWithAuthor>> opinionsFuture;
  final TextEditingController commentController;
  final int rating;
  final bool isSending;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  const _LocalOpinionsSection({
    required this.opinionsFuture,
    required this.commentController,
    required this.rating,
    required this.isSending,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          title: 'Opiniones de Chipileta',
          icon: Icons.forum_outlined,
        ),
        const SizedBox(height: 14),
        _OpinionComposer(
          controller: commentController,
          rating: rating,
          isSending: isSending,
          onRatingChanged: onRatingChanged,
          onSubmit: onSubmit,
        ),
        const SizedBox(height: 18),
        FutureBuilder<List<OpinionWithAuthor>>(
          future: opinionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.yellow,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return const _EmptySection(
                icon: Icons.error_outline_rounded,
                text: 'No fue posible cargar los comentarios.',
              );
            }

            final opinions = snapshot.data ?? const [];

            if (opinions.isEmpty) {
              return const _EmptySection(
                icon: Icons.chat_bubble_outline_rounded,
                text: 'Aún no hay comentarios. Sé el primero en opinar.',
              );
            }

            return Column(
              children: [
                for (var index = 0; index < opinions.length; index++) ...[
                  _LocalOpinionCard(item: opinions[index]),
                  if (index < opinions.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _OpinionComposer extends StatelessWidget {
  final TextEditingController controller;
  final int rating;
  final bool isSending;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  const _OpinionComposer({
    required this.controller,
    required this.rating,
    required this.isSending,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dividerBlue.withValues(alpha: .55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparte tu opinión',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (index) {
              final value = index + 1;
              final selected = value <= rating;

              return IconButton(
                tooltip: '$value estrellas',
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.only(right: 3),
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                onPressed: () => onRatingChanged(value),
                icon: AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  scale: selected ? 1.12 : 1,
                  child: Icon(
                    selected
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: selected
                        ? AppColors.yellow
                        : AppColors.white54,
                    size: 28,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 4,
            minLines: 3,
            maxLength: 500,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13,
              height: 1.4,
            ),
            cursorColor: AppColors.yellow,
            decoration: InputDecoration(
              hintText: '¿Qué te pareció este título?',
              hintStyle: const TextStyle(color: AppColors.white54),
              counterStyle: const TextStyle(color: AppColors.white54),
              filled: true,
              fillColor: AppColors.backgroundDark.withValues(alpha: .34),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.turquoise,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: isSending ? null : onSubmit,
              icon: isSending
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.heroText,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                isSending ? 'Publicando...' : 'Publicar opinión',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.turquoise,
                foregroundColor: AppColors.heroText,
                disabledBackgroundColor: AppColors.white54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalOpinionCard extends StatelessWidget {
  final OpinionWithAuthor item;

  const _LocalOpinionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.dividerBlue.withValues(alpha: .42),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.yellow,
            child: Text(
              item.initials.isEmpty ? '?' : item.initials,
              style: const TextStyle(
                color: AppColors.heroText,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _SmallRating(rating: item.opinion.rating),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _formatDate(item.opinion.createdAt),
                  style: const TextStyle(
                    color: AppColors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  item.opinion.comment,
                  style: const TextStyle(
                    color: AppColors.white70,
                    fontSize: 13,
                    height: 1.45,
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

class _TmdbReviewsSection extends StatelessWidget {
  final List<Review> reviews;

  const _TmdbReviewsSection({required this.reviews});

  @override
  Widget build(BuildContext context) {
    final visibleReviews = reviews.take(5).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          title: 'Reseñas de TMDB',
          icon: Icons.public_rounded,
        ),
        const SizedBox(height: 14),
        if (visibleReviews.isEmpty)
          const _EmptySection(
            icon: Icons.rate_review_outlined,
            text: 'TMDB no tiene reseñas públicas para este título.',
          )
        else
          Column(
            children: [
              for (
                var index = 0;
                index < visibleReviews.length;
                index++
              ) ...[
                _TmdbReviewCard(review: visibleReviews[index]),
                if (index < visibleReviews.length - 1)
                  const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }
}

class _TmdbReviewCard extends StatefulWidget {
  final Review review;

  const _TmdbReviewCard({required this.review});

  @override
  State<_TmdbReviewCard> createState() => _TmdbReviewCardState();
}

class _TmdbReviewCardState extends State<_TmdbReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final rating = widget.review.rating;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.turquoise.withValues(alpha: .34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.turquoise,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.heroText,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.review.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (rating != null)
                _SmallRating(rating: rating / 2),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: Text(
              widget.review.content,
              maxLines: _expanded ? null : 4,
              overflow: _expanded ? null : TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white70,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
          if (widget.review.content.length > 220) ...[
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.yellow,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _expanded ? 'Ver menos' : 'Leer más',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SmallRating extends StatelessWidget {
  final double rating;

  const _SmallRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star_rounded,
          color: AppColors.yellow,
          size: 17,
        ),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            color: AppColors.yellow,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.dividerBlue.withValues(alpha: .42),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(title: title, icon: icon),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeading({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.yellow,
          size: 22,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptySection({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.white54,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white70,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: .48),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Icon(
          icon,
          color: AppColors.white,
          size: 27,
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final Movie movie;
  final VoidCallback onBack;

  const _LoadingView({
    required this.movie,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (movie.backdropPath.isNotEmpty)
          Image.network(
            'https://image.tmdb.org/t/p/w1280${movie.backdropPath}',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x77000000),
                AppColors.homeGradientBottom,
              ],
            ),
          ),
        ),
        SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 14,
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: _CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: onBack,
                  ),
                ),
              ),
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.yellow,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: 12,
            left: 14,
            child: SizedBox(
              width: 46,
              height: 46,
              child: _CircleIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: onBack,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: AppColors.yellow,
                    size: 72,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No pudimos cargar el detalle',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Revisa tu conexión e inténtalo nuevamente.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
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
          ),
        ],
      ),
    );
  }
}

String _formatRuntime(int minutes) {
  if (minutes < 60) {
    return '$minutes min';
  }

  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (remainingMinutes == 0) {
    return '$hours h';
  }

  return '$hours h $remainingMinutes min';
}

String _formatDate(DateTime date) {
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

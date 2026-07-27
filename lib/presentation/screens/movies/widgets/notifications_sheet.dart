import 'package:flutter/material.dart';

import 'package:chipileta_movies_app/domain/entities/app_notification.dart';
import 'package:chipileta_movies_app/presentation/controllers/notifications_controller.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.homeGradient),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.white54,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_rounded,
                      color: AppColors.yellow,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Notificaciones',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    AnimatedBuilder(
                      animation: notificationsController,
                      builder: (context, _) {
                        if (notificationsController.items.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return TextButton.icon(
                          onPressed: notificationsController.clearAll,
                          icon: const Icon(
                            Icons.delete_sweep_rounded,
                            color: AppColors.white70,
                            size: 18,
                          ),
                          label: const Text(
                            'Borrar todo',
                            style: TextStyle(
                              color: AppColors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.dividerBlue, height: 20),
              Flexible(
                child: AnimatedBuilder(
                  animation: notificationsController,
                  builder: (context, _) {
                    final items = notificationsController.items;

                    if (items.isEmpty) {
                      return const _EmptyState();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return Dismissible(
                          key: ValueKey(item.remoteId ?? item.id),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (_) =>
                              notificationsController.remove(item),
                          background: const _DismissBackground(),
                          child: _NotificationTile(item: item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.notificationRed,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_rounded, color: AppColors.white, size: 22),
          SizedBox(width: 8),
          Text(
            'Eliminar',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification item;

  const _NotificationTile({required this.item});

  IconData get _typeIcon {
    switch (item.type) {
      case NotificationType.favorite:
        return Icons.star_rounded;
      case NotificationType.saved:
        return Icons.save;
      case NotificationType.like:
        return Icons.favorite_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Efecto de entrada: aparece con fade y un ligero deslizamiento.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset((1 - t) * 26, 0),
            child: child,
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 54,
              height: 76,
              child: _Poster(path: item.moviePoster),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.movieTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timeAgo(item.createdAt),
                      style: const TextStyle(
                        color: AppColors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      _typeIcon,
                      color: AppColors.yellow,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.legend,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.yellow,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);

  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'hace ${diff.inHours} h';
  if (diff.inDays < 7) return 'hace ${diff.inDays} d';

  return '${date.day}/${date.month}/${date.year}';
}

class _Poster extends StatelessWidget {
  final String path;

  const _Poster({required this.path});

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) {
      return const ColoredBox(
        color: AppColors.imagePlaceholder,
        child: Icon(Icons.movie_outlined, color: AppColors.white54, size: 20),
      );
    }

    return Image.network(
      'https://image.tmdb.org/t/p/w185$path',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: AppColors.imagePlaceholder,
        child: Icon(Icons.movie_outlined, color: AppColors.white54, size: 20),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            color: AppColors.white54,
            size: 46,
          ),
          SizedBox(height: 14),
          Text(
            'Aún no tienes notificaciones',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Guarda o marca películas como favoritas y Chipi te avisará aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
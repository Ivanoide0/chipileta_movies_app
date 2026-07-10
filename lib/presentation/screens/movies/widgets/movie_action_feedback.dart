import 'package:flutter/material.dart';

import 'package:chipileta_movies_app/domain/entities/app_notification.dart';
import 'package:chipileta_movies_app/domain/entities/movie.dart';
import 'package:chipileta_movies_app/presentation/controllers/movie_lists_controller.dart';
import 'package:chipileta_movies_app/presentation/controllers/notifications_controller.dart';
import 'package:chipileta_movies_app/resources/colors/colors.dart';
import 'package:chipileta_movies_app/services/notification_service.dart';

void handleFavoriteTap(BuildContext context, Movie movie) {
  final willBeFavorite = !movieListsController.isFavorite(movie);

  movieListsController.toggleFavorite(movie);
  showFavoriteFeedback(context, added: willBeFavorite);

  if (willBeFavorite) {
    NotificationService.instance.show(
      title: 'Añadida a favoritos',
      body: '${movie.title} está en tus favoritos',
    );
    notificationsController.addForMovie(movie, NotificationType.favorite);
  }
}

void handleSavedTap(BuildContext context, Movie movie) {
  final willBeSaved = !movieListsController.isSaved(movie);

  movieListsController.toggleSaved(movie);
  showSavedFeedback(context, added: willBeSaved);

  if (willBeSaved) {
    NotificationService.instance.show(
      title: 'Película guardada',
      body: 'Chipi la guardó para después',
    );
    notificationsController.addForMovie(movie, NotificationType.saved);
  }
}

void showFavoriteFeedback(
  BuildContext context, {
  required bool added,
}) {
  final overlay = Overlay.maybeOf(context);

  if (overlay == null) return;

  const int animationDurationMs = 2300;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) {
      return IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: animationDurationMs),
            curve: Curves.easeInOutCubic,
            onEnd: () {
              entry.remove();
            },
            builder: (context, value, child) {
              double opacity;

              if (value < 0.18) {
                opacity = (value / 0.18).clamp(0.0, 1.0).toDouble();
              } else if (value < 0.68) {
                opacity = 1;
              } else {
                opacity = ((1 - value) / 0.32).clamp(0.0, 1.0).toDouble();
              }

              final cardScale = value < 0.24
                  ? 0.94 + ((value / 0.24) * 0.06)
                  : 1.0;

              final logoMoveProgress =
                  (value / 0.42).clamp(0.0, 1.0).toDouble();

              final logoOffsetX = logoMoveProgress < 0.5
                  ? logoMoveProgress * 10
                  : 10 - ((logoMoveProgress - 0.5) * 20);

              final logoRotation = logoMoveProgress < 0.5
                  ? logoMoveProgress * 0.16
                  : 0.16 - ((logoMoveProgress - 0.5) * 0.32);

              final starProgress =
                  ((value - 0.24) / 0.52).clamp(0.0, 1.0).toDouble();

              final starOpacity = starProgress < 0.68
                  ? (starProgress / 0.68).clamp(0.0, 1.0).toDouble()
                  : ((1 - starProgress) / 0.32).clamp(0.0, 1.0).toDouble();

              final flyingStarX = 14 + (starProgress * 58);
              final flyingStarY = -2 - (starProgress * 48);
              final flyingStarScale = 0.55 + (starProgress * 0.75);

              final favoriteStarScale = value < 0.38
                  ? 0.72 + ((value / 0.38) * 0.28)
                  : 1.0;

              return Opacity(
                opacity: opacity,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.34 * opacity),
                  child: Center(
                    child: Transform.scale(
                      scale: cardScale,
                      child: Container(
                        width: 230,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 25,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111).withOpacity(0.90),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.yellow.withOpacity(0.24),
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.32),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                            BoxShadow(
                              color: AppColors.yellow.withOpacity(0.10),
                              blurRadius: 30,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 112,
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 86,
                                    height: 86,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.yellow.withOpacity(0.08),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: Offset(logoOffsetX, 0),
                                    child: Transform.rotate(
                                      angle: logoRotation,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(22),
                                        child: Image.asset(
                                          'lib/resources/images/chipilogo 2.png',
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: flyingStarX,
                                    top: 26 + flyingStarY,
                                    child: Opacity(
                                      opacity: starOpacity,
                                      child: Transform.scale(
                                        scale: flyingStarScale,
                                        child: Icon(
                                          Icons.auto_awesome_rounded,
                                          color: AppColors.yellow,
                                          size: 24,
                                          shadows: [
                                            Shadow(
                                              color: AppColors.yellow
                                                  .withOpacity(0.45),
                                              blurRadius: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    bottom: 7,
                                    child: Transform.scale(
                                      scale: favoriteStarScale,
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: AppColors.yellow,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.yellow
                                                  .withOpacity(0.30),
                                              blurRadius: 16,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          added
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          size: 20,
                                          color: AppColors.heroText,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              added
                                  ? 'Agregada a favoritos'
                                  : 'Quitada de favoritos',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              added
                                  ? 'Chipi la guardó para ti'
                                  : 'Chipi la quitó de tu lista',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );

  overlay.insert(entry);
}

void showSavedFeedback(
  BuildContext context, {
  required bool added,
}) {
  final overlay = Overlay.maybeOf(context);

  if (overlay == null) return;

  const int animationDurationMs = 2300;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) {
      return IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: animationDurationMs),
            curve: Curves.easeInOutCubic,
            onEnd: () {
              entry.remove();
            },
            builder: (context, value, child) {
              double opacity;

              if (value < 0.18) {
                opacity = (value / 0.18).clamp(0.0, 1.0).toDouble();
              } else if (value < 0.70) {
                opacity = 1;
              } else {
                opacity = ((1 - value) / 0.30).clamp(0.0, 1.0).toDouble();
              }

              final cardScale = value < 0.24
                  ? 0.94 + ((value / 0.24) * 0.06)
                  : 1.0;

              final logoProgress =
                  ((value - 0.10) / 0.55).clamp(0.0, 1.0).toDouble();

              final logoOffsetY = logoProgress < 0.70
                  ? logoProgress * 22
                  : 22 - ((logoProgress - 0.70) * 12);

              final logoScale = logoProgress < 0.70
                  ? 1.0 - (logoProgress * 0.10)
                  : 0.93;

              final arrowProgress =
                  ((value - 0.22) / 0.48).clamp(0.0, 1.0).toDouble();

              final arrowOpacity = arrowProgress < 0.75
                  ? (arrowProgress / 0.75).clamp(0.0, 1.0).toDouble()
                  : ((1 - arrowProgress) / 0.25).clamp(0.0, 1.0).toDouble();

              final arrowOffsetY = -34 + (arrowProgress * 42);

              final trayProgress =
                  ((value - 0.28) / 0.42).clamp(0.0, 1.0).toDouble();

              final trayWidth = 56 + (trayProgress * 28);
              final trayOpacity = trayProgress.clamp(0.0, 1.0).toDouble();

              final savedIconScale = value < 0.48
                  ? 0.76 + ((value / 0.48) * 0.24)
                  : 1.0;

              return Opacity(
                opacity: opacity,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.34 * opacity),
                  child: Center(
                    child: Transform.scale(
                      scale: cardScale,
                      child: Container(
                        width: 230,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 25,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111).withOpacity(0.90),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.yellow.withOpacity(0.24),
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.32),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                            BoxShadow(
                              color: AppColors.yellow.withOpacity(0.10),
                              blurRadius: 30,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 124,
                              height: 112,
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.yellow.withOpacity(0.08),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8 + arrowOffsetY,
                                    child: Opacity(
                                      opacity: arrowOpacity,
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.yellow,
                                        size: 34,
                                        shadows: [
                                          Shadow(
                                            color: AppColors.yellow
                                                .withOpacity(0.35),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: Offset(0, logoOffsetY),
                                    child: Transform.scale(
                                      scale: logoScale,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(22),
                                        child: Image.asset(
                                          'lib/resources/images/chipilogo 2.png',
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 6,
                                    child: Opacity(
                                      opacity: trayOpacity,
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: trayWidth,
                                        height: 15,
                                        decoration: BoxDecoration(
                                          color: AppColors.yellow
                                              .withOpacity(0.16),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: AppColors.yellow
                                                .withOpacity(0.65),
                                            width: 1.4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    bottom: 7,
                                    child: Transform.scale(
                                      scale: savedIconScale,
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: AppColors.yellow,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.yellow
                                                  .withOpacity(0.30),
                                              blurRadius: 16,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          added ? Icons.save : Icons.save,
                                          size: 20,
                                          color: AppColors.heroText,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              added
                                  ? 'Película guardada'
                                  : 'Película quitada',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              added
                                  ? 'Chipi la guardó para después'
                                  : 'Chipi la sacó de guardados',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );

  overlay.insert(entry);
}
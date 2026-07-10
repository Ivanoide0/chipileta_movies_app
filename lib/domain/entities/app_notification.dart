enum NotificationType { favorite, saved }

class AppNotification {
  final int? id;
  final int movieId;
  final String movieTitle;
  final String moviePoster;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    this.id,
    required this.movieId,
    required this.movieTitle,
    required this.moviePoster,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  // Leyenda que se muestra en el panel segun el tipo.
  String get legend => type == NotificationType.favorite
      ? 'Película agregada a favoritos'
      : 'Tu película se guardó correctamente';
}

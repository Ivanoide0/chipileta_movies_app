enum NotificationType { favorite, saved, like }

class AppNotification {
  final int? id;
  final String? remoteId;
  final int movieId;
  final String movieTitle;
  final String moviePoster;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    this.id,
    this.remoteId,
    required this.movieId,
    required this.movieTitle,
    required this.moviePoster,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  String get legend {
    switch (type) {
      case NotificationType.favorite:
        return 'Película agregada a favoritos';
      case NotificationType.saved:
        return 'Tu película se guardó correctamente';
      case NotificationType.like:
        return 'Recibiste un like por tu review';
    }
  }
}

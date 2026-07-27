enum NotificationType { favorite, saved, like }

class AppNotification {
  final int? id; // id local (SQLite) para favoritos/guardados.
  final String? remoteId; // id de documento en Firestore para likes.
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

  // Leyenda que se muestra en el panel segun el tipo.
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

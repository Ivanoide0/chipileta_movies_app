import '../../entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    super.id,
    required super.movieId,
    required super.movieTitle,
    required super.moviePoster,
    required super.type,
    required super.createdAt,
    super.isRead,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'movie_id': movieId,
    'movie_title': movieTitle,
    'movie_poster': moviePoster,
    'type': type.name,
    'created_at': createdAt.toIso8601String(),
    'is_read': isRead ? 1 : 0,
  };

  factory AppNotificationModel.fromMap(Map<String, dynamic> map) =>
    AppNotificationModel(
      id: map['id'] as int?,
      movieId: map['movie_id'] as int,
      movieTitle: map['movie_title'] as String,
      moviePoster: map['movie_poster'] as String,
      type: NotificationType.values.byName(map['type'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      isRead: (map['is_read'] as int) == 1,
    );

  AppNotification toEntity() => AppNotification(
    id: id,
    movieId: movieId,
    movieTitle: movieTitle,
    moviePoster: moviePoster,
    type: type,
    createdAt: createdAt,
    isRead: isRead,
  );
}

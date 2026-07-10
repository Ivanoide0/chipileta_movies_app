import '../entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<AppNotification> add({
    required int movieId,
    required String movieTitle,
    required String moviePoster,
    required NotificationType type,
  });

  Future<List<AppNotification>> getAll();

  Future<void> markAllRead();

  Future<void> delete(int id);

  Future<void> clearAll();
}
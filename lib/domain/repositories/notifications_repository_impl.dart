import '../datasources/notifications_local_datasource.dart';
import '../entities/app_notification.dart';
import 'notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsLocalDataSource localDataSource;

  NotificationsRepositoryImpl(this.localDataSource);

  @override
  Future<AppNotification> add({
    required int movieId,
    required String movieTitle,
    required String moviePoster,
    required NotificationType type,
  }) async {
    final model = await localDataSource.add(
      movieId: movieId,
      movieTitle: movieTitle,
      moviePoster: moviePoster,
      type: type,
    );
    return model.toEntity();
  }

  @override
  Future<List<AppNotification>> getAll() async {
    final models = await localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> markAllRead() => localDataSource.markAllRead();

  @override
  Future<void> delete(int id) => localDataSource.delete(id);

  @override
  Future<void> clearAll() => localDataSource.clearAll();
}
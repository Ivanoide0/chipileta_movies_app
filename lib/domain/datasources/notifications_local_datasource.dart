import '../data/models/app_notification_model.dart';
import '../entities/app_notification.dart';
import 'database_helper.dart';

class NotificationsLocalDataSource {
  final DatabaseHelper dbHelper;

  NotificationsLocalDataSource(this.dbHelper);

  Future<AppNotificationModel> add({
    required int movieId,
    required String movieTitle,
    required String moviePoster,
    required NotificationType type,
  }) async {
    final db = await dbHelper.database;
    final now = DateTime.now();

    final model = AppNotificationModel(
      movieId: movieId,
      movieTitle: movieTitle,
      moviePoster: moviePoster,
      type: type,
      createdAt: now,
      isRead: false,
    );

    final id = await db.insert('notifications', model.toMap());

    return AppNotificationModel(
      id: id,
      movieId: movieId,
      movieTitle: movieTitle,
      moviePoster: moviePoster,
      type: type,
      createdAt: now,
      isRead: false,
    );
  }

  Future<List<AppNotificationModel>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'notifications',
      orderBy: 'created_at DESC',
    );

    return result.map((map) => AppNotificationModel.fromMap(map)).toList();
  }

  Future<void> markAllRead() async {
    final db = await dbHelper.database;
    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'is_read = ?',
      whereArgs: [0],
    );
  }

  Future<void> delete(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAll() async {
    final db = await dbHelper.database;
    await db.delete('notifications');
  }
}
import 'package:flutter/foundation.dart';

import 'package:chipileta_movies_app/domain/datasources/database_helper.dart';
import 'package:chipileta_movies_app/domain/datasources/notifications_local_datasource.dart';
import 'package:chipileta_movies_app/domain/entities/app_notification.dart';
import 'package:chipileta_movies_app/domain/entities/movie.dart';
import 'package:chipileta_movies_app/domain/repositories/notifications_repository_impl.dart';
import 'package:chipileta_movies_app/domain/usercases/add_notification_usecase.dart';
import 'package:chipileta_movies_app/domain/usercases/clear_notifications_usecase.dart';
import 'package:chipileta_movies_app/domain/usercases/delete_notification_usecase.dart';
import 'package:chipileta_movies_app/domain/usercases/get_notifications_usecase.dart';
import 'package:chipileta_movies_app/domain/usercases/mark_notifications_read_usecase.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController() {
    final datasource = NotificationsLocalDataSource(DatabaseHelper.instance);
    final repository = NotificationsRepositoryImpl(datasource);

    _addNotification = AddNotificationUseCase(repository);
    _getNotifications = GetNotificationsUseCase(repository);
    _markRead = MarkNotificationsReadUseCase(repository);
    _deleteNotification = DeleteNotificationUseCase(repository);
    _clearNotifications = ClearNotificationsUseCase(repository);
  }

  late final AddNotificationUseCase _addNotification;
  late final GetNotificationsUseCase _getNotifications;
  late final MarkNotificationsReadUseCase _markRead;
  late final DeleteNotificationUseCase _deleteNotification;
  late final ClearNotificationsUseCase _clearNotifications;

  List<AppNotification> _items = const [];
  List<AppNotification> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  Future<void> load() async {
    _items = await _getNotifications();
    notifyListeners();
  }

  Future<void> addForMovie(Movie movie, NotificationType type) async {
    await _addNotification(
      movieId: movie.id,
      movieTitle: movie.title,
      moviePoster: movie.posterPath,
      type: type,
    );
    await load();
  }

  Future<void> markAllRead() async {
    if (!hasUnread) return;
    await _markRead();
    await load();
  }

  // Quita de inmediato de la lista (UI fluida) y luego borra en la base.
  Future<void> remove(AppNotification item) async {
    final id = item.id;
    if (id == null) return;

    _items = _items.where((n) => n.id != id).toList();
    notifyListeners();

    await _deleteNotification(id);
  }

  Future<void> clearAll() async {
    if (_items.isEmpty) return;

    _items = const [];
    notifyListeners();

    await _clearNotifications();
  }
}

final notificationsController = NotificationsController();
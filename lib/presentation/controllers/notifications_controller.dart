import 'package:flutter/foundation.dart';

import 'package:chipileta_movies_app/domain/datasources/database_helper.dart';
import 'package:chipileta_movies_app/domain/datasources/notifications_local_datasource.dart';
import 'package:chipileta_movies_app/domain/datasources/notifications_remote_datasource.dart';
import 'package:chipileta_movies_app/domain/datasources/session_service.dart';
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

  final NotificationsRemoteDataSource _remote = NotificationsRemoteDataSource();

  String? get _uid => SessionService.instance.currentUser?.id;

  List<AppNotification> _items = const [];
  List<AppNotification> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  Future<void> load() async {
    final local = await _getNotifications();
    final uid = _uid;
    final remote =
        uid == null ? <AppNotification>[] : await _remote.getForUser(uid);

    _items = [...local, ...remote]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
    final uid = _uid;
    if (uid != null) await _remote.markAllRead(uid);
    await load();
  }

  Future<void> remove(AppNotification item) async {
    _items = _items.where((n) => !identical(n, item)).toList();
    notifyListeners();

    if (item.remoteId != null) {
      final uid = _uid;
      if (uid != null) await _remote.delete(uid, item.remoteId!);
    } else if (item.id != null) {
      await _deleteNotification(item.id!);
    }
  }

  Future<void> clearAll() async {
    if (_items.isEmpty) return;

    _items = const [];
    notifyListeners();

    await _clearNotifications();
    final uid = _uid;
    if (uid != null) await _remote.clearAll(uid);
  }
}

final notificationsController = NotificationsController();
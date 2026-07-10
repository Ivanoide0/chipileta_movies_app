import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<AppNotification>> call() => repository.getAll();
}
